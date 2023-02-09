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
      topicsTab.tabItem {
        Image(systemName: "fibrechannel")
        Text("Topics")
      }
      serverTab.tabItem {
        Image(systemName: "network")
        Text("Server")
      }
    }
  }

  var topicsTab: some View {
    NavigationView {
      VStack {
        List {
          Section {
            Toggle(isOn: $server.sendPose) { Text("Pose") }
            Toggle(isOn: $server.sendLocation) { Text("GPS") }

            // TODO: CPU usage
            Toggle(isOn: $server.sendCPU ) { Text("CPU") }
            if server.sendCPU {
              cpuChart
            }

            // TODO: Memory usage
            Toggle(isOn: $server.sendMemory ) { Text("Memory") }
            if server.sendMemory {
              memoryChart
            }

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
        .listStyle(.insetGrouped)
      }
    }
  }

  var serverTab: some View {
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
    }
  }

  var cpuChart: some View {
    Chart(server.cpuHistory) {
      LineMark(
        x: .value("Time", $0.date),
        y: .value("Usage", $0.usage)
      )
    }
    .frame(height: 60)
    .chartXAxis(.hidden)
    .padding([.bottom, .top], 5)
    .chartYAxis {
      AxisMarks {
        AxisGridLine()
        AxisTick()
        let value = $0.as(Double.self)!
        AxisValueLabel {
          Text("\(value, format: .percent)")
        }
      }
    }
  }

  var memoryChart: some View {
    Chart(server.memHistory) {
      LineMark(
        x: .value("Time", $0.date),
        y: .value("Usage", $0.usage)
      )
    }
    .frame(height: 60)
    .chartXAxis(.hidden)
    .padding([.bottom, .top], 5)
    .chartYAxis {
      AxisMarks {
        AxisGridLine()
        AxisTick()
        let value = $0.as(Double.self)!
        AxisValueLabel {
          Text("\(value, format: .percent)")
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
