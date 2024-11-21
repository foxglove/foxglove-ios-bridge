import Charts
import StoreKit
import SwiftUI

private let isAppClip = Bundle.main.bundleIdentifier?.hasSuffix("appclip") ?? false
private let feedbackGenerator = UINotificationFeedbackGenerator()

enum Tab: String {
  case topics
  case server
}

public struct ContentView: View {
  @StateObject var server = Server()
  @State var sendPose = true
  @State var appStoreOverlayShown = false

  @AppStorage("foxglove.onboarding-completed")
  var onboardingCompleted = false

  @State var onboardingShown = false

  @AppStorage("foxglove.selected-tab")
  var selectedTab = Tab.topics

  public init() {}

  public var body: some View {
    TabView(selection: $selectedTab) {
      topicsTab
        .tabItem {
          Image(systemName: "fibrechannel")
          Text("Topics")
        }
        .tag(Tab.topics)

      serverTab
        .tabItem {
          Image(systemName: "network")
          Text("Server")
        }
        .tag(Tab.server)
    }
    .onAppear {
      onboardingShown = !onboardingCompleted
    }
    .sheet(isPresented: $onboardingShown) {
      onboardingCompleted = true
    } content: {
      OnboardingView(
        isConnected: !server.clientEndpointNames.isEmpty,
        serverURL: server.addresses.first.flatMap {
          guard let port = server.actualPort else {
            return nil
          }
          return "ws://\($0.withoutInterface.urlString):\(port)"
        } ?? "No interfaces :("
      )
      .interactiveDismissDisabled()
    }
  }

  var topicsTab: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20)], spacing: 20) {
        CardToggle(isOn: $server.sendPose) {
          Text("Pose")
        }
        CardToggle(isOn: $server.sendLocation) {
          Text("GPS")
          if !server.hasLocationPermission {
            Text("Permission required")
              .font(.footnote)
              .foregroundColor(.secondary)
          }
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
          if !server.hasCameraPermission {
            Text("Permission required")
              .font(.footnote)
              .foregroundColor(.secondary)
          }
          if server.sendCamera {
            Text("Dropped frames: \(server.droppedVideoFrames)")
              .font(.caption)
            if let cameraError = server.cameraError {
              Text(cameraError.localizedDescription)
                .foregroundStyle(.red)
                .font(.caption2)
            }
          }
        }
        .overlay(alignment: .bottom) {
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
        .overlay(alignment: .topTrailing) {
          if server.sendCamera {
            Picker("Compression", selection: $server.compressionMode) {
              ForEach(CompressionMode.allCases) { mode in
                Label(mode.description, systemImage: mode == .JPEG ? "photo.stack" : "film.stack")
                .tag(mode)
              }
            }
            .pickerStyle(.menu)
            .labelStyle(.iconOnly)
            .padding(.top, 6)
          }
        }
        /*
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
          */
      }.padding()
    }
  }

  var serverTab: some View {
    List {
      if let port = server.actualPort {
        Section {
          let addrs = Array(server.addresses.enumerated())
          ForEach(addrs, id: \.offset) { _, addr in
            IPAddressRow(address: addr, port: port)
          }
        } header: {
          Text(server.addresses.count == 1 ? "Server address" : "Server addresses")
        }

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

        Section {
          Button("Show Tutorial") {
            onboardingShown = true
          }
        } header: {
          Text("Help")
        } footer: {
          let info = Bundle.main.infoDictionary
          if let version = info?["CFBundleShortVersionString"] as? String,
             let build = info?["CFBundleVersion"] as? String
          {
            Text("Version \(version) (\(build))")
              .frame(maxWidth: .infinity)
          }
        }
      }
    }
    .listStyle(.insetGrouped)
  }

  var cpuChart: some View {
    UsageChart(history: server.cpuHistory)
  }

  var memoryChart: some View {
    UsageChart(history: server.memHistory)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
