import SwiftUI
import CoreMotion
import AVFoundation
import Combine
import Network
import CoreLocation

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
  let address = getIPAddress() ?? "<no address>"

  let server = FoxgloveServer()

  let motionManager = CMMotionManager()
  let locationManager = CLLocationManager()
  var captureSession: AVCaptureSession?
  var subscribers: [AnyCancellable] = []

  let poseChannel: ChannelID
  let cameraChannel: ChannelID
  let locationChannel: ChannelID

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

  @Published var sendLocation = false {
    didSet {
      if sendLocation {
        startLocationUpdates()
      } else {
        stopLocationUpdates()
      }
    }
  }

  @Published var activeCamera: Camera = .back {
    didSet {
      print("set active camera \(activeCamera)")
      reconfigureSession()
    }
  }
  @Published var sendGPS = false
  @Published var sendCPU = false
  @Published var sendMemory = false

  @Published var port: NWEndpoint.Port?
  var clientEndpointNames: [String] {
    print(server.clientEndpointNames)
    return server.clientEndpointNames
  }

  override init() {
    poseChannel = server.addChannel(topic: "pose", encoding: "json", schemaName: "foxglove.PoseInFrame", schema: poseInFrameSchema)
    cameraChannel = server.addChannel(topic: "camera", encoding: "protobuf", schemaName: Foxglove_CompressedImage.protoMessageName, schema: try! Data(contentsOf: Bundle.main.url(forResource: "CompressedImage", withExtension: "bin")!).base64EncodedString())
    locationChannel = server.addChannel(topic: "gps", encoding: "protobuf", schemaName: Foxglove_LocationFix.protoMessageName, schema: try! Data(contentsOf: Bundle.main.url(forResource: "LocationFix", withExtension: "bin")!).base64EncodedString())
    super.init()
    server.$port.assign(to: \.port, on: self).store(in: &subscribers)
    server.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }.store(in: &subscribers)
    startPoseUpdates()
  }


  func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
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
    print("got location authorization: \(CLLocationManager.authorizationStatus())")
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
    let img = UIImage(ciImage: CIImage(cvImageBuffer: imageBuffer))
    guard let jpeg = img.jpegData(compressionQuality: 0.8) else {
      print("failed to compress jpeg :(")
      return
    }

    var protoImg = Foxglove_CompressedImage()
    protoImg.timestamp = .init(date: .now)
    protoImg.frameID = "camera"
    protoImg.format = "jpeg"
    protoImg.data = jpeg

    let serializedProto = try! protoImg.serializedData()

    Task { @MainActor in
      server.sendMessage(on: cameraChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: serializedProto)
    }
  }

  nonisolated func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    Task { @MainActor in
      self.droppedVideoFrames += 1
    }
  }
}
