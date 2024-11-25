import AVFoundation
import Combine
import CoreLocation
import CoreMotion
import Network
import SwiftUI
import WatchConnectivity

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable force_try

struct CPUUsage: UsageDatum {
  let usage: Double
  let date: Date
  let id = UUID()

  enum CodingKeys: String, CodingKey {
    case usage
  }
}

struct MemoryUsage: UsageDatum {
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

@MainActor
class Server: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {
  @Published
  var addresses: [IPAddress] = []
  private var addressUpdateTimer: Timer?

  @AppStorage("foxglove.preferred-port")
  var preferredPort: Int?

  @Published var actualPort: NWEndpoint.Port?

  let server = FoxgloveServer()

  let cameraManager = CameraManager()
  let motionManager = CMMotionManager()
  let locationManager = CLLocationManager()

  var subscribers: [AnyCancellable] = []

  let poseChannel: ChannelID
  let calibrationChannel: ChannelID
  let h264Channel: ChannelID
  let h265Channel: ChannelID
  let jpegChannel: ChannelID
  let locationChannel: ChannelID
  let cpuChannel: ChannelID
  let memChannel: ChannelID
  let healthChannel: ChannelID

  let watchSession = WCSession.default

  @Published private(set) var droppedVideoFrames = 0

  @Published private(set) var cameraError: Error?

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
        cameraManager.startCameraUpdates()
      } else {
        cameraManager.stopCameraUpdates()
      }
    }
  }

  @Published var compressionMode = CompressionMode.JPEG {
    didSet {
      cameraManager.compressionMode = compressionMode
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
    locationManager.authorizationStatus == .authorizedWhenInUse || locationManager
      .authorizationStatus == .authorizedAlways
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
      cameraManager.activeCamera = activeCamera
    }
  }

  var clientEndpointNames: [String] {
    server.clientEndpointNames
  }

  var cpuTimer: Timer?
  let cpuHistory = UsageHistory<CPUUsage>()

  var memTimer: Timer?
  let memHistory = UsageHistory<MemoryUsage>()

  override init() {
    poseChannel = server.addChannel(
      topic: "pose",
      encoding: "json",
      schemaName: "foxglove.PoseInFrame",
      schema: poseInFrameSchema
    )
    jpegChannel = server.addChannel(
      topic: "camera_jpeg",
      encoding: "protobuf",
      schemaName: Foxglove_CompressedImage.protoMessageName,
      schema: try! Data(contentsOf: Bundle(for: Self.self).url(forResource: "CompressedImage", withExtension: "bin")!)
        .base64EncodedString()
    )
    calibrationChannel = server.addChannel(
      topic: "calibration",
      encoding: "protobuf",
      schemaName: Foxglove_CameraCalibration.protoMessageName,
      schema: try! Data(contentsOf: Bundle(for: Self.self).url(forResource: "CameraCalibration", withExtension: "bin")!)
        .base64EncodedString()
    )
    h264Channel = server.addChannel(
      topic: "camera_h264",
      encoding: "protobuf",
      schemaName: Foxglove_CompressedVideo.protoMessageName,
      schema: try! Data(contentsOf: Bundle(for: Self.self).url(forResource: "CompressedVideo", withExtension: "bin")!)
        .base64EncodedString()
    )
    h265Channel = server.addChannel(
      topic: "camera_h265",
      encoding: "protobuf",
      schemaName: Foxglove_CompressedVideo.protoMessageName,
      schema: try! Data(contentsOf: Bundle(for: Self.self).url(forResource: "CompressedVideo", withExtension: "bin")!)
        .base64EncodedString()
    )
    locationChannel = server.addChannel(
      topic: "gps",
      encoding: "protobuf",
      schemaName: Foxglove_LocationFix.protoMessageName,
      schema: try! Data(contentsOf: Bundle(for: Self.self).url(forResource: "LocationFix", withExtension: "bin")!)
        .base64EncodedString()
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

    cameraManager.$droppedFrames
      .assign(to: \.droppedVideoFrames, on: self)
      .store(in: &subscribers)

    cameraManager.$currentError
      .assign(to: \.cameraError, on: self)
      .store(in: &subscribers)

    cameraManager.calibrationData
      .sink { [weak self] calibration in
        guard let self else {
          return
        }
        var msg = Foxglove_CameraCalibration()
        msg.timestamp = .init(date: .now)
        msg.frameID = "camera"
        // Convert column-major to row-major
        msg.k = (0 ..< 3).flatMap { r in (0 ..< 3).map { c in Double(calibration.intrinsicMatrix[c, r]) } }
        msg.p = [
          msg.k[0], msg.k[1], msg.k[2], 0,
          msg.k[3], msg.k[4], msg.k[5], 0,
          msg.k[6], msg.k[7], msg.k[8], 0,
        ]
        msg.width = UInt32(calibration.width)
        msg.height = UInt32(calibration.height)
        let data = try! msg.serializedData()
        self.server.sendMessage(
          on: self.calibrationChannel,
          timestamp: DispatchTime.now().uptimeNanoseconds,
          payload: data
        )
      }
      .store(in: &subscribers)

    cameraManager.jpegFrames
      .sink { [weak self] in
        guard let self else {
          return
        }
        var msg = Foxglove_CompressedImage()
        msg.timestamp = .init(date: .now)
        msg.frameID = "camera"
        msg.format = "jpeg"
        msg.data = $0
        let data = try! msg.serializedData()
        self.server.sendMessage(on: self.jpegChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
      }
      .store(in: &subscribers)

    cameraManager.h264Frames
      .sink { [weak self] in
        guard let self else {
          return
        }
        var msg = Foxglove_CompressedVideo()
        msg.timestamp = .init(date: .now)
        msg.frameID = "camera"
        msg.format = "h264"
        msg.data = $0
        let data = try! msg.serializedData()
        self.server.sendMessage(on: self.h264Channel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
      }
      .store(in: &subscribers)

    cameraManager.h265Frames
      .sink { [weak self] in
        guard let self else {
          return
        }
        var msg = Foxglove_CompressedVideo()
        msg.timestamp = .init(date: .now)
        msg.frameID = "camera"
        msg.format = "h265"
        msg.data = $0
        let data = try! msg.serializedData()
        self.server.sendMessage(on: self.h265Channel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
      }
      .store(in: &subscribers)

    updateAddresses()
    addressUpdateTimer = .scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
      guard let self else { return }
      Task { @MainActor in
        self.updateAddresses()
      }
    }
  }

  func updateAddresses() {
    addresses = getIPAddresses()
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
    cpuHistory.clear()
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
    memHistory.clear()
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

  nonisolated func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
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
      "timestamp": ["sec": 0, "nsec": 0],
      "frame_id": "root",
      "pose": [
        "position": ["x": 0, "y": 0, "z": 0],
        "orientation": [
          "x": motion.attitude.quaternion.x,
          "y": motion.attitude.quaternion.y,
          "z": motion.attitude.quaternion.z,
          "w": motion.attitude.quaternion.w,
        ],
      ],
    ], options: .sortedKeys)

    server.sendMessage(on: poseChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
  }
}

extension Server: WCSessionDelegate {
  func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("watch activation completed: \(activationState), error: \(error)")
  }

  func sessionDidBecomeInactive(_: WCSession) {
    print("watch became inactive")
  }

  func sessionDidDeactivate(_: WCSession) {
    print("watch deactivated")
  }

  func startWatchUpdates() {
    watchSession.activate()
  }

  func stopWatchUpdates() {
    print("stop watch updates?")
  }

  func session(_: WCSession, didReceiveMessage message: [String: Any]) {
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
