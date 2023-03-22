import SwiftUI

private struct OnContinueKey: EnvironmentKey {
  static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
  var onContinue: () -> Void {
    get { self[OnContinueKey.self] }
    set { self[OnContinueKey.self] = newValue }
  }
}

extension View {
  func onContinue(_ action: @escaping () -> Void) -> some View {
    self.environment(\.onContinue, action)
  }
}

struct ContinueButton<Label: View>: View {
  @Environment(\.onContinue) var continueAction

  let label: () -> Label
  let bordered: Bool
  init(bordered: Bool = true, @ViewBuilder _ label: @escaping () -> Label) {
    self.label = label
    self.bordered = bordered
  }

  var body: some View {
    if bordered {
      button.buttonStyle(.borderedProminent)
    } else {
      button.buttonStyle(.borderless)
    }
  }

  @ViewBuilder
  var button: some View {
    Button {
      continueAction()
    } label: {
      label()
        .fontWeight(.medium)
        .padding(.vertical, 12)
        .frame(maxWidth: bordered ? .infinity : nil)
    }
  }
}

extension ContinueButton<Text> {
  init(_ text: String) {
    self.init {
      Text(text)
    }
  }
}

struct ContinueButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ContinueButton("Get Started")
      ContinueButton(bordered: false) {
        Text("Not Now")
      }
    }
  }
}
