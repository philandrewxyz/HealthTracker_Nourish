import SwiftUI
import WidgetKit

struct WaterControlsView: View {
    @AppStorage("saved_water_consumed", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var consumed: Double = 0.0

    @AppStorage("water_daily_goal", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var dailyGoal: Double = 2000

    var progress: Double { consumed / dailyGoal }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(1.0, progress))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)
                VStack(spacing: 2) {
                    Text("\(Int(consumed))")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("/ \(Int(dailyGoal)) ml")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)

            Text("\(Int(progress * 100))% of daily goal")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            NavigationLink("Add Water") {
                WaterControls(consumed: $consumed, dailyGoal: dailyGoal)
            }
            .font(.caption.bold())
            .foregroundColor(.blue)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        WaterControlsView()
    }
}
