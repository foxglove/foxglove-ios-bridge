import Charts
import SwiftUI

protocol UsageDatum: Encodable, Identifiable {
  var usage: Double { get }
  var date: Date { get }
}

class UsageHistory<T: UsageDatum>: ObservableObject {
  private var allValues: [T] = []

  func clear() {
    objectWillChange.send()
    allValues.removeAll()
  }

  func append(_ datum: T) {
    objectWillChange.send()
    allValues.append(datum)
    if allValues.count > 30 {
      allValues.removeFirst(10)
    }
  }

  var values: ArraySlice<T> {
    return allValues.suffix(20)
  }
}

struct UsageChartInner<T: UsageDatum>: View {
  @ObservedObject var history: UsageHistory<T>

  var body: some View {
    Chart(history.values) {
      LineMark(
        x: .value("Time", $0.date),
        y: .value("Usage", $0.usage)
      )
    }
  }
}

/// A chart of historical data over time, wrapped in a separate component to avoid the re-rendering parent when values change
struct UsageChart<T: UsageDatum>: View {
  var history: UsageHistory<T>

  var body: some View {
    UsageChartInner(history: history)
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
