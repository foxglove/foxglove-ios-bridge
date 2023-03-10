// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/ArrowPrimitive.proto
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

/// A primitive representing an arrow
struct Foxglove_ArrowPrimitive {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Position of the arrow's tail and orientation of the arrow. Identity orientation means the arrow points in the +x direction.
  var pose: Foxglove_Pose {
    get {return _pose ?? Foxglove_Pose()}
    set {_pose = newValue}
  }
  /// Returns true if `pose` has been explicitly set.
  var hasPose: Bool {return self._pose != nil}
  /// Clears the value of `pose`. Subsequent reads from it will return its default value.
  mutating func clearPose() {self._pose = nil}

  /// Length of the arrow shaft
  var shaftLength: Double = 0

  /// Diameter of the arrow shaft
  var shaftDiameter: Double = 0

  /// Length of the arrow head
  var headLength: Double = 0

  /// Diameter of the arrow head
  var headDiameter: Double = 0

  /// Color of the arrow
  var color: Foxglove_Color {
    get {return _color ?? Foxglove_Color()}
    set {_color = newValue}
  }
  /// Returns true if `color` has been explicitly set.
  var hasColor: Bool {return self._color != nil}
  /// Clears the value of `color`. Subsequent reads from it will return its default value.
  mutating func clearColor() {self._color = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _pose: Foxglove_Pose? = nil
  fileprivate var _color: Foxglove_Color? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Foxglove_ArrowPrimitive: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "foxglove"

extension Foxglove_ArrowPrimitive: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ArrowPrimitive"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "pose"),
    2: .standard(proto: "shaft_length"),
    3: .standard(proto: "shaft_diameter"),
    4: .standard(proto: "head_length"),
    5: .standard(proto: "head_diameter"),
    6: .same(proto: "color"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._pose) }()
      case 2: try { try decoder.decodeSingularDoubleField(value: &self.shaftLength) }()
      case 3: try { try decoder.decodeSingularDoubleField(value: &self.shaftDiameter) }()
      case 4: try { try decoder.decodeSingularDoubleField(value: &self.headLength) }()
      case 5: try { try decoder.decodeSingularDoubleField(value: &self.headDiameter) }()
      case 6: try { try decoder.decodeSingularMessageField(value: &self._color) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._pose {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if self.shaftLength != 0 {
      try visitor.visitSingularDoubleField(value: self.shaftLength, fieldNumber: 2)
    }
    if self.shaftDiameter != 0 {
      try visitor.visitSingularDoubleField(value: self.shaftDiameter, fieldNumber: 3)
    }
    if self.headLength != 0 {
      try visitor.visitSingularDoubleField(value: self.headLength, fieldNumber: 4)
    }
    if self.headDiameter != 0 {
      try visitor.visitSingularDoubleField(value: self.headDiameter, fieldNumber: 5)
    }
    try { if let v = self._color {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Foxglove_ArrowPrimitive, rhs: Foxglove_ArrowPrimitive) -> Bool {
    if lhs._pose != rhs._pose {return false}
    if lhs.shaftLength != rhs.shaftLength {return false}
    if lhs.shaftDiameter != rhs.shaftDiameter {return false}
    if lhs.headLength != rhs.headLength {return false}
    if lhs.headDiameter != rhs.headDiameter {return false}
    if lhs._color != rhs._color {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
