import AVFoundation
import Combine
import CoreImage
import UIKit
import VideoToolbox

enum Camera: CaseIterable, Identifiable, CustomStringConvertible {
  case back
  case front

  var description: String {
    switch self {
    case .back:
      return "Back"
    case .front:
      return "Front"
    }
  }

  var id: Self {
    self
  }
}

enum CompressionMode: Int32, CaseIterable, Identifiable, CustomStringConvertible {
  case JPEG
  case H264
  case H265

  var description: String {
    switch self {
    case .JPEG: return "JPEG"
    case .H264: return "H.264"
    case .H265: return "H.265"
    }
  }

  var id: Int32 {
    rawValue
  }
}

enum CameraError: Error {
  case noCameraDevice
  case unknownSize
}

enum VideoError: Error {
  case failedToGetParameterSetCount
  case failedToGetParameterSet(index: Int)
}

private func configureInputs(in session: AVCaptureSession, for camera: Camera) throws {
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
    throw CameraError.noCameraDevice
  }

  do {
    let input = try AVCaptureDeviceInput(device: device)
    print("ranges: \(input.device.activeFormat.videoSupportedFrameRateRanges)")
    session.addInput(input)
  } catch {
    print("failed to create device input: \(error)")
  }
}

struct CalibrationData {
  var intrinsicMatrix: matrix_float3x3
  var width: Int
  var height: Int
}

class CameraManager: NSObject, ObservableObject {
  private let queue = DispatchQueue(label: "CameraManager")
  private var captureSession: AVCaptureSession?
  private var compressionSession: VTCompressionSession?
  private var videoOutput: AVCaptureVideoDataOutput?
  private var forceKeyFrame = true

  let h264Frames = PassthroughSubject<Data, Never>()
  let h265Frames = PassthroughSubject<Data, Never>()
  let jpegFrames = PassthroughSubject<Data, Never>()
  let calibrationData = PassthroughSubject<CalibrationData, Never>()

  @Published var currentError: Error?

  @Published var droppedFrames = 0

  @Published var activeCamera: Camera = .back {
    didSet {
      print("set active camera \(activeCamera)")
      reconfigureSession()
    }
  }

  private var _compressionMode: Int32 = CompressionMode.JPEG.rawValue
  public var compressionMode: CompressionMode {
    get {
      CompressionMode(rawValue: _compressionMode)!
    }
    set {
      repeat {} while !OSAtomicCompareAndSwap32(_compressionMode, newValue.rawValue, &_compressionMode)

      reconfigureSession()
    }
  }

  override init() {
    super.init()
  }

  @MainActor
  func startCameraUpdates() {
    Task { @MainActor in
      droppedFrames = 0
    }
    let activeCamera = activeCamera

    queue.async { [self] in
      let captureSession = AVCaptureSession()

      do {
        try configureInputs(in: captureSession, for: activeCamera)
      } catch {
        print("error starting session: \(error)")
        Task { @MainActor in
          currentError = error
        }
        return
      }
      captureSession.sessionPreset = compressionMode == .JPEG ? .medium : .high

      let output = AVCaptureVideoDataOutput()
      output.setSampleBufferDelegate(self, queue: queue)
      captureSession.addOutput(output)
      if let connection = output.connection(with: .video) {
        print("intrinsic supported: \(connection.isCameraIntrinsicMatrixDeliverySupported)")
        if connection.isCameraIntrinsicMatrixDeliverySupported {
          connection.isCameraIntrinsicMatrixDeliveryEnabled = true
        }
      }
      videoOutput = output

      if compressionMode != .JPEG {
        do {
          try createCompressionSession(for: output)
        } catch let err {
          Task { @MainActor in
            currentError = err
          }
          return
        }
      }
      Task { @MainActor in
        currentError = nil
      }

      captureSession.startRunning()
      self.captureSession = captureSession
    }
  }

  @MainActor
  func stopCameraUpdates() {
    queue.async(qos: .userInitiated) { [self] in
      captureSession?.stopRunning()
    }
  }

  private func createCompressionSession(for output: AVCaptureVideoDataOutput) throws {
    let mode = compressionMode

    let codecType: CMVideoCodecType
    let profileLevel: CFString

    switch mode {
    case .JPEG:
      preconditionFailure("Expected video compression, not JPEG")
    case .H264:
      codecType = kCMVideoCodecType_H264
      profileLevel = kVTProfileLevel_H264_Main_AutoLevel
    case .H265:
      codecType = kCMVideoCodecType_HEVC
      profileLevel = kVTProfileLevel_HEVC_Main_AutoLevel
    }

    if let compressionSession {
      VTCompressionSessionInvalidate(compressionSession)
      self.compressionSession = nil
    }

    guard let width = output.videoSettings[kCVPixelBufferWidthKey as String] as? Int32,
          let height = output.videoSettings[kCVPixelBufferHeightKey as String] as? Int32
    else {
      throw CameraError.unknownSize
    }

    var err: OSStatus

    err = VTCompressionSessionCreate(
      allocator: kCFAllocatorDefault,
      width: width,
      height: height,
      codecType: codecType,
      encoderSpecification: [
        kVTVideoEncoderSpecification_EnableLowLatencyRateControl: kCFBooleanTrue,
      ] as CFDictionary,
      imageBufferAttributes: nil,
      compressedDataAllocator: nil,
      outputCallback: nil,
      refcon: nil,
      compressionSessionOut: &compressionSession
    )
    guard err == noErr, let compressionSession else {
      print("VTCompressionSessionCreate failed (\(err))")
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(err))
    }

