// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/LinePrimitive.proto
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

/// A primitive representing a series of points connected by lines
struct Foxglove_LinePrimitive {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Drawing primitive to use for lines
  var type: Foxglove_LinePrimitive.TypeEnum {
    get { _storage._type }
    set { _uniqueStorage()._type = newValue }
  }

  /// Origin of lines relative to reference frame
  var pose: Foxglove_Pose {
    get { _storage._pose ?? Foxglove_Pose() }
    set { _uniqueStorage()._pose = newValue }
  }

  /// Returns true if `pose` has been explicitly set.
  var hasPose: Bool { _storage._pose != nil }
  /// Clears the value of `pose`. Subsequent reads from it will return its default value.
  mutating func clearPose() { _uniqueStorage()._pose = nil }

  /// Line thickness
  var thickness: Double {
    get { _storage._thickness }
    set { _uniqueStorage()._thickness = newValue }
  }

  /// Indicates whether `thickness` is a fixed size in screen pixels (true), or specified in world coordinates and
  /// scales with distance from the camera (false)
  var scaleInvariant: Bool {
    get { _storage._scaleInvariant }
    set { _uniqueStorage()._scaleInvariant = newValue }
  }

  /// Points along the line
  var points: [Foxglove_Point3] {
    get { _storage._points }
    set { _uniqueStorage()._points = newValue }
  }

  /// Solid color to use for the whole line. One of `color` or `colors` must be provided.
  var color: Foxglove_Color {
    get { _storage._color ?? Foxglove_Color() }
    set { _uniqueStorage()._color = newValue }
  }

  /// Returns true if `color` has been explicitly set.
  var hasColor: Bool { _storage._color != nil }
  /// Clears the value of `color`. Subsequent reads from it will return its default value.
  mutating func clearColor() { _uniqueStorage()._color = nil }

  /// Per-point colors (if specified, must have the same length as `points`). One of `color` or `colors` must be
  /// provided.
  var colors: [Foxglove_Color] {
    get { _storage._colors }
    set { _uniqueStorage()._colors = newValue }
  }

  /// Indices into the `points` and `colors` attribute arrays, which can be used to avoid duplicating attribute data.
  ///
  /// If omitted or empty, indexing will not be used. This default behavior is equivalent to specifying [0, 1, ..., N-1]
  /// for the indices (where N is the number of `points` provided).
  var indices: [UInt32] {
    get { _storage._indices }
    set { _uniqueStorage()._indices = newValue }
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  /// An enumeration indicating how input points should be interpreted to create lines
  enum TypeEnum: SwiftProtobuf.Enum {
    typealias RawValue = Int

    /// Connected line segments: 0-1, 1-2, ..., (n-1)-n
    case lineStrip // = 0

    /// Closed polygon: 0-1, 1-2, ..., (n-1)-n, n-0
    case lineLoop // = 1

    /// Individual line segments: 0-1, 2-3, 4-5, ...
    case lineList // = 2
    case UNRECOGNIZED(Int)

    init() {
      self = .lineStrip
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .lineStrip
      case 1: self = .lineLoop
      case 2: self = .lineList
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .lineStrip: 0
      case .lineLoop: 1
      case .lineList: 2
      case let .UNRECOGNIZED(i): i
      }
    }
  }

  init() {}

  private var _storage = _StorageClass.defaultInstance
}

#if swift(>=4.2)

  extension Foxglove_LinePrimitive.TypeEnum: CaseIterable {
    // The compiler won't synthesize support with the UNRECOGNIZED case.
    static var allCases: [Foxglove_LinePrimitive.TypeEnum] = [
      .lineStrip,
      .lineLoop,
      .lineList,
    ]
  }

#endif // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
  extension Foxglove_LinePrimitive: @unchecked Sendable {}
  extension Foxglove_LinePrimitive.TypeEnum: @unchecked Sendable {}
#endif // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "foxglove"

extension Foxglove_LinePrimitive: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase,
  SwiftProtobuf._ProtoNameProviding
{
  static let protoMessageName: String = _protobuf_package + ".LinePrimitive"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "pose"),
    3: .same(proto: "thickness"),
    4: .standard(proto: "scale_invariant"),
    5: .same(proto: "points"),
    6: .same(proto: "color"),
    7: .same(proto: "colors"),
    8: .same(proto: "indices"),
  ]

  fileprivate class _StorageClass {
    var _type: Foxglove_LinePrimitive.TypeEnum = .lineStrip
    var _pose: Foxglove_Pose?
    var _thickness: Double = 0
    var _scaleInvariant: Bool = false
    var _points: [Foxglove_Point3] = []
    var _color: Foxglove_Color?
    var _colors: [Foxglove_Color] = []
    var _indices: [UInt32] = []

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _type = source._type
      _pose = source._pose
      _thickness = source._thickness
      _scaleInvariant = source._scaleInvariant
      _points = source._points
      _color = source._color
      _colors = source._colors
      _indices = source._indices
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try decoder.decodeSingularEnumField(value: &_storage._type)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._pose)
        case 3: try decoder.decodeSingularDoubleField(value: &_storage._thickness)
        case 4: try decoder.decodeSingularBoolField(value: &_storage._scaleInvariant)
        case 5: try decoder.decodeRepeatedMessageField(value: &_storage._points)
        case 6: try decoder.decodeSingularMessageField(value: &_storage._color)
        case 7: try decoder.decodeRepeatedMessageField(value: &_storage._colors)
        case 8: try decoder.decodeRepeatedFixed32Field(value: &_storage._indices)
        default: break
        }
      }
    }
  }

  func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      if _storage._type != .lineStrip {
        try visitor.visitSingularEnumField(value: _storage._type, fieldNumber: 1)
      }
      try { if let v = _storage._pose {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      if _storage._thickness != 0 {
        try visitor.visitSingularDoubleField(value: _storage._thickness, fieldNumber: 3)
      }
      if _storage._scaleInvariant != false {
        try visitor.visitSingularBoolField(value: _storage._scaleInvariant, fieldNumber: 4)
      }
      if !_storage._points.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._points, fieldNumber: 5)
      }
      try { if let v = _storage._color {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      } }()
      if !_storage._colors.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._colors, fieldNumber: 7)
      }
      if !_storage._indices.isEmpty {
        try visitor.visitPackedFixed32Field(value: _storage._indices, fieldNumber: 8)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func == (lhs: Foxglove_LinePrimitive, rhs: Foxglove_LinePrimitive) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((
        lhs._storage,
        rhs._storage
      )) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._type != rhs_storage._type { return false }
        if _storage._pose != rhs_storage._pose { return false }
        if _storage._thickness != rhs_storage._thickness { return false }
        if _storage._scaleInvariant != rhs_storage._scaleInvariant { return false }
        if _storage._points != rhs_storage._points { return false }
        if _storage._color != rhs_storage._color { return false }
        if _storage._colors != rhs_storage._colors { return false }
        if _storage._indices != rhs_storage._indices { return false }
        return true
      }
      if !storagesAreEqual { return false }
    }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}

extension Foxglove_LinePrimitive.TypeEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "LINE_STRIP"),
    1: .same(proto: "LINE_LOOP"),
    2: .same(proto: "LINE_LIST"),
  ]
}
