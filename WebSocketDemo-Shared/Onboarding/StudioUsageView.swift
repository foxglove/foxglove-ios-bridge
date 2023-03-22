import SwiftUI

struct OrbitingViews: View {
  let views: [AnyView]

  let itemSize: Double = 50
  let radius: Double = 80
  let rotationsPerSecond: Double = 0.08
  let wobblesPerSecond: Double = 0.1

  @State var startDate = Date.now

  var body: some View {
    TimelineView(.animation) { timeline in
      let time = timeline.date.timeIntervalSince(startDate)
      let wobbleAmount: Double = sin(.pi * time * wobblesPerSecond)
      let tiltAngle: Double = .pi * (0.5 + 0.1 * wobbleAmount)
      ZStack {
        ForEach(Array(views.enumerated()), id: \.offset) { (offset: Int, element: AnyView) in
          let phase: Double = 2 * .pi * (time * rotationsPerSecond + Double(offset) / Double(views.count))
          let x: Double = radius * cos(phase)
          let y: Double = radius * sin(phase)
          let depth: Double = sin(tiltAngle) * sin(phase)
          let perspective: Double = 0.3
          let scale: Double = 1 + depth * perspective
          element
            .frame(width: itemSize, height: itemSize)
            .scaleEffect(scale, anchor: .center)
            .transformEffect(
              .identity
                .translatedBy(x: x, y: y * cos(tiltAngle))
            )
            .zIndex(depth)
            .opacity(0.8 + 0.3 * depth)
        }
      }
    }
    .frame(width: radius + itemSize / 2.0, height: radius + itemSize / 2.0)
  }
}

func resizableImage(systemName: String, color: Color, renderingMode: SymbolRenderingMode = .hierarchical) -> some View {
  Image(systemName: systemName)
    .resizable()
    .scaledToFit()
    .symbolRenderingMode(renderingMode)
    .foregroundColor(color)
}

struct StudioUsageView: View {
  @ScaledMetric var bulletSize = 30

  let deviceModel = UIDevice.current.model

  var body: some View {
    OnboardingStepWrapper {
      VStack {
        Spacer(minLength: 0)
        OrbitingViews(views: [
          AnyView(resizableImage(systemName: "cube.transparent", color: .orange)),
          AnyView(resizableImage(systemName: "photo", color: .green)),
          AnyView(resizableImage(systemName: "mappin.and.ellipse", color: .red)),
          AnyView(resizableImage(systemName: "chart.xyaxis.line", color: .blue)),
          AnyView(resizableImage(systemName: "note.text", color: .gray, renderingMode: .monochrome)),
        ])

        Spacer(minLength: 20).fixedSize()

        Text("Enjoy your visualizations!")
          .fixedHeight()
          .font(.largeTitle)
          .fontWeight(.heavy)

        Spacer(minLength: 32).fixedSize()

        Text("""
Try out Foxglove Studio’s **3D**, **Image**, and **Map** panels to visualize the sensor data from your \(deviceModel).

For more information, visit https://foxglove.dev/docs/studio.
""")

        Spacer(minLength: 30)
        ContinueButton("Done")
      }
    }
  }
}

struct StudioUsageView_Previews: PreviewProvider {
  static var previews: some View {
    StudioUsageView()
  }
}
