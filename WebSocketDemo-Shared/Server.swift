import SwiftUI
import CoreMotion
import AVFoundation
import Combine
import Network
import CoreLocation
import WatchConnectivity
import VideoToolbox

struct CPUUsage: Encodable, Identifiable {
  let usage: Double
  let date: Date
  let id = UUID()

  enum CodingKeys: String, CodingKey {
    case usage
  }
}

struct MemoryUsage: Encodable, Identifiable {
  let usage: Double
  let date: Date
  let id = UUID()

  enum CodingKeys: String, CodingKey {
    case usage
  }
}

struct Timestamp: Encodable {
  let sec: UInt32
  let nsec: UInt32
}
extension Timestamp {
  init(_ date: Date) {
    let seconds = date.timeIntervalSince1970
    var intSec = UInt32(seconds)
    var intNsec = UInt32(seconds.truncatingRemainder(dividingBy: 1) * 1_000_000_000)
    if intNsec > 999_999_999 {
      intSec += 1
      intNsec -= 1_000_000_000
    }
    sec = intSec
    nsec = intNsec
  }
}
struct Health: Encodable {
  let heart_rate: Double
  let timestamp: Timestamp
}

enum Camera: CaseIterable, Identifiable, CustomStringConvertible {
  case back
  case front
//  case backDepth
//  case frontDepth

  var description: String {
    switch self {
    case .back:
      return "Back"
    case .front:
      return "Front"
    }
  }

  var id: Self {
    return self
  }
}

enum ServerError: Error {
  case noCameraDevice
}


func configureInputs(in session: AVCaptureSession, for camera: Camera) throws {
  for input in session.inputs {
    session.removeInput(input)
  }
  
  let device: AVCaptureDevice?
  switch camera {
  case .back:
    device = .default(.builtInWideAngleCamera, for: .video, position: .back)
  case .front:
    device = .default(.builtInWideAngleCamera, for: .video, position: .front)
  }

  guard let device else {
    throw ServerError.noCameraDevice
  }

  do {
    let input = try AVCaptureDeviceInput(device: device)
    print("ranges: \(input.device.activeFormat.videoSupportedFrameRateRanges)")
    session.addInput(input)
//        input.videoMinFrameDurationOverride = CMTime(seconds: 0.1, preferredTimescale: 30)
  } catch let error {
    print("failed to create device input: \(error)")
  }
}

@MainActor
class Server: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {
  let videoQueue = DispatchQueue(label: "VideoQueue")

  @Published
  var addresses: [IPAddress] = []
  private var addressUpdateTimer: Timer?

  @AppStorage("foxglove.preferred-port")
  var preferredPort: Int?

  @Published var actualPort: NWEndpoint.Port?

  let server = FoxgloveServer()

  let motionManager = CMMotionManager()
  let locationManager = CLLocationManager()
  var captureSession: AVCaptureSession?
  var compressionSessionOut: VTCompressionSession?

  var subscribers: [AnyCancellable] = []

  let poseChannel: ChannelID
  let cameraChannel: ChannelID
  let locationChannel: ChannelID
  let cpuChannel: ChannelID
  let memChannel: ChannelID
  let healthChannel: ChannelID

  let watchSession = WCSession.default

  @Published var droppedVideoFrames = 0

  @Published var sendPose = true {
    didSet {
      if sendPose {
        startPoseUpdates()
      } else {
        stopPoseUpdates()
      }
    }
  }

  @Published var sendCamera = false {
    didSet {
      if sendCamera {
        startCameraUpdates()
      } else {
        stopCameraUpdates()
      }
    }
  }
  var hasCameraPermission: Bool {
    AVCaptureDevice.authorizationStatus(for: .video) == .authorized
  }

  @Published var sendLocation = false {
    didSet {
      if sendLocation {
        startLocationUpdates()
      } else {
        stopLocationUpdates()
      }
    }
  }
  var hasLocationPermission: Bool {
    locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
  }

  @Published var sendCPU = true {
    didSet {
      if sendCPU {
        startCPUUpdates()
      } else {
        stopCPUUpdates()
      }
    }
  }

