import SwiftUI

struct ConnectionView: View {
  let isConnected: Bool
  let serverURL: String

  let deviceModel = UIDevice.current.model

  @ScaledMetric var bulletSize = 30

  @ViewBuilder
  var icon: some View {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
      Image(systemName: "laptopcomputer.and.iphone")
    case .pad:
      Image(systemName: "laptopcomputer.and.ipad")
    default:
      Image(systemName: "laptopcomputer")
    }
  }

  @ViewBuilder
  var buttons: some View {
    if isConnected {
      Label("Connected", systemImage: "network")
        .fontWeight(.medium)
        .foregroundColor(.green)
    } else {
      ContinueButton(bordered: false) {
        Text("Skip For Now")
          .fontWeight(.medium)
      }
    }
    ContinueButton {
      if isConnected {
        Text("Done")
      } else {
        HStack(spacing: 10) {
          ProgressView()
          Text("Connecting…")
        }
      }
    }
      .disabled(!isConnected)
  }

  var body: some View {
    OnboardingStepWrapper {
      VStack {
        Spacer(minLength: 0)
        HStack(alignment: .center) {
          icon
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(.accentColor)
            .font(.system(size: 60))
        }

        Spacer(minLength: 20).fixedSize()

        Text("Connect \(deviceModel) to Foxglove Studio")
          .fixedHeight()
          .font(.largeTitle)
          .fontWeight(.heavy)

        Spacer(minLength: 32).fixedSize()

        VStack(alignment: .leading, spacing: 20) {
          HStack(alignment: .center) {
            Image(systemName: "1.circle")
              .foregroundColor(.secondary)
              .font(.system(size: bulletSize))
            Text("On your computer, visit https://studio.foxglove.dev. Google Chrome is recommended.")
          }
          HStack(alignment: .center) {
            Image(systemName: "2.circle")
              .foregroundColor(.secondary)
              .font(.system(size: bulletSize))
            Text("Click “Open connection”, then choose “Foxglove WebSocket”.")
          }
          HStack(alignment: .center) {
            Image(systemName: "3.circle")
              .foregroundColor(.secondary)
              .font(.system(size: bulletSize))
            Text("Enter the following WebSocket URL:")
          }

          Text(serverURL)
            .font(.title2)
            .monospaced()
            .tracking(-0.7)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .textSelection(.enabled)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)

          HStack(alignment: .top) {
            Image(systemName: "4.circle")
              .foregroundColor(.secondary)
              .font(.system(size: bulletSize))
            VStack(alignment: .leading, spacing: 6) {
              Text("Click the \(Image(systemName: "shield.lefthalf.filled")) icon in the address bar, then click “Load Unsafe Scripts”.")
              Text("This setting allows a “`https://`” page to connect to a “`ws://`” URL.")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
        }
        .multilineTextAlignment(.leading)

        Spacer(minLength: 30)
        buttons
      }
    }
  }
}

struct ConnectionView_Previews: PreviewProvider {
  static var previews: some View {
    ConnectionView(isConnected: true, serverURL: "ws://192.168.255.255:23456")
      .previewDisplayName("Connected v4")
    ConnectionView(isConnected: false, serverURL: "ws://192.168.255.255:23456")
      .previewDisplayName("Not connected v4")
    ConnectionView(isConnected: false, serverURL: "ws://[ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff]:23456")
      .previewDisplayName("Not connected v6")
    ConnectionView(isConnected: false, serverURL: "ws://[ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff]:23456")
      .previewDisplayName("Not connected v6 iPad")
      .previewDevice("iPad Pro (12.9-inch) (6th generation)")
  }
}
