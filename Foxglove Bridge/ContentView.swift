import SwiftUI
import Network
import Darwin
import CoreMotion
import Combine

struct ContentView: View {
  @StateObject var server = Server()

  @State var sendPose = true
  @State var selectedCamera = 0

  static let cameras = ["Front", "Rear"]

  var body: some View {
    NavigationView {
      VStack {
        List {
          if let port = server.port {
            Section {
              Text("Listening on \(server.address):\(port.debugDescription)")
            } header: { Text("Server") }

            Section {
              Toggle(isOn: $server.sendPose) { Text("Pose") }
              Picker(
                selection: $selectedCamera,
                label: Toggle(isOn: $server.sendRearCamera) {
                  Text("Camera")
                }) {
                if server.sendRearCamera {
                  ForEach(0 ..< Self.cameras.count) {
                    Text(Self.cameras[$0])
                  }
                  Text("Dropped frames: \(server.droppedVideoFrames)")
                }
              }
              .pickerStyle(InlinePickerStyle())

            } header: { Text("Topics") }
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
