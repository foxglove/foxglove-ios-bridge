import SwiftUI
import Charts
import StoreKit

@MainActor
class AsyncInitialized<T>: ObservableObject {
  @Published var value: T?
  init(_ block: @escaping () -> T?) {
    Task.detached {
      let result = block()
      Task { @MainActor in
        self.value = result
      }
    }
  }
}

private let isAppClip = Bundle.main.bundleIdentifier?.hasSuffix("appclip") ?? false
private let feedbackGenerator = UINotificationFeedbackGenerator()

public struct ContentView: View {
  @StateObject var server = Server()
  @State var sendPose = true
  @State var appStoreOverlayShown = false

  @ObservedObject var qrCode = AsyncInitialized {
    createQRCode("https://foxglove.dev/")
  }

  public init() {}

  public var body: some View {
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
        CardToggle(isOn: $server.sendWatchData, dashed: isAppClip) {
          Text("Heart Rate (Apple Watch)")
            .multilineTextAlignment(.center)
          if isAppClip {
            Text("Requires full app")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }.disabled(isAppClip)
          .onTapGesture {
            if isAppClip && !appStoreOverlayShown {
              appStoreOverlayShown = true
              feedbackGenerator.notificationOccurred(.warning)
            }
          }
          .appStoreOverlay(isPresented: $appStoreOverlayShown) {
            SKOverlay.AppClipConfiguration(position: .bottom)
          }
      }.padding()
    }
  }

  var serverTab: some View {
    List {
      if let port = server.port {
        Section {
          Text("Listening on \(server.address):\(port.debugDescription)")
        } header: { Text("Server") }

        Section {
          ForEach(Array(server.clientEndpointNames.enumerated()), id: \.offset) {
            Text($0.element)
          }
          if server.clientEndpointNames.isEmpty {
            Text("No clients connected")
              .foregroundColor(.gray)
          }
        } header: {
          Text("Clients")
        }

//        Section { } footer: {
//          HStack {
//            if let qrCode = qrCode.value {
//              Image(uiImage: qrCode)
//                .interpolation(.none)
//                .resizable()
//                .colorMultiply(.secondary)
//                .aspectRatio(1, contentMode: .fit)
//                .frame(width: 5 * qrCode.size.width)
//            }
//          }.frame(maxWidth: .infinity)
//        }
      }
    }
    .listStyle(.insetGrouped)
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