    err = VTSessionSetProperty(
      compressionSession,
      key: kVTCompressionPropertyKey_ProfileLevel,
      value: profileLevel
    )
    guard err == noErr else {
      print("VTSessionSetProperty(kVTCompressionPropertyKey_ProfileLevel) failed (\(err))")
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(err))
    }

    // Indicate that the compression session is in real time, which streaming
    // requires.
    err = VTSessionSetProperty(compressionSession, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
    guard err == noErr else {
      print("VTSessionSetProperty(kVTCompressionPropertyKey_RealTime) failed (\(err))")
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(err))
    }
    // Enables temporal compression.
    err = VTSessionSetProperty(
      compressionSession,
      key: kVTCompressionPropertyKey_AllowTemporalCompression,
      value: kCFBooleanTrue
    )
    guard err == noErr else {
      print("Warning: VTSessionSetProperty(kVTCompressionPropertyKey_AllowTemporalCompression) failed (\(err))")
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(err))
    }

    // Disable frame reordering
    err = VTSessionSetProperty(
      compressionSession,
      key: kVTCompressionPropertyKey_AllowFrameReordering,
      value: kCFBooleanFalse
    )
    guard err == noErr else {
      print("Warning: VTSessionSetProperty(kVTCompressionPropertyKey_AllowFrameReordering) failed (\(err))")
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(err))
    }

    // Require key frames every 2 seconds
    err = VTSessionSetProperty(
      compressionSession,
      key: kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration,
      value: 2 as CFNumber
    )
    guard err == noErr else {
      print("Warning: VTSessionSetProperty(kVTCompressionPropertyKey_MaxKeyFrameIntervalDuration) failed (\(err))")
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(err))
    }
  }

  private func reconfigureSession() {
    let activeCamera = activeCamera

    queue.async(qos: .userInitiated) { [self] in
      guard let session = captureSession else {
        return
      }
      print("changing session")
      session.beginConfiguration()
      do {
        try configureInputs(in: session, for: activeCamera)
      } catch {
        print("error changing session: \(error)")
      }
      session.sessionPreset = compressionMode == .JPEG ? .medium : .high
      session.commitConfiguration()
      if compressionMode != .JPEG, let videoOutput {
        do {
          try createCompressionSession(for: videoOutput)
        } catch let err {
          Task { @MainActor in
            currentError = err
          }
          return
        }
      }
      forceKeyFrame = true
    }
  }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
    guard let imageBuffer = sampleBuffer.imageBuffer else {
      print("no image buffer :(")
      return
    }

    if let matrixData = sampleBuffer.attachments[.cameraIntrinsicMatrix]?.value as? Data,
       matrixData.count == MemoryLayout<matrix_float3x3>.size
    {
      let matrix = matrixData.withUnsafeBytes { $0.load(as: matrix_float3x3.self) }
      let width = CVPixelBufferGetWidth(imageBuffer)
      let height = CVPixelBufferGetHeight(imageBuffer)
      Task { @MainActor in
        calibrationData.send(CalibrationData(intrinsicMatrix: matrix, width: width, height: height))
      }
    }

    let mode = compressionMode

    let outputSubject: PassthroughSubject<Data, Never>
    switch mode {
    case .JPEG:
      let img = UIImage(ciImage: CIImage(cvImageBuffer: imageBuffer))
      guard let jpeg = img.jpegData(compressionQuality: 0.8) else {
        print("failed to compress jpeg :(")
        return
      }
      Task { @MainActor in
        jpegFrames.send(jpeg)
      }
      return

    case .H264:
      outputSubject = h264Frames
    case .H265:
      outputSubject = h265Frames
    }

    guard let compressionSession else {
      print("no compression session")
      return
    }

    var err: OSStatus

    err = VTCompressionSessionEncodeFrame(
      compressionSession,
      imageBuffer: imageBuffer,
      presentationTimeStamp: sampleBuffer.presentationTimeStamp,
      duration: .invalid,
      frameProperties: [
        kVTEncodeFrameOptionKey_ForceKeyFrame: forceKeyFrame ? kCFBooleanTrue : kCFBooleanFalse,
      ] as CFDictionary,
      infoFlagsOut: nil
    ) { [self] status, infoFlags, sampleBuffer in
      queue.async(qos: .userInteractive) { [self] in
        if infoFlags.contains(.frameDropped) {
          print("Encoder dropped the frame with status \(status)")
          return
        }

        guard status == noErr else {
          forceKeyFrame = true
          print("Encoder returned an error for frame with \(status)")
          Task { @MainActor in
            self.droppedFrames += 1
          }
          return
        }
        guard let sampleBuffer else {
          print("Encoder returned an unexpected NULL sampleBuffer for frame")
          return
        }

        guard let annexBData = sampleBuffer.dataBufferAsAnnexB(compressionMode: mode) else {
          print("Unable to translate to Annex B format")
          forceKeyFrame = true
          return
        }

        forceKeyFrame = false
        Task { @MainActor in
          outputSubject.send(annexBData)
        }
      }
    }

    guard err == noErr else {
      forceKeyFrame = true
      print("Encode call failed: \(err) \(NSError(domain: NSOSStatusErrorDomain, code: Int(err)))")

      // When the app is backgrounded and comes back to the foreground,
      // the compression session becomes invalid, so we recreate it
      if err == kVTInvalidSessionErr, let videoOutput {
        print("invalid compression session, recreating")
        do {
          try createCompressionSession(for: videoOutput)
        } catch let err {
          Task { @MainActor [err] in
            self.droppedFrames += 1
            self.currentError = err
          }
          return
        }
      }
      Task { @MainActor [err] in
        self.droppedFrames += 1
        self.currentError = NSError(domain: NSOSStatusErrorDomain, code: Int(err))
      }
      return
    }

    Task { @MainActor in
      if currentError != nil {
        currentError = nil
      }
    }
  }

  func captureOutput(_: AVCaptureOutput, didDrop _: CMSampleBuffer, from _: AVCaptureConnection) {
    Task { @MainActor in
      droppedFrames += 1
    }
  }
}

