import Network
import Foundation
import CoreMotion

extension NWConnection: Hashable, Comparable, Identifiable {
  public static func < (lhs: NWConnection, rhs: NWConnection) -> Bool {
    switch (lhs.endpoint, rhs.endpoint) {
    case (.hostPort(let host1, _), .hostPort(host: let host2, _)):
      return host1.debugDescription < host2.debugDescription

    default:
      return ObjectIdentifier(lhs) < ObjectIdentifier(rhs)
    }
  }

  public static func == (lhs: NWConnection, rhs: NWConnection) -> Bool {
    return lhs === rhs
  }

  public func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }

  public var id: ObjectIdentifier {
    return ObjectIdentifier(self)
  }
}

class Server: ObservableObject {
  let queue = DispatchQueue(label: "ServerQueue")

  let address = getIPAddress() ?? "<no address>"
  var timer: Timer?

  let motionManager = CMMotionManager()

  @MainActor @Published var port: NWEndpoint.Port?

  @MainActor @Published var clients: [NWConnection: NWConnection.State] = [:]

  init() {
    do {
      let params = NWParameters(tls: nil)
//      params.includePeerToPeer = true
      print(params.defaultProtocolStack.applicationProtocols)

      let opts = NWProtocolWebSocket.Options()
//      opts.setSubprotocols(["foxglove.websocket.v1"])
      opts.setClientRequestHandler(queue) { subprotocols, additionalHeaders in
        let subproto = "foxglove.websocket.v1"
        if subprotocols.contains(subproto) {
          return NWProtocolWebSocket.Response(status: .accept, subprotocol: subproto)
        } else {
          return NWProtocolWebSocket.Response(status: .reject, subprotocol: nil)
        }
      }
      params.defaultProtocolStack.applicationProtocols.append(opts)

      let listener = try NWListener(using: params, on: 62338)
      listener.stateUpdateHandler = { newState in
        if let port = listener.port {
          print("Listening on \(self.address):\(port)")
        }
        Task { @MainActor in
          self.port = listener.port
        }
      }
      listener.newConnectionHandler = { [weak self] newConnection in
        guard let self else { return }
        print("New conn: \(newConnection)")

        Task { @MainActor in
          self.clients[newConnection] = newConnection.state
        }

        func receive() {
          newConnection.receiveMessage { data, context, isComplete, error in
            if let data, let context {
              self.handleClientMessage(data, context, isComplete, error)
              receive()
            }
          }

          newConnection.stateUpdateHandler = { state in
            print("connection state \(state)")

            if newConnection.state == .ready {
              self.sendInfo(newConnection)
            }

            Task { @MainActor in
              if case .failed(_) = newConnection.state {
                self.clients[newConnection] = nil
              } else if newConnection.state == .cancelled {
                self.clients[newConnection] = nil
              } else {
                self.clients[newConnection] = newConnection.state
              }
            }
          }
        }
        receive()

        newConnection.start(queue: self.queue)

        self.startPoseUpdates()
      }
      listener.start(queue: queue)

//      self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
//        self.broadcastData()
//      }

    } catch let error {
      print("Error \(error)")
    }
  }

  func startPoseUpdates() {
    motionManager.deviceMotionUpdateInterval = 0.02
    motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
      if let motion {
        self.broadcastPose(motion: motion)
      }
    }
  }
  func stopPoseUpdates() {
    motionManager.stopDeviceMotionUpdates()
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

    try! sendJson([
      "op": "advertise",
      "channels": [
        [
          "id": 1,
          "topic": "pose",
          "encoding": "json",
          "schemaName": "foxglove.PoseInFrame",
//          "schema": #"{"type":"object","properties":{"roll":{"type":"number"},"pitch":{"type":"number"},"yaw":{"type":"number"}}}"#,
          "schema":"""
{
  "title": "foxglove.PoseInFrame",
  "description": "A timestamped pose for an object or reference frame in 3D space",
  "$comment": "Generated by https://github.com/foxglove/schemas",
  "type": "object",
  "properties": {
    "timestamp": {
      "type": "object",
      "title": "time",
      "properties": {
        "sec": {
          "type": "integer",
          "minimum": 0
        },
        "nsec": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "description": "Timestamp of pose"
    },
    "frame_id": {
      "type": "string",
      "description": "Frame of reference for pose position and orientation"
    },
    "pose": {
      "title": "foxglove.Pose",
      "description": "Pose in 3D space",
      "type": "object",
      "properties": {
        "position": {
          "title": "foxglove.Vector3",
          "description": "Point denoting position in 3D space",
          "type": "object",
          "properties": {
            "x": {
              "type": "number",
              "description": "x coordinate length"
            },
            "y": {
              "type": "number",
              "description": "y coordinate length"
            },
            "z": {
              "type": "number",
              "description": "z coordinate length"
            }
          }
        },
        "orientation": {
          "title": "foxglove.Quaternion",
          "description": "Quaternion denoting orientation in 3D space",
          "type": "object",
          "properties": {
            "x": {
              "type": "number",
              "description": "x value"
            },
            "y": {
              "type": "number",
              "description": "y value"
            },
            "z": {
              "type": "number",
              "description": "z value"
            },
            "w": {
              "type": "number",
              "description": "w value"
            }
          }
        }
      }
    }
  }
}
"""
        ],
      ],
    ], to: connection)
  }

  func broadcastPose(motion: CMDeviceMotion) {
    var data = Data()
    data.append(0x01) // opcode
    var subId = UInt32(0).littleEndian
    withUnsafeBytes(of: &subId) { data.append(contentsOf: $0) }
    var timestamp = UInt64(DispatchTime.now().uptimeNanoseconds).littleEndian
    withUnsafeBytes(of: &timestamp) { data.append(contentsOf: $0) }
//    data.append(try! JSONSerialization.data(withJSONObject: ["roll": motion.attitude.roll, "pitch": motion.attitude.pitch, "yaw": motion.attitude.yaw], options: .sortedKeys))
    data.append(try! JSONSerialization.data(withJSONObject: [
      "timestamp": 0,
      "frame_id": "root",
      "pose": [
        "position":["x":0,"y":0,"z":0],
        "orientation":[
          "x":motion.attitude.quaternion.x,
          "y":motion.attitude.quaternion.y,
          "z":motion.attitude.quaternion.z,
          "w":motion.attitude.quaternion.w,
        ],
      ],
    ], options: .sortedKeys))
    let constData = data

    Task { @MainActor in
      for conn in self.clients.keys {
        try! sendBinary(constData, to: conn)
      }
    }
  }

  func sendJson(_ obj: Any, to connection: NWConnection) throws {
    let data = try JSONSerialization.data(withJSONObject: obj)

    connection.send(content: data, contentContext: Self.jsonMessage, completion: .contentProcessed({ error in
      if let error {
        print("send error: \(error)")
      }
    }))
  }

  func sendBinary(_ data: Data, to connection: NWConnection) throws {
    connection.send(content: data, contentContext: Self.binaryMessage, completion: .contentProcessed({ error in
      if let error {
        print("send error: \(error)")
      }
    }))
  }

  func handleClientMessage(_ data: Data, _ context: NWConnection.ContentContext, _ isComplete: Bool, _ error: NWError?) {
    if let obj = try? JSONSerialization.jsonObject(with: data) {
      print("Got client message: \(obj)")
    } else {
      print("Got client message: data \(data)")
    }
  }
}