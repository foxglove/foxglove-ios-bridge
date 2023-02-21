// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/PointCloud.proto
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

/// A collection of N-dimensional points, which may contain additional fields with information like normals, intensity, etc.
struct Foxglove_PointCloud {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Timestamp of point cloud
  var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_timestamp = newValue}
  }
  /// Returns true if `timestamp` has been explicitly set.
  var hasTimestamp: Bool {return self._timestamp != nil}
  /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
  mutating func clearTimestamp() {self._timestamp = nil}

  /// Frame of reference
  var frameID: String = String()

  /// The origin of the point cloud relative to the frame of reference
  var pose: Foxglove_Pose {
    get {return _pose ?? Foxglove_Pose()}
    set {_pose = newValue}
  }
  /// Returns true if `pose` has been explicitly set.
  var hasPose: Bool {return self._pose != nil}
  /// Clears the value of `pose`. Subsequent reads from it will return its default value.
  mutating func clearPose() {self._pose = nil}

  /// Number of bytes between points in the `data`
  var pointStride: UInt32 = 0

  /// Fields in the `data`
  var fields: [Foxglove_PackedElementField] = []

  /// Point data, interpreted using `fields`
  var data: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
  fileprivate var _pose: Foxglove_Pose? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Foxglove_PointCloud: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "foxglove"

extension Foxglove_PointCloud: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".PointCloud"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .standard(proto: "frame_id"),
    3: .same(proto: "pose"),
    4: .standard(proto: "point_stride"),
    5: .same(proto: "fields"),
    6: .same(proto: "data"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.frameID) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._pose) }()
      case 4: try { try decoder.decodeSingularFixed32Field(value: &self.pointStride) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.fields) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.data) }()
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
    if !self.frameID.isEmpty {
      try visitor.visitSingularStringField(value: self.frameID, fieldNumber: 2)
    }
    try { if let v = self._pose {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if self.pointStride != 0 {
      try visitor.visitSingularFixed32Field(value: self.pointStride, fieldNumber: 4)
    }
    if !self.fields.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.fields, fieldNumber: 5)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Foxglove_PointCloud, rhs: Foxglove_PointCloud) -> Bool {
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs.frameID != rhs.frameID {return false}
    if lhs._pose != rhs._pose {return false}
    if lhs.pointStride != rhs.pointStride {return false}
    if lhs.fields != rhs.fields {return false}
    if lhs.data != rhs.data {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}