  @Published var sendMemory = true {
    didSet {
      if sendMemory {
        startMemoryUpdates()
      } else {
        stopMemoryUpdates()
      }
    }
  }

  @Published var sendWatchData = false {
    didSet {
      if sendWatchData {
        startWatchUpdates()
      } else {
        stopWatchUpdates()
      }
    }
  }

  @Published var activeCamera: Camera = .back {
    didSet {
      print("set active camera \(activeCamera)")
      reconfigureSession()
    }
  }

  var clientEndpointNames: [String] {
    return server.clientEndpointNames
  }

  var cpuTimer: Timer?
  @Published var cpuHistory: [CPUUsage] = []

  var memTimer: Timer?
  @Published var memHistory: [MemoryUsage] = []

  override init() {
    poseChannel = server.addChannel(
      topic: "pose",
      encoding: "json",
      schemaName: "foxglove.PoseInFrame",
      schema: poseInFrameSchema
    )
    cameraChannel = server.addChannel(
      topic: "camera",
      encoding: "protobuf",
      schemaName: Foxglove_CompressedVideo.protoMessageName,
      schema: try! Data(contentsOf: Bundle(for: Self.self).url(forResource: "CompressedVideo", withExtension: "bin")!).base64EncodedString()
    )
    locationChannel = server.addChannel(
      topic: "gps",
      encoding: "protobuf",
      schemaName: Foxglove_LocationFix.protoMessageName,
      schema: try! Data(contentsOf: Bundle(for: Self.self).url(forResource: "LocationFix", withExtension: "bin")!).base64EncodedString()
    )
    cpuChannel = server.addChannel(topic: "cpu", encoding: "json", schemaName: "CPU", schema:
#"""
{
  "type":"object",
  "properties":{
    "usage":{"type":"number"}
  }
}
"""#)
    memChannel = server.addChannel(topic: "memory", encoding: "json", schemaName: "Memory", schema:
#"""
{
  "type":"object",
  "properties":{
    "usage":{"type":"number"}
  }
}
"""#)
    healthChannel = server.addChannel(topic: "health", encoding: "json", schemaName: "Health", schema:
#"""
{
  "type":"object",
  "properties":{
    "heart_rate":{"type":"number"},
    "timestamp":{
      "type":"object",
      "properties":{"sec":{"type":"number"},"nsec":{"type":"number"}}
    }
  }
}
"""#)
    super.init()
    server.start(preferredPort: preferredPort.flatMap { UInt16(exactly: $0) })
    server.$port
      .sink { [weak self] in
        self?.actualPort = $0
        self?.preferredPort = $0.flatMap { Int(exactly: $0.rawValue) }
      }
      .store(in: &subscribers)
    server.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }.store(in: &subscribers)
    startPoseUpdates()
    startCPUUpdates()
    startMemoryUpdates()
    watchSession.delegate = self

    updateAddresses()
    addressUpdateTimer = .scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
      guard let self else { return }
      Task { @MainActor in
        self.updateAddresses()
      }
    }
  }

  func updateAddresses() {
    self.addresses = getIPAddresses()
      .filter {
        // Filter out some AirDrop interfaces that are not useful https://apple.stackexchange.com/q/394047/8318
        if $0.interface?.name.hasPrefix("llw") == true || $0.interface?.name.hasPrefix("awdl") == true {
          return false
        }
        return $0.interface?.type == .wifi || $0.interface?.type == .wiredEthernet
      }
      .sorted(by: compareIPAddresses)
  }

  deinit {
    addressUpdateTimer?.invalidate()
  }

  func startCPUUpdates() {
    cpuHistory = []
    let timer = Timer(timeInterval: 0.25, repeats: true) { [self] _ in
      let cpuUsage = CPUUsage(
        usage: getCPUUsage(),
        date: .now
      )
      let enc = JSONEncoder()
      enc.outputFormatting = .sortedKeys
      let data = try! enc.encode(cpuUsage)

      Task { @MainActor in
        self.cpuHistory.append(cpuUsage)
        if self.cpuHistory.count > 20 {
          self.cpuHistory.remove(at: 0)
        }
        self.server.sendMessage(on: self.cpuChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
      }
    }
    cpuTimer = timer
    RunLoop.main.add(timer, forMode: .common) // https://stackoverflow.com/a/60999226
  }

  func stopCPUUpdates() {
    cpuTimer?.invalidate()
    cpuTimer = nil
  }

  func startMemoryUpdates() {
    memHistory = []
    let timer = Timer(timeInterval: 0.25, repeats: true) { [self] _ in
      let usage = getMemoryUsage()
      let memUsage = MemoryUsage(
        usage: Double(usage.used) / Double(usage.total),
        date: .now
      )
      let enc = JSONEncoder()
      enc.outputFormatting = .sortedKeys
      let data = try! enc.encode(memUsage)

      Task { @MainActor in
        self.memHistory.append(memUsage)
        if self.memHistory.count > 20 {
          self.memHistory.remove(at: 0)
        }
        self.server.sendMessage(on: self.memChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
      }
    }
    memTimer = timer
    RunLoop.main.add(timer, forMode: .common) // https://stackoverflow.com/a/60999226
  }

  func stopMemoryUpdates() {
    memTimer?.invalidate()
    memTimer = nil
  }


  func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    if hasLocationPermission {
      locationManager.startUpdatingLocation()
    }
  }

  func stopLocationUpdates() {
    locationManager.stopUpdatingLocation()
  }

  nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location: CLLocation = locations.last else { return }

    var msg = Foxglove_LocationFix()
    msg.latitude = location.coordinate.latitude
    msg.longitude = location.coordinate.longitude
    msg.altitude = location.altitude

    let data = try! msg.serializedData()

    Task { @MainActor in
      server.sendMessage(on: locationChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
    }
  }

  nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    print("got location authorization: \(manager.authorizationStatus)")
    manager.startUpdatingLocation()
  }

  func startPoseUpdates() {
    motionManager.deviceMotionUpdateInterval = 0.02
    motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
      if let motion {
        self.sendPose(motion: motion)
      }
    }
  }
  func stopPoseUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }

  func sendPose(motion: CMDeviceMotion) {
    let data = try! JSONSerialization.data(withJSONObject: [
      "timestamp": ["sec":0,"nsec":0],
      "frame_id": "root",
      "pose": [
        "position":["x":0,"y":0,"z":0],
        "orientation":[
          "x":motion.attitude.quaternion.x,
          "y":motion.attitude.quaternion.y,
          "z":motion.attitude.quaternion.z,
          "w":motion.attitude.quaternion.w,
        ],
      ],
    ], options: .sortedKeys)

    server.sendMessage(on: poseChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
  }

  func startCameraUpdates() {
    droppedVideoFrames = 0
    let activeCamera = self.activeCamera
    
    videoQueue.async {
      let session = AVCaptureSession()
      do {
        try configureInputs(in: session, for: activeCamera)
      } catch let error {
        print("error starting session: \(error)")
      }
      session.sessionPreset = .medium

      let output = AVCaptureVideoDataOutput()
      output.setSampleBufferDelegate(self, queue: self.videoQueue)
      session.addOutput(output)
      session.startRunning()
     
      Task { @MainActor in self.captureSession = session }
    }
  }

  func stopCameraUpdates() {
    let session = self.captureSession
    DispatchQueue.global(qos: .userInitiated).async {
      session?.stopRunning()
      Task { @MainActor in
        self.captureSession = nil
      }
    }
  }

  func reconfigureSession() {
    guard let session = captureSession else {
      return
    }
    let activeCamera = self.activeCamera

    Task.detached(priority: .userInitiated) {
      print("changing session")

      session.beginConfiguration()
      do {
        try configureInputs(in: session, for: activeCamera)
      } catch let error {
        print("error changing session: \(error)")
      }
      session.commitConfiguration()
    }
  }


  nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let imageBuffer = sampleBuffer.imageBuffer else {
      print("no image buffer :(")
      return
    }
    Task { @MainActor in
      if compressionSessionOut == nil {
        var err: OSStatus = noErr
        err = VTCompressionSessionCreate(allocator: kCFAllocatorDefault,
                                             width: 720,
                                             height: 1280,
                                             codecType: kCMVideoCodecType_H264,
                                             encoderSpecification: nil,
                                             imageBufferAttributes: nil,
                                             compressedDataAllocator: nil,
                                             outputCallback: nil,
                                             refcon: nil,
                                             compressionSessionOut: &compressionSessionOut)
        guard err == noErr, let compressionSession = compressionSessionOut else {
          fatalError("VTCompressionSession creation failed (\(err))!")
        }
        err = VTSessionSetProperty(compressionSession, key: kVTCompressionPropertyKey_ProfileLevel, value: kVTProfileLevel_H264_Main_AutoLevel)
        if noErr != err {
               print("Warning: VTSessionSetProperty(kVTCompressionPropertyKey_ProfileLevel) failed (\(err))")
           }
        
        // Indicate that the compression session is in real time, which streaming
        // requires.
        err = VTSessionSetProperty(compressionSession, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
        if noErr != err {
            print("Warning: VTSessionSetProperty(kVTCompressionPropertyKey_RealTime) failed (\(err))")
        }
        // Enables temporal compression.
        err = VTSessionSetProperty(compressionSession, key: kVTCompressionPropertyKey_AllowTemporalCompression, value: kCFBooleanTrue)
        if noErr != err {
            print("Warning: VTSessionSetProperty(kVTCompressionPropertyKey_AllowTemporalCompression) failed (\(err))")
        }

        
        
      }
   
      
      VTCompressionSessionEncodeFrame(compressionSessionOut!, imageBuffer: sampleBuffer.imageBuffer!, presentationTimeStamp: sampleBuffer.presentationTimeStamp, duration: .invalid, frameProperties: nil, infoFlagsOut: nil) { status, infoFlags, sampleBuffer  in
        if infoFlags.contains(.frameDropped) {
            print("Encoder dropped the frame with status \(status)")
            return
        }
        // If frame encoding fails in a live streaming use case, drop any
        // pending frames that the encoder may emit and force a key frame.
        // See `kVTEncodeFrameOptionKey_ForceKeyFrame` for information about
        // forcing a key frame. This sample app doesn't include this
        // implementation.
        guard noErr == status else {
            print("Encoder returned an error for frame with \(status)")
            return
        }
        guard let sampleBuffer else {
            print("Encoder returned an unexpected NULL sampleBuffer for frame")
            return
        }
        var protoVideo = Foxglove_CompressedVideo()
        protoVideo.timestamp = .init(date: .now)
        protoVideo.frameID = "camera"
        protoVideo.format = "h264"
        try! sampleBuffer.dataBuffer?.withContiguousStorage({ rawBufferPtr in
           protoVideo.data = Data(rawBufferPtr)
        });
        
        let serializedProto = try! protoVideo.serializedData()
        Task { @MainActor in
          self.server.sendMessage(on: self.cameraChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: serializedProto)
        }
      }
    }
  }

  nonisolated func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    Task { @MainActor in
      self.droppedVideoFrames += 1
    }
  }
}


extension Server: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("watch activation completed: \(activationState), error: \(error)")
  }

  func sessionDidBecomeInactive(_ session: WCSession) {
    print("watch became inactive")
  }

  func sessionDidDeactivate(_ session: WCSession) {
    print("watch deactivated")
  }

  func startWatchUpdates() {
    watchSession.activate()
  }
  func stopWatchUpdates() {
    print("stop watch updates?")
  }

  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("message from watch: \(message)")
    guard sendWatchData else {
      return
    }

    if let bpm = message["heart_rate"] as? Double {
      let health = Health(
        heart_rate: bpm,
        timestamp: Timestamp(.now)
      )
      let enc = JSONEncoder()
      enc.outputFormatting = .sortedKeys
      let data = try! enc.encode(health)

      Task { @MainActor in
        self.server.sendMessage(on: self.healthChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
      }
    }
  }
}
