// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/TextAnnotation.proto
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

/// A text label on a 2D image
struct Foxglove_TextAnnotation {
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

  /// Bottom-left origin of the text label in 2D image coordinates (pixels)
  var position: Foxglove_Point2 {
    get { _position ?? Foxglove_Point2() }
    set { _position = newValue }
  }

  /// Returns true if `position` has been explicitly set.
  var hasPosition: Bool { _position != nil }
  /// Clears the value of `position`. Subsequent reads from it will return its default value.
  mutating func clearPosition() { _position = nil }

  /// Text to display
  var text: String = .init()

  /// Font size in pixels
  var fontSize: Double = 0

  /// Text color
  var textColor: Foxglove_Color {
    get { _textColor ?? Foxglove_Color() }
    set { _textColor = newValue }
  }

  /// Returns true if `textColor` has been explicitly set.
  var hasTextColor: Bool { _textColor != nil }
  /// Clears the value of `textColor`. Subsequent reads from it will return its default value.
  mutating func clearTextColor() { _textColor = nil }

  /// Background fill color
  var backgroundColor: Foxglove_Color {
    get { _backgroundColor ?? Foxglove_Color() }
    set { _backgroundColor = newValue }
  }

  /// Returns true if `backgroundColor` has been explicitly set.
  var hasBackgroundColor: Bool { _backgroundColor != nil }
  /// Clears the value of `backgroundColor`. Subsequent reads from it will return its default value.
  mutating func clearBackgroundColor() { _backgroundColor = nil }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  private var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp?
  private var _position: Foxglove_Point2?
  private var _textColor: Foxglove_Color?
  private var _backgroundColor: Foxglove_Color?
}

#if swift(>=5.5) && canImport(_Concurrency)
  extension Foxglove_TextAnnotation: @unchecked Sendable {}
#endif // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "foxglove"

extension Foxglove_TextAnnotation: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase,
  SwiftProtobuf._ProtoNameProviding
{
  static let protoMessageName: String = _protobuf_package + ".TextAnnotation"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .same(proto: "position"),
    3: .same(proto: "text"),
    4: .standard(proto: "font_size"),
    5: .standard(proto: "text_color"),
    6: .standard(proto: "background_color"),
  ]

  mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &_timestamp)
      case 2: try decoder.decodeSingularMessageField(value: &_position)
      case 3: try decoder.decodeSingularStringField(value: &text)
      case 4: try decoder.decodeSingularDoubleField(value: &fontSize)
      case 5: try decoder.decodeSingularMessageField(value: &_textColor)
      case 6: try decoder.decodeSingularMessageField(value: &_backgroundColor)
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
    try { if let v = self._position {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !text.isEmpty {
      try visitor.visitSingularStringField(value: text, fieldNumber: 3)
    }
    if fontSize != 0 {
      try visitor.visitSingularDoubleField(value: fontSize, fieldNumber: 4)
    }
    try { if let v = self._textColor {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    } }()
    try { if let v = self._backgroundColor {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func == (lhs: Foxglove_TextAnnotation, rhs: Foxglove_TextAnnotation) -> Bool {
    if lhs._timestamp != rhs._timestamp { return false }
    if lhs._position != rhs._position { return false }
    if lhs.text != rhs.text { return false }
    if lhs.fontSize != rhs.fontSize { return false }
    if lhs._textColor != rhs._textColor { return false }
    if lhs._backgroundColor != rhs._backgroundColor { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
