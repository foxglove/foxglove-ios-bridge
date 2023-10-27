import CoreMotion
import Foundation
import Network

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable force_try todo

extension NWConnection: Hashable, Comparable, Identifiable {
  public static func < (lhs: NWConnection, rhs: NWConnection) -> Bool {
    switch (lhs.endpoint, rhs.endpoint) {
    case let (.hostPort(host1, _), .hostPort(host: host2, _)):
      host1.debugDescription < host2.debugDescription

    default:
      ObjectIdentifier(lhs) < ObjectIdentifier(rhs)
    }
  }

  public static func == (lhs: NWConnection, rhs: NWConnection) -> Bool {
    lhs === rhs
  }

  public func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }

  public var id: ObjectIdentifier {
    ObjectIdentifier(self)
  }
}

typealias SubscriptionID = UInt32
typealias ChannelID = UInt32

class ClientInfo {
  let connection: NWConnection
  let name: String
  var subscriptions: [SubscriptionID: ChannelID] = [:]
  var subscriptionsByChannel: [ChannelID: Set<SubscriptionID>] = [:]

  init(connection: NWConnection) {
    self.connection = connection
    name = connection.endpoint.debugDescription
  }
}

struct Channel {
  let id: ChannelID
  let topic: String
  let encoding: String
  let schemaName: String
  let schema: String
}

enum FoxgloveServerError: Error {
  case channelDoesNotExist(id: ChannelID)
  case unrecognizedOpcode(_ op: String)
}

class FoxgloveServer: ObservableObject {
  let queue = DispatchQueue(label: "ServerQueue")

  @MainActor @Published var port: NWEndpoint.Port?
  @MainActor @Published private var clients: [NWConnection: ClientInfo] = [:]

  @MainActor
  var clientEndpointNames: [String] {
    clients.keys.sorted().map(\.endpoint.debugDescription)
  }

  @MainActor var channels: [ChannelID: Channel] = [:]

  func start(preferredPort: UInt16?) {
    print("starting with preferred port \(preferredPort.debugDescription)")
    do {
      let params = NWParameters(tls: nil)
      print(params.defaultProtocolStack.applicationProtocols)

      let opts = NWProtocolWebSocket.Options()
      opts.setClientRequestHandler(queue) { subprotocols, _ in
        let subproto = "foxglove.websocket.v1"
        if subprotocols.contains(subproto) {
          return NWProtocolWebSocket.Response(status: .accept, subprotocol: subproto)
        } else {
          return NWProtocolWebSocket.Response(status: .reject, subprotocol: nil)
        }
      }
      params.defaultProtocolStack.applicationProtocols.append(opts)

      let listener = try NWListener(using: params, on: preferredPort.map(NWEndpoint.Port.init) ?? .any)
      listener.stateUpdateHandler = { [weak self, weak listener] newState in
        guard let listener else {
          return
        }
        // If we tried to use a specific port but it was in use, try again with any port
        if preferredPort != nil, case .failed(.posix(.EADDRINUSE)) = newState {
          listener.cancel()
          self?.start(preferredPort: nil)
        }
        let port = newState == .ready ? listener.port : nil
        Task { @MainActor [self] in
          self?.port = port == 0 ? nil : port
        }
      }
      listener.newConnectionHandler = { [weak self] newConnection in
        self?.handleNewConnection(newConnection)
      }
      listener.start(queue: queue)
    } catch {
      print("Error \(error)")
    }
  }

