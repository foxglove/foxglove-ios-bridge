import SwiftUI

enum OnboardingStep {
  case connection
  case studioUsage
}

struct OnboardingView: View {
  let isConnected: Bool
  let serverURL: String

  @Environment(\.dismiss) var dismiss

  @State var path: [OnboardingStep] = []

  var body: some View {
    NavigationStack(path: $path) {
      IntroView()
        .onContinue {
          path.append(.connection)
        }
        .navigationDestination(for: OnboardingStep.self) {
          switch $0 {
          case .connection:
            ConnectionView(isConnected: isConnected, serverURL: serverURL)
              .onContinue {
                path.append(.studioUsage)
              }
          case .studioUsage:
            StudioUsageView()
              .onContinue {
                dismiss()
              }
          }
        }
    }
  }
}

struct OnboardingStepWrapper<Content: View>: View {
  @ViewBuilder let content: () -> Content

  init(content: @escaping () -> Content) {
    self.content = content
  }

  @ScaledMetric var maxWidth = 500.0

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        content()
          .frame(maxWidth: maxWidth, alignment: .center)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
          .padding(.bottom, 32)
        // Ensure the content takes up at least one full page in the scroll view
          .frame(maxWidth: .infinity, minHeight: proxy.size.height)
      }
    }
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView(isConnected: true, serverURL: "ws://192.168.1.2:12346")
      .previewDevice("iPhone 13 mini")
    OnboardingView(isConnected: true, serverURL: "ws://192.168.1.2:12346")
      .previewDevice("iPhone 14 Plus")
    OnboardingView(isConnected: true, serverURL: "ws://192.168.1.2:12346")
      .previewDevice("iPad Pro (12.9-inch) (6th generation)")
  }
}
