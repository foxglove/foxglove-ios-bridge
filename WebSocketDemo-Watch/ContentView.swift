import HealthKit
import SwiftUI
import WatchConnectivity

@MainActor
class SessionManager: NSObject, ObservableObject, WCSessionDelegate {
  @Published var isRunning = false
  @Published var isReachable = false

  let session = WCSession.default
  var workoutSession: HKWorkoutSession?

  let healthStore = HKHealthStore()
  var heartRateQuery: HKAnchoredObjectQuery?

  @Published var currentHeartRate: Double?

  override init() {
    super.init()
    session.delegate = self
  }

  func toggleRunning() {
    if session.activationState == .activated {
      if isRunning {
        isRunning = false
        stopHeartRateUpdates()
      } else {
        isRunning = true
        startHeartRateUpdates()
      }
    } else {
      session.activate()
    }
  }

  nonisolated func session(
    _: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    guard activationState == .activated else {
      print("activation failed \(error)")
      return
    }
    Task { @MainActor in
      isRunning = true
      startHeartRateUpdates()
    }
  }

  nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
    Task { @MainActor in
      isReachable = session.isReachable
    }
  }

  func startHeartRateUpdates() {
    do {
      let config = HKWorkoutConfiguration()
      config.activityType = .other
      config.locationType = .unknown
      let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
      session.startActivity(with: .now)
      session.pause()
      workoutSession = session
      print("started session")
    } catch {
      print("error creating workout: \(error)")
    }
    let type = HKQuantityType(.heartRate)
    let query = HKAnchoredObjectQuery(
      type: type,
      predicate: HKQuery.predicateForSamples(withStart: .now, end: nil),
      anchor: nil,
      limit: HKObjectQueryNoLimit
    ) { _, samples, deleted, anchor, error in
      print("results: \(samples), deleted \(deleted), anchor \(anchor), error \(error)")
    }
    query.updateHandler = { [weak self] _, samples, deleted, anchor, error in
      guard let self else { return }
      print("update: \(samples), deleted \(deleted), anchor \(anchor), error \(error)")

      guard let samples else { return }
      for case let sample as HKQuantitySample in samples {
        let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        session.sendMessage(["heart_rate": bpm], replyHandler: nil)
        Task { @MainActor in
          self.currentHeartRate = bpm
        }
      }
    }

    healthStore.requestAuthorization(toShare: nil, read: [type]) { success, error in
      print("health authorization \(success)")
      if let error {
        print("health authorization error \(error)")
        return
      }
      Task { @MainActor in
        self.heartRateQuery = query
      }
      self.healthStore.execute(query)
    }
  }

  func stopHeartRateUpdates() {
    if let workoutSession {
      workoutSession.stopActivity(with: .now)
    }
    if let heartRateQuery {
      healthStore.stop(heartRateQuery)
    }
  }
}

struct ContentView: View {
  @StateObject var sessionManager = SessionManager()

  var body: some View {
    VStack {
      Button {
        sessionManager.toggleRunning()
      } label: {
        Image(systemName: sessionManager.isRunning ? "stop.circle.fill" : "play.circle.fill")
      }
      .buttonStyle(.borderless)
      .font(.system(size: 80))
      .foregroundColor(sessionManager.isRunning ? .green : .accentColor)
      if sessionManager.isRunning {
        HStack {
          if let bpm = sessionManager.currentHeartRate {
            Text("\(bpm, format: .number.precision(.fractionLength(0)))")
          } else {
            Text("–").disabled(true)
          }
          Image(systemName: "heart.fill")
            .foregroundColor(.red)
        }
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
