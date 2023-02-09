import SwiftUI

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
    }
  }
}
