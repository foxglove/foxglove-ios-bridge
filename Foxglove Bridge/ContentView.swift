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
              Toggle(isOn: $server.sendPose) { Text("Pose") }
              Toggle(isOn: $server.sendRearCamera) { Text("Rear camera") }
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
