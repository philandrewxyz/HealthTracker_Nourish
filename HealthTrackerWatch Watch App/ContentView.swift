import SwiftUI
import WidgetKit

struct ContentView: View {
    @AppStorage("saved_food_consumed", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var foodConsumed: Double = 0.0

    @AppStorage("saved_water_consumed", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var waterConsumed: Double = 0.0

    @AppStorage("food_daily_goal", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var foodGoal: Double = 2000

    @AppStorage("water_daily_goal", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var waterGoal: Double = 2000

    @AppStorage("last_reset_date", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var lastResetDate: Double = Date().timeIntervalSince1970
    
    @Environment(\.scenePhase) var scenePhase

    var foodProgress: Double { foodGoal > 0 ? foodConsumed / foodGoal : 0 }
    var waterProgress: Double { waterGoal > 0 ? waterConsumed / waterGoal : 0 }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<23: return "Good evening"
        default: return "Good night"
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                    .padding(.leading, 10)
                Text("Here's your progress today:")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.leading, 10)
            }

            HStack(spacing: 24) {
                NavigationLink(destination: FoodScreen()) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle().stroke(Color.gray.opacity(0.15), lineWidth: 5)
                            Circle()
                                .trim(from: 0, to: min(1.0, foodProgress))
                                .stroke(Color.orange, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(), value: foodProgress)
                            VStack(spacing: 1) {
                                Text("\(Int(foodProgress * 100))%")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.orange)
                                Text("\(Int(foodConsumed))kcal")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 85, height: 85)
                        Text("Food")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)

                NavigationLink(destination: WaterScreen()) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle().stroke(Color.gray.opacity(0.15), lineWidth: 5)
                            Circle()
                                .trim(from: 0, to: min(1.0, waterProgress))
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(), value: waterProgress)
                            VStack(spacing: 1) {
                                Text("\(Int(waterProgress * 100))%")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                Text("\(Int(waterConsumed))ml")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 85, height: 85)
                        Text("Water")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                NavigationLink(destination: HistoryView()) {
                    Text("History")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                NavigationLink(destination: SetGoalsView()) {
                    Text("Set Goals")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
            checkAndResetDailyGoals()
            
            _ = WatchConnector.shared
            
            if foodGoal == 0 { foodGoal = 2000 }
            if waterGoal == 0 { waterGoal = 2000 }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                checkAndResetDailyGoals()
            }
        }
        // UI refreshes when iPhone syncs new data
        .onReceive(WatchConnector.shared.$syncedFood) { self.foodConsumed = $0 }
        .onReceive(WatchConnector.shared.$syncedWater) { self.waterConsumed = $0 }
        .onReceive(WatchConnector.shared.$syncedFoodGoal) { self.foodGoal = $0 }
        .onReceive(WatchConnector.shared.$syncedWaterGoal) { self.waterGoal = $0 }
    }
    
    private func checkAndResetDailyGoals() {
        let lastDate = Date(timeIntervalSince1970: lastResetDate)
        if !Calendar.current.isDateInToday(lastDate) {
            HistoryManager.shared.saveRecord(date: lastDate, food: foodConsumed, water: waterConsumed)
            foodConsumed = 0.0
            waterConsumed = 0.0
            lastResetDate = Date().timeIntervalSince1970
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
