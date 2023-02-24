import SwiftUI

private let feedbackGenerator = UISelectionFeedbackGenerator()

struct CardToggle<Content: View>: View {
  @Binding var isOn: Bool
  let dashed: Bool
  @ViewBuilder let content: () -> Content

  @Environment(\.isEnabled) var isEnabled

  internal init(isOn: Binding<Bool>, dashed: Bool = false, @ViewBuilder content: @escaping () -> Content) {
    self._isOn = isOn
    self.dashed = dashed
    self.content = content
  }

  var body: some View {
    let color = isOn ? Color.accentColor : Color.gray.opacity(0.5)
    ZStack {
      let shape = RoundedRectangle(cornerRadius: 10)
      shape
        .stroke(
          color.opacity(0.5),
          style: StrokeStyle(
            lineWidth: 2,
            dash: dashed ? [20, 5] : []
          )
        )
        .background(
          shape.fill(color.opacity(0.05))
        )
      VStack {
        content()
      }
    }
    .overlay(alignment: .topLeading) {
      Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
        .foregroundColor(color)
        .padding(10)
        .font(.system(size: 24))
    }
    .opacity(isEnabled ? 1 : 0.6)
    .aspectRatio(1, contentMode: .fit)
    .onTapGesture {
      if isEnabled {
        isOn.toggle()
        feedbackGenerator.selectionChanged()
      }
    }
  }
}

struct CardToggle_Previews: PreviewProvider {
  static var previews: some View {
    Preview()
  }

  struct Preview: View {
    @State var test = false
    @State var test2 = 1

    var body: some View {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20)]) {
        CardToggle(isOn: $test) {
          Text("Hi")
        }
        .overlay(alignment: .bottom) {
          Picker(selection: $test2) {
            Text("one").tag(1)
            Text("two").tag(2)
            Text("three").tag(3)
          } label: {
            Text("hi")
          }
          .pickerStyle(.segmented)
          .padding()
        }

        CardToggle(isOn: $test, dashed: true) {
          Text("Hi")
        }

        CardToggle(isOn: $test, dashed: true) {
          Text("Hi")
        }.disabled(true)
      }
      .padding()
    }
  }
}
