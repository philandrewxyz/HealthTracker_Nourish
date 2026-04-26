import SwiftUI
import WidgetKit

struct SetGoalsView: View {
    @AppStorage("food_daily_goal", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    var foodGoal: Double = 2000

    @AppStorage("water_daily_goal", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    var waterGoal: Double = 2000

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    Text("Calorie Goal")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.orange)

                    HStack(spacing: 12) {
                        Button(action: { foodGoal = max(100, foodGoal - 100) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)

                        Text("\(Int(foodGoal)) kcal")
                            .font(.system(size: 11, weight: .bold))
                            .monospacedDigit()
                            .frame(width: 70)

                        Button(action: { foodGoal += 100 }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider()

                VStack(spacing: 6) {
                    Text("Water Goal")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.blue)

                    HStack(spacing: 12) {
                        Button(action: { waterGoal = max(100, waterGoal - 100) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)

                        Text("\(Int(waterGoal)) ml")
                            .font(.system(size: 11, weight: .bold))
                            .monospacedDigit()
                            .frame(width: 70)

                        Button(action: { waterGoal += 100 }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.green)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button("Save") {
                    WidgetCenter.shared.reloadAllTimelines()
                    dismiss()
                }
                .font(.caption.bold())
                .foregroundColor(.green)
            }

            Spacer(minLength: 0)
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        SetGoalsView()
    }
}
