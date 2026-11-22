import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: WatchSessionManager

    private let lynioTeal = Color(red: 0.110, green: 0.643, blue: 0.557)

    var body: some View {
        NavigationStack {
            if session.isRinging {
                VStack(spacing: 12) {
                    Image(systemName: "bell.and.waves.left.and.right.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(.orange)
                    Text("Find My Watch")
                        .font(.headline)
                    Button("Stop Ringing", role: .destructive) {
                        session.stopRinging()
                    }
                }
                .padding()
            } else {
                List {
                    Section {
                        HStack {
                            Circle()
                                .fill(session.isReachable ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                            Text(session.isReachable ? "iPhone Connected" : "Background Sync")
                                .font(.footnote.bold())
                        }
                        if let alert = session.lastAlertText {
                            Label(alert, systemImage: "bell.badge.fill")
                                .font(.caption)
                                .foregroundStyle(lynioTeal)
                        }
                    }

                    Section("Synced from iPhone") {
                        LabeledContent("Face", value: session.activeFaceId.capitalized)
                        LabeledContent("Step Goal", value: "\(session.stepGoal)")
                        LabeledContent("Reminders", value: "\(session.openReminders)")
                        LabeledContent(
                            "Quiet Hours",
                            value: session.quietHoursEnabled ? "On" : "Off"
                        )
                    }

                    Section {
                        Button {
                            session.sendTelemetryToPhone()
                        } label: {
                            Label("Sync Battery & Health", systemImage: "arrow.triangle.2.circlepath")
                                .foregroundStyle(lynioTeal)
                        }
                    }
                }
                .navigationTitle("iHealthFit")
            }
        }
    }
}
