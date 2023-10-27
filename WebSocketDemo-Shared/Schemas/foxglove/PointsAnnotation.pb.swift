// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/PointsAnnotation.proto
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

/// An array of points on a 2D image
struct Foxglove_PointsAnnotation {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Timestamp of annotation
  var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get { _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp() }
    set { _timestamp = newValue }
  }

  /// Returns true if `timestamp` has been explicitly set.
  var hasTimestamp: Bool { _timestamp != nil }
  /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
  mutating func clearTimestamp() { _timestamp = nil }

  /// Type of points annotation to draw
  var type: Foxglove_PointsAnnotation.TypeEnum = .unknown

  /// Points in 2D image coordinates (pixels)
  var points: [Foxglove_Point2] = []

  /// Outline color
  var outlineColor: Foxglove_Color {
    get { _outlineColor ?? Foxglove_Color() }
    set { _outlineColor = newValue }
  }

  /// Returns true if `outlineColor` has been explicitly set.
  var hasOutlineColor: Bool { _outlineColor != nil }
  /// Clears the value of `outlineColor`. Subsequent reads from it will return its default value.
  mutating func clearOutlineColor() { _outlineColor = nil }

  /// Per-point colors, if `type` is `POINTS`, or per-segment stroke colors, if `type` is `LINE_LIST`.
  var outlineColors: [Foxglove_Color] = []

  /// Fill color
  var fillColor: Foxglove_Color {
    get { _fillColor ?? Foxglove_Color() }
    set { _fillColor = newValue }
  }

  /// Returns true if `fillColor` has been explicitly set.
  var hasFillColor: Bool { _fillColor != nil }
  /// Clears the value of `fillColor`. Subsequent reads from it will return its default value.
  mutating func clearFillColor() { _fillColor = nil }

  /// Stroke thickness in pixels
  var thickness: Double = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  /// Type of points annotation
  enum TypeEnum: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case unknown // = 0

    /// Individual points: 0, 1, 2, ...
    case points // = 1

    /// Closed polygon: 0-1, 1-2, ..., (n-1)-n, n-0
    case lineLoop // = 2

    /// Connected line segments: 0-1, 1-2, ..., (n-1)-n
    case lineStrip // = 3

    /// Individual line segments: 0-1, 2-3, 4-5, ...
    case lineList // = 4
    case UNRECOGNIZED(Int)

    init() {
      self = .unknown
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unknown
      case 1: self = .points
      case 2: self = .lineLoop
      case 3: self = .lineStrip
      case 4: self = .lineList
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .unknown: 0
      case .points: 1
      case .lineLoop: 2
      case .lineStrip: 3
      case .lineList: 4
      case let .UNRECOGNIZED(i): i
      }
    }
  }

  init() {}

  private var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp?
  private var _outlineColor: Foxglove_Color?
  private var _fillColor: Foxglove_Color?
}

#if swift(>=4.2)

  extension Foxglove_PointsAnnotation.TypeEnum: CaseIterable {
    // The compiler won't synthesize support with the UNRECOGNIZED case.
    static var allCases: [Foxglove_PointsAnnotation.TypeEnum] = [
      .unknown,
      .points,
      .lineLoop,
      .lineStrip,
      .lineList,
    ]
  }

#endif // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
  extension Foxglove_PointsAnnotation: @unchecked Sendable {}
  extension Foxglove_PointsAnnotation.TypeEnum: @unchecked Sendable {}
#endif // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "foxglove"

extension Foxglove_PointsAnnotation: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase,
  SwiftProtobuf._ProtoNameProviding
{
  static let protoMessageName: String = _protobuf_package + ".PointsAnnotation"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .same(proto: "type"),
    3: .same(proto: "points"),
    4: .standard(proto: "outline_color"),
    5: .standard(proto: "outline_colors"),
    6: .standard(proto: "fill_color"),
    7: .same(proto: "thickness"),
  ]

  mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &_timestamp)
      case 2: try decoder.decodeSingularEnumField(value: &type)
      case 3: try decoder.decodeRepeatedMessageField(value: &points)
      case 4: try decoder.decodeSingularMessageField(value: &_outlineColor)
      case 5: try decoder.decodeRepeatedMessageField(value: &outlineColors)
      case 6: try decoder.decodeSingularMessageField(value: &_fillColor)
      case 7: try decoder.decodeSingularDoubleField(value: &thickness)
      default: break
      }
    }
  }

  func traverse(visitor: inout some SwiftProtobuf.Visitor) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if let v = _timestamp {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if type != .unknown {
      try visitor.visitSingularEnumField(value: type, fieldNumber: 2)
    }
    if !points.isEmpty {
      try visitor.visitRepeatedMessageField(value: points, fieldNumber: 3)
    }
    try { if let v = self._outlineColor {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    if !outlineColors.isEmpty {
      try visitor.visitRepeatedMessageField(value: outlineColors, fieldNumber: 5)
    }
    try { if let v = self._fillColor {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    } }()
    if thickness != 0 {
      try visitor.visitSingularDoubleField(value: thickness, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func == (lhs: Foxglove_PointsAnnotation, rhs: Foxglove_PointsAnnotation) -> Bool {
    if lhs._timestamp != rhs._timestamp { return false }
    if lhs.type != rhs.type { return false }
    if lhs.points != rhs.points { return false }
    if lhs._outlineColor != rhs._outlineColor { return false }
    if lhs.outlineColors != rhs.outlineColors { return false }
    if lhs._fillColor != rhs._fillColor { return false }
    if lhs.thickness != rhs.thickness { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}

extension Foxglove_PointsAnnotation.TypeEnum: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "POINTS"),
    2: .same(proto: "LINE_LOOP"),
    3: .same(proto: "LINE_STRIP"),
    4: .same(proto: "LINE_LIST"),
  ]
}
