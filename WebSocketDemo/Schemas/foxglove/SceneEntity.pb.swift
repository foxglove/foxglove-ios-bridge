// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/SceneEntity.proto
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

/// A visual element in a 3D scene. An entity may be composed of multiple primitives which all share the same frame of reference.
struct Foxglove_SceneEntity {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Timestamp of the entity
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

  /// Identifier for the entity. A entity will replace any prior entity on the same topic with the same `id`.
  var id: String = String()

  /// Length of time (relative to `timestamp`) after which the entity should be automatically removed. Zero value indicates the entity should remain visible until it is replaced or deleted.
  var lifetime: SwiftProtobuf.Google_Protobuf_Duration {
    get {return _lifetime ?? SwiftProtobuf.Google_Protobuf_Duration()}
    set {_lifetime = newValue}
  }
  /// Returns true if `lifetime` has been explicitly set.
  var hasLifetime: Bool {return self._lifetime != nil}
  /// Clears the value of `lifetime`. Subsequent reads from it will return its default value.
  mutating func clearLifetime() {self._lifetime = nil}

  /// Whether the entity should keep its location in the fixed frame (false) or follow the frame specified in `frame_id` as it moves relative to the fixed frame (true)
  var frameLocked: Bool = false

  /// Additional user-provided metadata associated with the entity. Keys must be unique.
  var metadata: [Foxglove_KeyValuePair] = []

  /// Arrow primitives
  var arrows: [Foxglove_ArrowPrimitive] = []

  /// Cube primitives
  var cubes: [Foxglove_CubePrimitive] = []

  /// Sphere primitives
  var spheres: [Foxglove_SpherePrimitive] = []

  /// Cylinder primitives
  var cylinders: [Foxglove_CylinderPrimitive] = []

  /// Line primitives
  var lines: [Foxglove_LinePrimitive] = []

  /// Triangle list primitives
  var triangles: [Foxglove_TriangleListPrimitive] = []

  /// Text primitives
  var texts: [Foxglove_TextPrimitive] = []

  /// Model primitives
  var models: [Foxglove_ModelPrimitive] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
  fileprivate var _lifetime: SwiftProtobuf.Google_Protobuf_Duration? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Foxglove_SceneEntity: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "foxglove"

extension Foxglove_SceneEntity: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".SceneEntity"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .standard(proto: "frame_id"),
    3: .same(proto: "id"),
    4: .same(proto: "lifetime"),
    5: .standard(proto: "frame_locked"),
    6: .same(proto: "metadata"),
    7: .same(proto: "arrows"),
    8: .same(proto: "cubes"),
    9: .same(proto: "spheres"),
    10: .same(proto: "cylinders"),
    11: .same(proto: "lines"),
    12: .same(proto: "triangles"),
    13: .same(proto: "texts"),
    14: .same(proto: "models"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.frameID) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.id) }()
      case 4: try { try decoder.decodeSingularMessageField(value: &self._lifetime) }()
      case 5: try { try decoder.decodeSingularBoolField(value: &self.frameLocked) }()
      case 6: try { try decoder.decodeRepeatedMessageField(value: &self.metadata) }()
      case 7: try { try decoder.decodeRepeatedMessageField(value: &self.arrows) }()
      case 8: try { try decoder.decodeRepeatedMessageField(value: &self.cubes) }()
      case 9: try { try decoder.decodeRepeatedMessageField(value: &self.spheres) }()
      case 10: try { try decoder.decodeRepeatedMessageField(value: &self.cylinders) }()
      case 11: try { try decoder.decodeRepeatedMessageField(value: &self.lines) }()
      case 12: try { try decoder.decodeRepeatedMessageField(value: &self.triangles) }()
      case 13: try { try decoder.decodeRepeatedMessageField(value: &self.texts) }()
      case 14: try { try decoder.decodeRepeatedMessageField(value: &self.models) }()
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
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 3)
    }
    try { if let v = self._lifetime {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    if self.frameLocked != false {
      try visitor.visitSingularBoolField(value: self.frameLocked, fieldNumber: 5)
    }
    if !self.metadata.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.metadata, fieldNumber: 6)
    }
    if !self.arrows.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.arrows, fieldNumber: 7)
    }
    if !self.cubes.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.cubes, fieldNumber: 8)
    }
    if !self.spheres.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.spheres, fieldNumber: 9)
    }
    if !self.cylinders.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.cylinders, fieldNumber: 10)
    }
    if !self.lines.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.lines, fieldNumber: 11)
    }
    if !self.triangles.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.triangles, fieldNumber: 12)
    }
    if !self.texts.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.texts, fieldNumber: 13)
    }
    if !self.models.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.models, fieldNumber: 14)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Foxglove_SceneEntity, rhs: Foxglove_SceneEntity) -> Bool {
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs.frameID != rhs.frameID {return false}
    if lhs.id != rhs.id {return false}
    if lhs._lifetime != rhs._lifetime {return false}
    if lhs.frameLocked != rhs.frameLocked {return false}
    if lhs.metadata != rhs.metadata {return false}
    if lhs.arrows != rhs.arrows {return false}
    if lhs.cubes != rhs.cubes {return false}
    if lhs.spheres != rhs.spheres {return false}
    if lhs.cylinders != rhs.cylinders {return false}
    if lhs.lines != rhs.lines {return false}
    if lhs.triangles != rhs.triangles {return false}
    if lhs.texts != rhs.texts {return false}
    if lhs.models != rhs.models {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}