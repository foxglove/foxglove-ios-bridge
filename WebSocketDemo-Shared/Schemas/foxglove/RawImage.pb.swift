// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/RawImage.proto
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

/// A raw image
struct Foxglove_RawImage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Timestamp of image
  var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get { _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp() }
    set { _timestamp = newValue }
  }

  /// Returns true if `timestamp` has been explicitly set.
  var hasTimestamp: Bool { _timestamp != nil }
  /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
  mutating func clearTimestamp() { _timestamp = nil }

  /// Frame of reference for the image. The origin of the frame is the optical center of the camera. +x points to the
  /// right in the image, +y points down, and +z points into the plane of the image.
  var frameID: String = .init()

  /// Image width
  var width: UInt32 = 0

  /// Image height
  var height: UInt32 = 0

  /// Encoding of the raw image data
  ///
  /// Supported values: `8UC1`, `8UC3`, `16UC1`, `32FC1`, `bayer_bggr8`, `bayer_gbrg8`, `bayer_grbg8`, `bayer_rggb8`,
  /// `bgr8`, `bgra8`, `mono8`, `mono16`, `rgb8`, `rgba8`, `uyvy` or `yuv422`, `yuyv` or `yuv422_yuy2`
  var encoding: String = .init()

  /// Byte length of a single row
  var step: UInt32 = 0

  /// Raw image data
  var data: Data = .init()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  private var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp?
}

#if swift(>=5.5) && canImport(_Concurrency)
  extension Foxglove_RawImage: @unchecked Sendable {}
#endif // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "foxglove"

extension Foxglove_RawImage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase,
  SwiftProtobuf._ProtoNameProviding
{
  static let protoMessageName: String = _protobuf_package + ".RawImage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    7: .standard(proto: "frame_id"),
    2: .same(proto: "width"),
    3: .same(proto: "height"),
    4: .same(proto: "encoding"),
    5: .same(proto: "step"),
    6: .same(proto: "data"),
  ]

  mutating func decodeMessage(decoder: inout some SwiftProtobuf.Decoder) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &_timestamp)
      case 2: try decoder.decodeSingularFixed32Field(value: &width)
      case 3: try decoder.decodeSingularFixed32Field(value: &height)
      case 4: try decoder.decodeSingularStringField(value: &encoding)
      case 5: try decoder.decodeSingularFixed32Field(value: &step)
      case 6: try decoder.decodeSingularBytesField(value: &data)
      case 7: try decoder.decodeSingularStringField(value: &frameID)
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
    if width != 0 {
      try visitor.visitSingularFixed32Field(value: width, fieldNumber: 2)
    }
    if height != 0 {
      try visitor.visitSingularFixed32Field(value: height, fieldNumber: 3)
    }
    if !encoding.isEmpty {
      try visitor.visitSingularStringField(value: encoding, fieldNumber: 4)
    }
    if step != 0 {
      try visitor.visitSingularFixed32Field(value: step, fieldNumber: 5)
    }
    if !data.isEmpty {
      try visitor.visitSingularBytesField(value: data, fieldNumber: 6)
    }
    if !frameID.isEmpty {
      try visitor.visitSingularStringField(value: frameID, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func == (lhs: Foxglove_RawImage, rhs: Foxglove_RawImage) -> Bool {
    if lhs._timestamp != rhs._timestamp { return false }
    if lhs.frameID != rhs.frameID { return false }
    if lhs.width != rhs.width { return false }
    if lhs.height != rhs.height { return false }
    if lhs.encoding != rhs.encoding { return false }
    if lhs.step != rhs.step { return false }
    if lhs.data != rhs.data { return false }
    if lhs.unknownFields != rhs.unknownFields { return false }
    return true
  }
}
