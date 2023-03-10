// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/Pose.proto
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

/// A position and orientation for an object or reference frame in 3D space
struct Foxglove_Pose {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Point denoting position in 3D space
  var position: Foxglove_Vector3 {
    get {return _position ?? Foxglove_Vector3()}
    set {_position = newValue}
  }
  /// Returns true if `position` has been explicitly set.
  var hasPosition: Bool {return self._position != nil}
  /// Clears the value of `position`. Subsequent reads from it will return its default value.
  mutating func clearPosition() {self._position = nil}

  /// Quaternion denoting orientation in 3D space
  var orientation: Foxglove_Quaternion {
    get {return _orientation ?? Foxglove_Quaternion()}
    set {_orientation = newValue}
  }
  /// Returns true if `orientation` has been explicitly set.
  var hasOrientation: Bool {return self._orientation != nil}
  /// Clears the value of `orientation`. Subsequent reads from it will return its default value.
  mutating func clearOrientation() {self._orientation = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _position: Foxglove_Vector3? = nil
  fileprivate var _orientation: Foxglove_Quaternion? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Foxglove_Pose: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "foxglove"

extension Foxglove_Pose: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Pose"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "position"),
    2: .same(proto: "orientation"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._position) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._orientation) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._position {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._orientation {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Foxglove_Pose, rhs: Foxglove_Pose) -> Bool {
    if lhs._position != rhs._position {return false}
    if lhs._orientation != rhs._orientation {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
