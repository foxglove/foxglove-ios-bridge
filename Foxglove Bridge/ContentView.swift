import SwiftUI
import Network
import Darwin
import CoreMotion


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
            ForEach(server.clients.keys.sorted()) { client in
              Text("\(client.endpoint.debugDescription): \(String(describing: client.state))")
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
