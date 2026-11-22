import Combine
import Foundation
import WatchConnectivity
import WatchKit

final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()

    @Published var isReachable: Bool = false
    @Published var isRinging: Bool = false
    @Published var quietHoursEnabled: Bool = false
    @Published var activeFaceId: String = "activity"
    @Published var stepGoal: Int = 10000
    @Published var openReminders: Int = 0
    @Published var lastAlertText: String?

    private var ringTimer: Timer?

    private override init() {
        super.init()
        WKInterfaceDevice.current().isBatteryMonitoringEnabled = true
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func sendTelemetryToPhone(steps: Int = 7842, heartRateBpm: Int = 68) {
        let device = WKInterfaceDevice.current()
        let batteryPct = device.batteryLevel >= 0 ? Int(device.batteryLevel * 100) : 85
        let isCharging = device.batteryState == .charging || device.batteryState == .full

        let payload: [String: Any] = [
            "type": "telemetry",
            "batteryPercent": batteryPct,
            "isCharging": isCharging,
            "steps": steps,
            "heartRateBpm": heartRateBpm,
        ]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil, errorHandler: nil)
        } else {
            try? WCSession.default.updateApplicationContext(payload)
        }
    }

    func stopRinging() {
        ringTimer?.invalidate()
        ringTimer = nil
        DispatchQueue.main.async {
            self.isRinging = false
        }
    }

    private func startRinging() {
        DispatchQueue.main.async {
            self.isRinging = true
            WKInterfaceDevice.current().play(.notification)
            self.ringTimer?.invalidate()
            self.ringTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }

    private func handleIncoming(_ payload: [String: Any]) {
        DispatchQueue.main.async {
            if let type = payload["type"] as? String {
                switch type {
                case "ringWatch":
                    let active = payload["active"] as? Bool ?? false
                    if active {
                        self.startRinging()
                    } else {
                        self.stopRinging()
                    }
                case "testNotification":
                    let title = payload["title"] as? String ?? "iHealthFit Alert"
                    self.lastAlertText = title
                    WKInterfaceDevice.current().play(.success)
                case "syncState":
                    self.applyContext(payload)
                default:
                    self.applyContext(payload)
                }
            } else {
                self.applyContext(payload)
            }
        }
    }

    private func applyContext(_ context: [String: Any]) {
        if let face = context["faceId"] as? String {
            activeFaceId = face
        }
        if let quiet = context["quietHoursEnabled"] as? Bool {
            quietHoursEnabled = quiet
        }
        if let goal = context["stepGoal"] as? Int {
            stepGoal = goal
        }
        if let rem = context["openReminders"] as? Int {
            openReminders = rem
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        sendTelemetryToPhone()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleIncoming(message)
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        handleIncoming(applicationContext)
    }
}
