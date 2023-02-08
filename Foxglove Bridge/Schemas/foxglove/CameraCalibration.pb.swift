// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/CameraCalibration.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Generated by https://github.com/foxglove/schemas

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// Camera calibration parameters
struct Foxglove_CameraCalibration {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Timestamp of calibration data
  var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_timestamp = newValue}
  }
  /// Returns true if `timestamp` has been explicitly set.
  var hasTimestamp: Bool {return self._timestamp != nil}
  /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
  mutating func clearTimestamp() {self._timestamp = nil}

  /// Frame of reference for the camera. The origin of the frame is the optical center of the camera. +x points to the right in the image, +y points down, and +z points into the plane of the image.
  var frameID: String = String()

  /// Image width
  var width: UInt32 = 0

  /// Image height
  var height: UInt32 = 0

  /// Name of distortion model
  /// 
  /// Supported values: `plumb_bob` and `rational_polynomial`
  var distortionModel: String = String()

  /// Distortion parameters
  var d: [Double] = []

  /// Intrinsic camera matrix (3x3 row-major matrix)
  /// 
  /// A 3x3 row-major matrix for the raw (distorted) image.
  /// 
  /// Projects 3D points in the camera coordinate frame to 2D pixel coordinates using the focal lengths (fx, fy) and principal point (cx, cy).
  /// 
  /// ```
  ///     [fx  0 cx]
  /// K = [ 0 fy cy]
  ///     [ 0  0  1]
  /// ```
  var k: [Double] = []

  /// Rectification matrix (stereo cameras only, 3x3 row-major matrix)
  /// 
  /// A rotation matrix aligning the camera coordinate system to the ideal stereo image plane so that epipolar lines in both stereo images are parallel.
  var r: [Double] = []

  /// Projection/camera matrix (3x4 row-major matrix)
  /// 
  /// ```
  ///     [fx'  0  cx' Tx]
  /// P = [ 0  fy' cy' Ty]
  ///     [ 0   0   1   0]
  /// ```
  /// 
  /// By convention, this matrix specifies the intrinsic (camera) matrix of the processed (rectified) image. That is, the left 3x3 portion is the normal camera intrinsic matrix for the rectified image.
  /// 
  /// It projects 3D points in the camera coordinate frame to 2D pixel coordinates using the focal lengths (fx', fy') and principal point (cx', cy') - these may differ from the values in K.
  /// 
  /// For monocular cameras, Tx = Ty = 0. Normally, monocular cameras will also have R = the identity and P[1:3,1:3] = K.
  /// 
  /// For a stereo pair, the fourth column [Tx Ty 0]' is related to the position of the optical center of the second camera in the first camera's frame. We assume Tz = 0 so both cameras are in the same stereo image plane. The first camera always has Tx = Ty = 0. For the right (second) camera of a horizontal stereo pair, Ty = 0 and Tx = -fx' * B, where B is the baseline between the cameras.
  /// 
  /// Given a 3D point [X Y Z]', the projection (x, y) of the point onto the rectified image is given by:
  /// 
  /// ```
  /// [u v w]' = P * [X Y Z 1]'
  ///        x = u / w
  ///        y = v / w
  /// ```
  /// 
  /// This holds for both images of a stereo pair.
  var p: [Double] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Foxglove_CameraCalibration: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "foxglove"

extension Foxglove_CameraCalibration: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".CameraCalibration"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    9: .standard(proto: "frame_id"),
    2: .same(proto: "width"),
    3: .same(proto: "height"),
    4: .standard(proto: "distortion_model"),
    5: .same(proto: "D"),
    6: .same(proto: "K"),
    7: .same(proto: "R"),
    8: .same(proto: "P"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      case 2: try { try decoder.decodeSingularFixed32Field(value: &self.width) }()
      case 3: try { try decoder.decodeSingularFixed32Field(value: &self.height) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.distortionModel) }()
      case 5: try { try decoder.decodeRepeatedDoubleField(value: &self.d) }()
      case 6: try { try decoder.decodeRepeatedDoubleField(value: &self.k) }()
      case 7: try { try decoder.decodeRepeatedDoubleField(value: &self.r) }()
      case 8: try { try decoder.decodeRepeatedDoubleField(value: &self.p) }()
      case 9: try { try decoder.decodeSingularStringField(value: &self.frameID) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._timestamp {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if self.width != 0 {
      try visitor.visitSingularFixed32Field(value: self.width, fieldNumber: 2)
    }
    if self.height != 0 {
      try visitor.visitSingularFixed32Field(value: self.height, fieldNumber: 3)
    }
    if !self.distortionModel.isEmpty {
      try visitor.visitSingularStringField(value: self.distortionModel, fieldNumber: 4)
    }
    if !self.d.isEmpty {
      try visitor.visitPackedDoubleField(value: self.d, fieldNumber: 5)
    }
    if !self.k.isEmpty {
      try visitor.visitPackedDoubleField(value: self.k, fieldNumber: 6)
    }
    if !self.r.isEmpty {
      try visitor.visitPackedDoubleField(value: self.r, fieldNumber: 7)
    }
    if !self.p.isEmpty {
      try visitor.visitPackedDoubleField(value: self.p, fieldNumber: 8)
    }
    if !self.frameID.isEmpty {
      try visitor.visitSingularStringField(value: self.frameID, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Foxglove_CameraCalibration, rhs: Foxglove_CameraCalibration) -> Bool {
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs.frameID != rhs.frameID {return false}
    if lhs.width != rhs.width {return false}
    if lhs.height != rhs.height {return false}
    if lhs.distortionModel != rhs.distortionModel {return false}
    if lhs.d != rhs.d {return false}
    if lhs.k != rhs.k {return false}
    if lhs.r != rhs.r {return false}
    if lhs.p != rhs.p {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
