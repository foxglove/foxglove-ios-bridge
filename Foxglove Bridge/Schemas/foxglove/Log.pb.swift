// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: foxglove/Log.proto
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

/// A log message
struct Foxglove_Log {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Timestamp of log message
  var timestamp: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _timestamp ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_timestamp = newValue}
  }
  /// Returns true if `timestamp` has been explicitly set.
  var hasTimestamp: Bool {return self._timestamp != nil}
  /// Clears the value of `timestamp`. Subsequent reads from it will return its default value.
  mutating func clearTimestamp() {self._timestamp = nil}

  /// Log level
  var level: Foxglove_Log.Level = .unknown

  /// Log message
  var message: String = String()

  /// Process or node name
  var name: String = String()

  /// Filename
  var file: String = String()

  /// Line number in the file
  var line: UInt32 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  /// Log level
  enum Level: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case unknown // = 0
    case debug // = 1
    case info // = 2
    case warning // = 3
    case error // = 4
    case fatal // = 5
    case UNRECOGNIZED(Int)

    init() {
      self = .unknown
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .unknown
      case 1: self = .debug
      case 2: self = .info
      case 3: self = .warning
      case 4: self = .error
      case 5: self = .fatal
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .unknown: return 0
      case .debug: return 1
      case .info: return 2
      case .warning: return 3
      case .error: return 4
      case .fatal: return 5
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}

  fileprivate var _timestamp: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=4.2)

extension Foxglove_Log.Level: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [Foxglove_Log.Level] = [
    .unknown,
    .debug,
    .info,
    .warning,
    .error,
    .fatal,
  ]
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension Foxglove_Log: @unchecked Sendable {}
extension Foxglove_Log.Level: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "foxglove"

extension Foxglove_Log: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Log"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "timestamp"),
    2: .same(proto: "level"),
    3: .same(proto: "message"),
    4: .same(proto: "name"),
    5: .same(proto: "file"),
    6: .same(proto: "line"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._timestamp) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.level) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.message) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.file) }()
      case 6: try { try decoder.decodeSingularFixed32Field(value: &self.line) }()
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
    if self.level != .unknown {
      try visitor.visitSingularEnumField(value: self.level, fieldNumber: 2)
    }
    if !self.message.isEmpty {
      try visitor.visitSingularStringField(value: self.message, fieldNumber: 3)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 4)
    }
    if !self.file.isEmpty {
      try visitor.visitSingularStringField(value: self.file, fieldNumber: 5)
    }
    if self.line != 0 {
      try visitor.visitSingularFixed32Field(value: self.line, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Foxglove_Log, rhs: Foxglove_Log) -> Bool {
    if lhs._timestamp != rhs._timestamp {return false}
    if lhs.level != rhs.level {return false}
    if lhs.message != rhs.message {return false}
    if lhs.name != rhs.name {return false}
    if lhs.file != rhs.file {return false}
    if lhs.line != rhs.line {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Foxglove_Log.Level: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UNKNOWN"),
    1: .same(proto: "DEBUG"),
    2: .same(proto: "INFO"),
    3: .same(proto: "WARNING"),
    4: .same(proto: "ERROR"),
    5: .same(proto: "FATAL"),
  ]
}
