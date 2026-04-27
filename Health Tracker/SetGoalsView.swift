import SwiftUI
import SwiftData

struct SetGoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [DailyRecord]
    
    @AppStorage("step_daily_goal", store: UserDefaults(suiteName: "group.com.philreddy.foodwatertracker"))
    private var globalStepGoal: Double = 10000
    
    @State private var foodGoal: Double = 2000
    @State private var waterGoal: Double = 2000
    @State private var stepGoal: Double = 10000
    
    // alert state Variables
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Daily Targets")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 15)
                ) {
                    Stepper("Calories: \(Int(foodGoal)) kcal", value: $foodGoal, in: 500...10000, step: 100)
                    Stepper("Water: \(Int(waterGoal)) ml", value: $waterGoal, in: 500...8000, step: 100)
                    Stepper("Steps: \(Int(stepGoal)) steps", value: $stepGoal, in: 1000...50000, step: 500)
                }
                
                HStack {
                    Spacer()
                    Button("Save Goals") {
                        checkAndSaveGoals()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .cornerRadius(10)
                    .buttonStyle(.borderless)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .padding(.top, -15)
            }
            .navigationTitle("Set Goals")
            .onAppear(perform: loadCurrentGoals)
            // target warning if the set goal is too low or too high compared to the recommended intake or goals
            .alert("Target Warning", isPresented: $showingAlert) {
                Button("Continue", role: .destructive) {
                    saveGoals()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadCurrentGoals() {
        stepGoal = globalStepGoal
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        if let today = records.first(where: { $0.dateString == todayString }) {
            foodGoal = today.foodGoal
            waterGoal = today.waterGoal
            stepGoal = today.stepGoal
        }
    }
    
    // to check limits if they are too low or too high
    private func checkAndSaveGoals() {
        var calWarning = ""
        if foodGoal < 1800 { calWarning = "below the recommended daily caloric" }
        else if foodGoal > 3200 { calWarning = "above the recommended daily caloric" }
        
        var waterWarning = ""
        if waterGoal < 2000 { waterWarning = "below the recommended daily water" }
        else if waterGoal > 3000 { waterWarning = "above the recommended daily water" }
        
        var combined = ""
        if !calWarning.isEmpty && !waterWarning.isEmpty {
            combined = "\(calWarning) and \(waterWarning)"
        } else {
            combined = calWarning + waterWarning
        }
        
        if combined.isEmpty {
            // if limits are fine, save immediately
            saveGoals()
        } else {
            // if limits are exceeded, show popup
            alertMessage = "You are going \(combined) intake. Would you like to continue?"
            showingAlert = true
        }
    }
    
    private func saveGoals() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        if let today = records.first(where: { $0.dateString == todayString }) {
            today.foodGoal = foodGoal
            today.waterGoal = waterGoal
            today.stepGoal = stepGoal
        }
        
        let defaults = UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")
        defaults?.set(foodGoal, forKey: "food_daily_goal")
        defaults?.set(waterGoal, forKey: "water_daily_goal")
        
        globalStepGoal = stepGoal
        
        // to trigger a notification reschedule so the new goals are reflected
        NotificationManager.shared.scheduleReminder()
        
        // beams new goals to watch
        WatchConnector.shared.syncToOtherDevice()
    }
}
