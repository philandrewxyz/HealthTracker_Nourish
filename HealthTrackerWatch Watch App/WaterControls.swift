import SwiftUI
import WidgetKit

struct WaterControls: View {
    @Binding var consumed: Double
    let dailyGoal: Double
    @Environment(\.dismiss) private var dismiss
    @State private var amountToChange: Double = 20

    var body: some View {
        VStack(spacing: 14) {
            Text("Add Water (in ml)")
                .font(.headline)
                .foregroundColor(.blue)

            HStack(spacing: 20) {
                Button(action: {
                    amountToChange = max(0, amountToChange - 20)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)

                Text("\(Int(amountToChange)) ml")
                    .font(.footnote.bold())
                    .monospacedDigit()
                    .frame(width: 70)

                Button(action: {
                    amountToChange += 20
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }

            Button("Done") {
                consumed = max(0, consumed + amountToChange)
                WidgetCenter.shared.reloadAllTimelines()
                
                // restarts reminders and checks if goals have been achieved
                NotificationManager.shared.scheduleReminder()
                NotificationManager.shared.checkMilestones()
                
                // beams new water data to iPhone
                WatchConnector.shared.syncToOtherDevice()
                
                dismiss()
            }
            .font(.caption.bold())
            .foregroundColor(.blue)
        }
        .padding()
    }
}
