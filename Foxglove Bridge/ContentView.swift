import SwiftUI
import Network
import Darwin
import CoreMotion
import Combine

@MainActor
class Server: ObservableObject {
  let address = getIPAddress() ?? "<no address>"

  let server = FoxgloveServer()

  let motionManager = CMMotionManager()
  var subscribers: [AnyCancellable] = []

  let poseChannel: ChannelID

  @Published var sendPose = true {
    didSet {
      if sendPose {
        startPoseUpdates()
      } else {
        stopPoseUpdates()
      }
    }
  }

  @Published var port: NWEndpoint.Port?
  var clientEndpointNames: [String] {
    print(server.clientEndpointNames)
    return server.clientEndpointNames
  }

  init() {
    poseChannel = server.addChannel(topic: "pose", encoding: "json", schemaName: "foxglove.PoseInFrame", schema: poseInFrameSchema)
    server.$port.assign(to: \.port, on: self).store(in: &subscribers)
    server.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }.store(in: &subscribers)
    startPoseUpdates()
  }


  func startPoseUpdates() {
    motionManager.deviceMotionUpdateInterval = 0.02
    motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
      if let motion {
        self.sendPose(motion: motion)
      }
    }
  }
  func stopPoseUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }

  func sendPose(motion: CMDeviceMotion) {
    let data = try! JSONSerialization.data(withJSONObject: [
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
    ], options: .sortedKeys)

    server.sendMessage(on: poseChannel, timestamp: DispatchTime.now().uptimeNanoseconds, payload: data)
  }
}


struct ContentView: View {
  @StateObject var server = Server()

  @State var sendPose = true

  var body: some View {
    NavigationView {
      VStack {
        List {
          if let port = server.port {
            Section {
              Text("Listening on \(server.address):\(port.debugDescription)")
              Toggle(isOn: $sendPose) {
                Text("Pose")
              }.onChange(of: sendPose) { newValue in
                if newValue {
                  server.startPoseUpdates()
                } else {
                  server.stopPoseUpdates()
                }
              }
            } header: {
              Text("Server")
            }
          }
          Section {
            ForEach(Array(server.clientEndpointNames.enumerated()), id: \.offset) {
              Text($0.element)
            }
          } header: {
            Text("Clients")
          }
        }
        .listStyle(.insetGrouped)
      }
      .navigationTitle(Text("WebSocket demo"))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
