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
      ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 20)], spacing: 20) {
          CardToggle(isOn: $server.sendPose) {
            Text("Pose")
          }
          CardToggle(isOn: $server.sendLocation) {
            Text("GPS")
          }
          CardToggle(isOn: $server.sendCPU) {
            Text("CPU")
            if server.sendCPU {
              cpuChart
            }
          }
          CardToggle(isOn: $server.sendMemory) {
            Text("Memory")
            if server.sendMemory {
              memoryChart
            }
          }
          CardToggle(isOn: $server.sendCamera) {
            Text("Camera")
            if server.sendCamera {
              Text("Dropped frames: \(server.droppedVideoFrames)")
            }
          }.overlay(alignment: .bottom) {
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
            .pickerStyle(.segmented)
            .padding()
          }
          CardToggle(isOn: $server.sendWatchData) {
            Text("Apple Watch")
          }
        }.padding()
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
