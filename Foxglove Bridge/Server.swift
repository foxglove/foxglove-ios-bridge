import SwiftUI
import CoreMotion
import AVFoundation
import Combine
import Network

@MainActor
class Server: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  let videoQueue = DispatchQueue(label: "VideoQueue")
  let address = getIPAddress() ?? "<no address>"

  let server = FoxgloveServer()

  let motionManager = CMMotionManager()
  var captureSession: AVCaptureSession?
  var subscribers: [AnyCancellable] = []

  let poseChannel: ChannelID
  let cameraChannel: ChannelID

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

  @Published var sendRearCamera = false {
    didSet {
      if sendRearCamera {
        startCameraUpdates()
      } else {
        stopCameraUpdates()
      }
    }
  }

  @Published var port: NWEndpoint.Port?
  var clientEndpointNames: [String] {
    print(server.clientEndpointNames)
    return server.clientEndpointNames
  }

  override init() {
    poseChannel = server.addChannel(topic: "pose", encoding: "json", schemaName: "foxglove.PoseInFrame", schema: poseInFrameSchema)
    cameraChannel = server.addChannel(topic: "camera", encoding: "protobuf", schemaName: Foxglove_CompressedImage.protoMessageName, schema: try! Data(contentsOf: Bundle.main.url(forResource: "CompressedImage", withExtension: "bin")!).base64EncodedString())
    super.init()
    server.$port.assign(to: \.port, on: self).store(in: &subscribers)
    server.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }.store(in: &subscribers)
    startPoseUpdates()
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
    
    videoQueue.async {
      let session = AVCaptureSession()
      guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
        print("no camera device")
        return
      }
      do {
        let input = try AVCaptureDeviceInput(device: device)
        print("ranges: \(input.device.activeFormat.videoSupportedFrameRateRanges)")
        session.addInput(input)
        session.sessionPreset = .medium
//        input.videoMinFrameDurationOverride = CMTime(seconds: 0.1, preferredTimescale: 30)
      } catch let error {
        print("failed to create device input: \(error)")
        return
      }
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