  func handleNewConnection(_ connection: NWConnection) {
    print("New conn: \(connection)")

    let info = ClientInfo(connection: connection)
    Task { @MainActor in
      self.clients[connection] = info
    }

    func receive() {
      connection.receiveMessage { data, context, isComplete, error in
        if let data, let context {
          self.handleClientMessage(info, data, context, isComplete, error)
          receive()
        }
        // TODO: emit error
        if let error {
          print("receive error: \(error)")
        }
      }

      connection.stateUpdateHandler = { state in
        print("connection state \(state)")

        if connection.state == .ready {
          self.sendInfo(connection)
        }

        let closed: Bool
        switch connection.state {
        case .cancelled, .failed:
          closed = true
        default:
          closed = false
        }

        Task { @MainActor in
          if !self.channels.isEmpty {
            try self.sendJson([
              "op": "advertise",
              "channels": self.channels.values.map {
                [
                  "id": $0.id,
                  "topic": $0.topic,
                  "encoding": $0.encoding,
                  "schemaName": $0.schemaName,
                  "schema": $0.schema,
                ]
              },
            ], to: connection)
          }

          if closed {
            print("Closed \(connection)")
            let potentialUnsubscribes = Array(info.subscriptionsByChannel.keys)
            self.clients[connection] = nil
            for chanID in potentialUnsubscribes {
//              if !this.anySubscribed(chanID) {
//                this.emitter.emit("unsubscribe", channelId);
//              }
            }
          }
        }
      }
    }
    receive()

    connection.start(queue: queue)
  }

  static let binaryMessage = NWConnection.ContentContext(identifier: "", metadata: [
    NWProtocolWebSocket.Metadata(opcode: .binary),
  ])
  static let jsonMessage = NWConnection.ContentContext(identifier: "", metadata: [
    NWProtocolWebSocket.Metadata(opcode: .text),
  ])

  func sendInfo(_ connection: NWConnection) {
    try! sendJson([
      "op": "serverInfo",
      "name": "iOS Foxglove Bridge",
      "capabilities": [],
      "metadata": [:],
    ], to: connection)
  }

  private var nextChannelID: ChannelID = 0

  /**
   * Advertise a new channel and inform any connected clients.
   * - Returns: The ID of the new channel
   */
  @MainActor
  func addChannel(topic: String, encoding: String, schemaName: String, schema: String) -> ChannelID {
    let newID = nextChannelID
    nextChannelID += 1

    channels[newID] = Channel(
      id: newID,
      topic: topic,
      encoding: encoding,
      schemaName: schemaName,
      schema: schema
    )

    for (conn, info) in clients {
      // TODO: don't duplicate serialization
      do {
        try sendJson([
          "op": "advertise",
          "channels": [
            "id": newID,
            "topic": topic,
            "encoding": encoding,
            "schemaName": schemaName,
            "schema": schema,
          ],
        ], to: conn)
      } catch {
        // TODO: emit error
        print("addchannel error: \(error)")
      }
    }

    return newID
  }

  /**
   * Remove a previously advertised channel and inform any connected clients.
   */
  @MainActor
  func removeChannel(_ channelID: ChannelID) throws {
    if channels.removeValue(forKey: channelID) == nil {
      throw FoxgloveServerError.channelDoesNotExist(id: channelID)
    }
    for (conn, info) in clients {
      if let subs = info.subscriptionsByChannel[channelID] {
        for subID in subs {
          info.subscriptions[subID] = nil
        }
        info.subscriptionsByChannel[channelID] = nil
      }

      do {
        // TODO: serialize once
        try sendJson([
          "op": "unadvertise",
          "channelIds": [channelID],
        ], to: conn)
      } catch {
        // TODO: emit error
        print("remove error \(error)")
      }
    }
  }

  /**
   * Emit a message payload to any clients subscribed to `chanID`.
   */
  @MainActor
  func sendMessage(on chanID: ChannelID, timestamp: UInt64, payload: Data) {
    for (conn, info) in clients {
      guard let subs = info.subscriptionsByChannel[chanID] else { continue }
      for subID in subs {
        sendMessageData(on: conn, subscriptionID: subID, timestamp: timestamp, payload: payload)
      }
    }
  }

