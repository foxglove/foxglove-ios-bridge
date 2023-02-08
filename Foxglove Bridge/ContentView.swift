import SwiftUI
import Network
import Darwin
import CoreMotion
import Combine

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
            } header: { Text("Server") }

            Section {
              Toggle(isOn: $server.sendPose) { Text("Pose") }

              // TODO: GPS @jtbandes
              Toggle(isOn: $server.sendGPS ) { Text("GPS") }

              // TODO: CPU usage
              Toggle(isOn: $server.sendCPU ) { Text("CPU") }

              // TODO: Memory usage
              Toggle(isOn: $server.sendMemory ) { Text("Memory") }

              Picker(
                selection: $server.activeCamera,
                label: Toggle(isOn: $server.sendCamera) {
                  Text("Camera")
                }
              ) {
                if server.sendCamera {
                  ForEach(Camera.allCases) {
                    Text($0.description)
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
