import SwiftUI
import WidgetKit

enum MealType: String, CaseIterable {
    case main = "Main"
    case snack = "Snack"
    case dessert = "Dessert"
}

struct FoodControls: View {
    @Binding var consumed: Double
    let dailyGoal: Double
    let mealType: MealType
    @Environment(\.dismiss) private var dismiss
    @State private var amountToChange: Double = 20

    var body: some View {
        VStack(spacing: 14) {
            Text(mealType.rawValue)
                .font(.headline)
                .foregroundColor(.orange)

            HStack(spacing: 20) {
                Button(action: {
                    amountToChange = max(0, amountToChange - 20)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)

                Text("\(Int(amountToChange)) kcal")
                    .font(.footnote.bold())
                    .monospacedDigit()
                    .frame(width: 70)

                Button(action: {
                    amountToChange += 20
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }

            Button("Done") {
                consumed = max(0, consumed + amountToChange)
                WidgetCenter.shared.reloadAllTimelines()
                
                // sets and restarts reminder notification
                NotificationManager.shared.scheduleReminder()
                NotificationManager.shared.checkMilestones()
                
                // Beams the new food data to your iPhone
                WatchConnector.shared.syncToOtherDevice()
                
                dismiss()
            }
            .font(.caption.bold())
            .foregroundColor(.orange)
        }
        .padding()
    }
}