  private func sendMessageData(
    on connection: NWConnection,
    subscriptionID: SubscriptionID,
    timestamp: UInt64,
    payload: Data
  ) {
    var header = Data(count: 1 + 4 + 8)
    header[0] = BinaryOpcode.messageData.rawValue
    withUnsafeBytes(of: subscriptionID.littleEndian) {
      header.replaceSubrange(1 ..< 5, with: $0.baseAddress!, count: $0.count)
    }
    withUnsafeBytes(of: timestamp.littleEndian) {
      header.replaceSubrange(5 ..< 13, with: $0.baseAddress!, count: $0.count)
    }
    connection.send(
      content: header,
      contentContext: Self.binaryMessage,
      isComplete: false,
      completion: .contentProcessed { error in
        if let error {
          print("error sending1: \(error)")
        }
      }
    )
    connection.send(
      content: payload,
      contentContext: Self.binaryMessage,
      isComplete: true,
      completion: .contentProcessed { error in
        if let error {
          print("error sending2: \(error)")
        }
      }
    )
  }

  private func sendJson(_ obj: Any, to connection: NWConnection) throws {
    let data = try JSONSerialization.data(withJSONObject: obj)

    connection.send(content: data, contentContext: Self.jsonMessage, completion: .contentProcessed { error in
      if let error {
        print("send error: \(error)")
      }
    })
  }

  private func sendBinary(_ data: Data, to connection: NWConnection) throws {
    connection.send(content: data, contentContext: Self.binaryMessage, completion: .contentProcessed { error in
      if let error {
        print("send error: \(error)")
      }
    })
  }

  private func handleClientMessage(
    _ client: ClientInfo,
    _ data: Data,
    _ context: NWConnection.ContentContext,
    _: Bool,
    _ error: NWError?
  ) {
    do {
      let metadata = context.protocolMetadata(definition: NWProtocolWebSocket.definition)
      let isText = (metadata as? NWProtocolWebSocket.Metadata)?.opcode == .text
      if isText {
        let msg = try JSONDecoder().decode(ClientMessage.self, from: data)
        switch msg {
        case let .subscribe(msg):
          Task { @MainActor in
            for sub in msg.subscriptions {
              // TODO: emit status messages for warnings (see TS impl)
              guard let info = self.channels[sub.channelId] else {
                // TODO: emit status messages for warnings
                print("no channel for sub \(sub.channelId)")
                continue
              }
              client.subscriptions[sub.id] = sub.channelId
              client.subscriptionsByChannel[sub.channelId, default: []].insert(sub.id)
            }
            // TODO: emit subscribe
          }
        case let .unsubscribe(msg):
          Task { @MainActor in
            for sub in msg.subscriptionIds {
              guard let chanID = client.subscriptions[sub] else {
                // TODO: error
                continue
              }
              client.subscriptions[sub] = nil
              // TODO: cleanup index usage?
              client.subscriptionsByChannel[chanID]?.remove(sub)
              if client.subscriptionsByChannel[chanID]?.isEmpty == true {
                client.subscriptionsByChannel[chanID] = nil
              }
            }
            // TODO: emit unsubscribe
          }
        }
      }
      if let obj = try? JSONSerialization.jsonObject(with: data) {
        print("Got client message: \(obj)")
      } else {
        print("Got client message: data \(data)")
      }
    } catch {
      // TODO: emit error
      print("client msg error: \(error)")
    }
  }
}

enum ClientOp: String {
  case subscribe, unsubscribe
}

enum BinaryOpcode: UInt8 {
  case messageData = 0x01
}

struct Subscribe: Decodable {
  static let op = ClientOp.subscribe
  struct Subscription: Decodable {
    let id: SubscriptionID
    let channelId: ChannelID
  }

  let subscriptions: [Subscription]
}

struct Unsubscribe: Decodable {
  static let op = ClientOp.unsubscribe
  let subscriptionIds: [SubscriptionID]
}

enum ClientMessage: Decodable {
  enum CodingKeys: CodingKey {
    case op
  }

  case subscribe(Subscribe)
  case unsubscribe(Unsubscribe)

  init(from decoder: Decoder) throws {
    let op = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .op)
    switch ClientOp(rawValue: op) {
    case .subscribe: self = try .subscribe(Subscribe(from: decoder))
    case .unsubscribe: self = try .unsubscribe(Unsubscribe(from: decoder))
    case nil:
      throw FoxgloveServerError.unrecognizedOpcode(op)
    }
  }
}
