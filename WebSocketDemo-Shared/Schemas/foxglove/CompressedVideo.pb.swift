// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/CompressedVideo.proto
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

/// A single frame of a compressed video bitstream
struct Foxglove_CompressedVideo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Timestamp of video frame
  var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_timestamp = newValue}
  }
  /// Returns true if `timestamp` has been explicitly set.
  var hasTimestamp: Bool {return self._timestamp != nil}
  /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
  mutating func clearTimestamp() {self._timestamp = nil}

  /// Frame of reference for the video. The origin of the frame is the optical center of the camera. +x points to the right in the video, +y points down, and +z points into the plane of the video.
  var frameID: String = String()

  /// Compressed video frame data. For packet-based video codecs this data must begin and end on packet boundaries (no partial packets), and must contain enough video packets to decode exactly one image (either a keyframe or delta frame). Note: Foxglove Studio does not support video streams that include B frames because they require lookahead.
  var data: Data = Data()

  /// Video format
  /// 
  /// Supported values: `h264`
  var format: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Foxglove_CompressedVideo: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "foxglove"

extension Foxglove_CompressedVideo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".CompressedVideo"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .standard(proto: "frame_id"),
    3: .same(proto: "data"),
    4: .same(proto: "format"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.frameID) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.data) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.format) }()
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
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 3)
    }
    if !self.format.isEmpty {
      try visitor.visitSingularStringField(value: self.format, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Foxglove_CompressedVideo, rhs: Foxglove_CompressedVideo) -> Bool {
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs.frameID != rhs.frameID {return false}
    if lhs.data != rhs.data {return false}
    if lhs.format != rhs.format {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