extension CMSampleBuffer {
  /// Convert a CMSampleBuffer holding a CMBlockBuffer in AVCC format into Annex B format.
  func dataBufferAsAnnexB(compressionMode: CompressionMode) -> Data? {
    guard let dataBuffer, let formatDescription else {
      return nil
    }

    do {
      var result = Data()
      let startCode = Data([0x00, 0x00, 0x00, 0x01])

      switch compressionMode {
      case .JPEG:
        preconditionFailure("Expected H264 or H265 compression mode")
      case .H264:
        try formatDescription.forEachParameterSetH264 { buf in
          result.append(startCode)
          result.append(buf)
        }
      case .H265:
        try formatDescription.forEachParameterSetH265 { buf in
          result.append(startCode)
          result.append(buf)
        }
      }

      try dataBuffer.withContiguousStorage { rawBuffer in
        // Since the startCode is 4 bytes, we can append the whole AVCC buffer to the output,
        // and then replace the 4-byte length values with start codes.
        var offset = result.count
        result.append(rawBuffer.assumingMemoryBound(to: UInt8.self))
        result.withUnsafeMutableBytes { resultBuffer in
          while offset + 4 < resultBuffer.count {
            let nalUnitLength = Int(UInt32(bigEndian: resultBuffer.loadUnaligned(
              fromByteOffset: offset,
              as: UInt32.self
            )))
            UnsafeMutableRawBufferPointer(rebasing: resultBuffer[offset ..< offset + 4]).copyBytes(from: startCode)
            offset += 4 + nalUnitLength
          }
        }
      }

      return result
    } catch let err {
      print("Error converting to Annex B: \(err)")
      return nil
    }
  }
}

extension CMFormatDescription {
  func forEachParameterSetH264(_ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
    var parameterSetCount = 0
    var status = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(
      self,
      parameterSetIndex: 0,
      parameterSetPointerOut: nil,
      parameterSetSizeOut: nil,
      parameterSetCountOut: &parameterSetCount,
      nalUnitHeaderLengthOut: nil
    )
    guard noErr == status else {
      throw VideoError.failedToGetParameterSetCount
    }

    for idx in 0 ..< parameterSetCount {
      var ptr: UnsafePointer<UInt8>?
      var size = 0
      status = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(
        self,
        parameterSetIndex: idx,
        parameterSetPointerOut: &ptr,
        parameterSetSizeOut: &size,
        parameterSetCountOut: nil,
        nalUnitHeaderLengthOut: nil
      )
      guard noErr == status else {
        throw VideoError.failedToGetParameterSet(index: idx)
      }
      callback(UnsafeBufferPointer(start: ptr, count: size))
    }
  }

  func forEachParameterSetH265(_ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
    var parameterSetCount = 0
    var status = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(
      self,
      parameterSetIndex: 0,
      parameterSetPointerOut: nil,
      parameterSetSizeOut: nil,
      parameterSetCountOut: &parameterSetCount,
      nalUnitHeaderLengthOut: nil
    )
    guard noErr == status else {
      throw VideoError.failedToGetParameterSetCount
    }

    for idx in 0 ..< parameterSetCount {
      var ptr: UnsafePointer<UInt8>?
      var size = 0
      status = CMVideoFormatDescriptionGetHEVCParameterSetAtIndex(
        self,
        parameterSetIndex: idx,
        parameterSetPointerOut: &ptr,
        parameterSetSizeOut: &size,
        parameterSetCountOut: nil,
        nalUnitHeaderLengthOut: nil
      )
      guard noErr == status else {
        throw VideoError.failedToGetParameterSet(index: idx)
      }
      callback(UnsafeBufferPointer(start: ptr, count: size))
    }
  }
}
