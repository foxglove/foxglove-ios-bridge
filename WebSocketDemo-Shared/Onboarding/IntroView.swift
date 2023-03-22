import SwiftUI

fileprivate class Dummy {}

extension Text {
  // https://stackoverflow.com/a/64731044/23649
  func fixedHeight() -> some View {
    self.fixedSize(horizontal: false, vertical: true)
  }
}

struct FeatureRow: View {
  let imageSystemName: String
  let imageColor: Color
  let title: String
  let subtitle: String

  @ScaledMetric var imageSize = 40

  var body: some View {
    HStack {
      Image(systemName: imageSystemName)
        .symbolRenderingMode(.hierarchical)
        .font(.system(size: imageSize))
        .foregroundColor(imageColor)
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
        Text(subtitle)
          .fixedHeight()
          .foregroundColor(.secondary)
      }
    }
    .multilineTextAlignment(.leading)
  }
}

struct IntroView: View {
  let deviceModel = UIDevice.current.model

  var body: some View {
    OnboardingStepWrapper {
      VStack(alignment: .center, spacing: 0) {
        Spacer(minLength: 0)
        HStack(alignment: .center) {
          Text("🤖")
            .font(.system(size: 60))
            .padding(.bottom, 5)
          Image(systemName: "dot.radiowaves.right")
            .font(.system(size: 30))
            .opacity(0.3)
            .padding(.leading, 10)
            .padding(.trailing, 18)
          Image("studio-logo", bundle: Bundle(for: Dummy.self))
            .resizable()
            .frame(width: 50, height: 50)
        }

        Text("Get started with Foxglove Studio")
          .fixedHeight()
          .font(.largeTitle)
          .fontWeight(.heavy)

        Spacer(minLength: 16).fixedSize()
        Text("""
This app streams sensor data to Foxglove Studio via a WebSocket connection. Your \(deviceModel) acts like a “robot” by capturing data from its built-in sensors and internal state.
""")
        .fixedHeight()
        .lineSpacing(4)

        Spacer(minLength: 32).fixedSize()

        VStack(alignment: .leading, spacing: 20) {
          FeatureRow(
            imageSystemName: "move.3d",
            imageColor: .orange,
            title: "Pose",
            subtitle: "See device orientation in 3D space"
          )
          FeatureRow(
            imageSystemName: "location",
            imageColor: .blue,
            title: "Location",
            subtitle: "View GPS coordinates on a map"
          )
          FeatureRow(
            imageSystemName: "camera.viewfinder",
            imageColor: .green,
            title: "Camera images",
            subtitle: "See a live feed from front or rear cameras"
          )
        }

        Spacer(minLength: 32)

        ContinueButton("Get Started")
      }
    }
  }
}

struct IntroView_Previews: PreviewProvider {
  static var previews: some View {
    IntroView()
      .previewDevice("iPhone 13 mini")
  }
}
