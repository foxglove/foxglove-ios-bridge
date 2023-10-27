// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/CubePrimitive.proto
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
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// A primitive representing a cube or rectangular prism
struct Foxglove_CubePrimitive {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Position of the center of the cube and orientation of the cube
  var pose: Foxglove_Pose {
    get { _pose ?? Foxglove_Pose() }
    set { _pose = newValue }
  }

  /// Returns true if `pose` has been explicitly set.
  var hasPose: Bool { _pose != nil }
  /// Clears the value of `pose`. Subsequent reads from it will return its default value.
  mutating func clearPose() { _pose = nil }

  /// Size of the cube along each axis
  var size: Foxglove_Vector3 {
    get { _size ?? Foxglove_Vector3() }
    set { _size = newValue }
  }

  /// Returns true if `size` has been explicitly set.
  var hasSize: Bool { _size != nil }
  /// Clears the value of `size`. Subsequent reads from it will return its default value.
  mutating func clearSize() { _size = nil }

  /// Color of the cube
  var color: Foxglove_Color {
    get { _color ?? Foxglove_Color() }
    set { _color = newValue }
  }

  /// Returns true if `color` has been explicitly set.
  var hasColor: Bool { _color != nil }
  /// Clears the value of `color`. Subsequent reads from it will return its default value.
  mutating func clearColor() { _color = nil }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  private var _pose: Foxglove_Pose?
  private var _size: Foxglove_Vector3?
  private var _color: Foxglove_Color?
}

#if swift(>=5.5) && canImport(_Concurrency)
  extension Foxglove_CubePrimitive: @unchecked Sendable {}
#endif // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "foxglove"

extension Foxglove_CubePrimitive: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase,
  SwiftProtobuf._ProtoNameProviding
{
  static let protoMessageName: String = _protobuf_package + ".CubePrimitive"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "pose"),
    2: .same(proto: "size"),
    3: .same(proto: "color"),
  ]

  mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &_pose)
      case 2: try decoder.decodeSingularMessageField(value: &_size)
      case 3: try decoder.decodeSingularMessageField(value: &_color)
      default: break
      }
    }
  }

  func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if let v = _pose {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    try { if let v = self._size {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._color {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func == (lhs: Foxglove_CubePrimitive, rhs: Foxglove_CubePrimitive) -> Bool {
    if lhs._pose != rhs._pose { return false }
    if lhs._size != rhs._size { return false }
    if lhs._color != rhs._color { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
