import SwiftUI
import Network
import Darwin
import Charts
import CoreMotion
import Combine

struct ContentView: View {
  @StateObject var server = Server()

  @State var sendPose = true

  var body: some View {
    TabView {
      NavigationView {
        VStack {
          List {
            if let port = server.port {
              Section {
                Text("Listening on \(server.address):\(port.debugDescription)")
              } header: { Text("Server") }

              Section {
                Toggle(isOn: $server.sendPose) { Text("Pose") }
                Toggle(isOn: $server.sendLocation) { Text("GPS") }

                // TODO: CPU usage
                Toggle(isOn: $server.sendCPU ) { Text("CPU") }
                if server.sendCPU {
                  Chart(server.cpuHistory) {
                    LineMark(
                      x: .value("Time", $0.date),
                      y: .value("Usage", 1 - $0.idle)
                    )
                  }
                  .frame(height: 60)
                  .chartXAxis(Visibility.hidden)
                  .padding([.bottom, .top], 5)
                }

                // TODO: Memory usage
                Toggle(isOn: $server.sendMemory ) { Text("Memory") }
                  .disabled(true)

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
                  }
                }
                .pickerStyle(InlinePickerStyle())

                if server.sendCamera {
                  Text("Dropped frames: \(server.droppedVideoFrames)")
                }
              } header: { Text("Topics") }
            }
          }
          .listStyle(.insetGrouped)
        }
      }
      .tabItem {
        Image(systemName: "list.dash")
        Text("Tab 2")
      }
      NavigationView {
        VStack {
          List {
            if let port = server.port {
              Section {
                Text("Listening on \(server.address):\(port.debugDescription)")
              } header: { Text("Server") }

              Section {
                ForEach(Array(server.clientEndpointNames.enumerated()), id: \.offset) {
                  Text($0.element)
                }
              } header: {
                Text("Clients")
              }
            }
          }
          .listStyle(.insetGrouped)
        }
      }.tabItem {
        Image(systemName: "list.dash")
        Text("Tab 1") }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
