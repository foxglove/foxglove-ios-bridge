import SwiftUI
import Network
import Darwin
import Charts
import CoreMotion
import Combine

struct MonthlyHoursOfSunshine: Identifiable {
  var id = UUID()
  var date: Date
  var hoursOfSunshine: Double

  init(month: Int, hoursOfSunshine: Double) {
    let calendar = Calendar.autoupdatingCurrent
    self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
    self.hoursOfSunshine = hoursOfSunshine
  }
}

var data: [MonthlyHoursOfSunshine] = [
  MonthlyHoursOfSunshine(month: 1, hoursOfSunshine: 0),
  MonthlyHoursOfSunshine(month: 2, hoursOfSunshine: 10),
  MonthlyHoursOfSunshine(month: 3, hoursOfSunshine: 20),
  MonthlyHoursOfSunshine(month: 4, hoursOfSunshine: 30),
  MonthlyHoursOfSunshine(month: 5, hoursOfSunshine: 40),
  MonthlyHoursOfSunshine(month: 6, hoursOfSunshine: 30),
  MonthlyHoursOfSunshine(month: 7, hoursOfSunshine: 50),
  MonthlyHoursOfSunshine(month: 8, hoursOfSunshine: 60),
  MonthlyHoursOfSunshine(month: 9, hoursOfSunshine: 30),
  MonthlyHoursOfSunshine(month: 10, hoursOfSunshine: 20),
  MonthlyHoursOfSunshine(month: 11, hoursOfSunshine: 10),
  MonthlyHoursOfSunshine(month: 12, hoursOfSunshine: 40)
]

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
                  Chart(data) {
                    LineMark(
                      x: .value("Month", $0.date),
                      y: .value("Hours of Sunshine", $0.hoursOfSunshine)
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
