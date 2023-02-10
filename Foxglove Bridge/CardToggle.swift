import SwiftUI

let feedbackGenerator = UISelectionFeedbackGenerator()

struct CardToggle<Content: View>: View {
  @Binding var isOn: Bool
  @ViewBuilder let content: () -> Content

  var body: some View {
    let color = isOn ? Color.accentColor : Color.gray.opacity(0.5)
    ZStack {
      let shape = RoundedRectangle(cornerRadius: 10)
      shape
        .stroke(color.opacity(0.5), lineWidth: 2)
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
    .aspectRatio(1, contentMode: .fit)
    .onTapGesture {
      isOn.toggle()
      feedbackGenerator.selectionChanged()
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
      CardToggle(isOn: $test) {
        Text("Hi")
      }.frame(width: 200)
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
    }
  }
}
