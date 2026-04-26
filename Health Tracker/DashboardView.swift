import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext                       // saving and deleting data
    @EnvironmentObject var healthManager: HealthManager                         // for access to HealthKit
    @Query private var records: [DailyRecord]                                   // fetching and updating daily records
    
    @Environment(\.scenePhase) var scenePhase
    
    @State private var showingAddSheet = false
    
    // finding daily record and if not, creates a new one if non-existent
    private var todayRecord: DailyRecord {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        if let record = records.first(where: { $0.dateString == todayString }) {
            return record
        } else {
            let newRecord = DailyRecord(date: Date())
            modelContext.insert(newRecord)
            return newRecord
        }
    }
    
    // for food and water progress sections, as well as the buttons and the HealthKit data - I have added steps, heart rate, sleep and exercise times
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    DetailedProgressCardView(
                        title: "Food",
                        type: "Food",
                        current: todayRecord.totalFood,
                        goal: todayRecord.foodGoal,
                        color: .orange,
                        unit: "kcal",
                        record: todayRecord
                    )
                    
                    DetailedProgressCardView(
                        title: "Water",
                        type: "Water",
                        current: todayRecord.totalWater,
                        goal: todayRecord.waterGoal,
                        color: .blue,
                        unit: "ml",
                        record: todayRecord
                    )
                    
                    Button(action: { showingAddSheet = true }) {
                        Text("Add Intake")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HealthMetricCard(
                            icon: "shoeprints.fill",
                            color: .green,
                            title: "Steps Today",
                            value: "\(Int(healthManager.todaySteps))",
                            unit: "steps"
                        )
                        
                        HealthMetricCard(
                            icon: "flame.fill",
                            color: .red,
                            title: "Exercise Time",
                            value: "\(Int(healthManager.todayExerciseMinutes))",
                            unit: "min"
                        )
                        
                        HealthMetricCard(
                            icon: "heart.fill",
                            color: .red,
                            title: "Heart Rate",
                            value: "\(Int(healthManager.latestHeartRate))",
                            unit: "bpm"
                        )
                        
                        HealthMetricCard(
                            icon: "bed.double.fill",
                            color: .purple,
                            title: "Time in Bed",
                            value: healthManager.todaySleepFormatted,
                            unit: ""
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showingAddSheet) {
                AddEntryView(dailyRecord: todayRecord)
            }
            .onAppear {
                healthManager.fetchAllData()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    healthManager.fetchAllData()
                }
            }
            .onChange(of: healthManager.todaySteps) { _, newSteps in
                todayRecord.stepCount = newSteps
            }
            // listens for my apple watch data and updates the iOS
            .onReceive(WatchConnector.shared.$syncedFood) { newFood in
                if newFood > 0 && newFood != todayRecord.totalFood {
                    let diff = newFood - todayRecord.totalFood
                    let syncEntry = ConsumptionEntry(type: "Food", amount: diff, categoryName: "Watch Sync")
                    todayRecord.entries.append(syncEntry)
                }
            }
            .onReceive(WatchConnector.shared.$syncedWater) { newWater in
                if newWater > 0 && newWater != todayRecord.totalWater {
                    let diff = newWater - todayRecord.totalWater
                    let syncEntry = ConsumptionEntry(type: "Water", amount: diff, categoryName: "Watch Sync")
                    todayRecord.entries.append(syncEntry)
                }
            }
        }
    }
}

// for health metrics
struct HealthMetricCard: View {
    var icon: String
    var color: Color
    var title: String
    var value: String
    var unit: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title3.bold())
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// for daily progress
struct DetailedProgressCardView: View {
    var title: String
    var type: String
    var current: Double
    var goal: Double
    var color: Color
    var unit: String
    var record: DailyRecord
    
    var progress: Double { goal > 0 ? current / goal : 0 }
    
    var displayCategories: [String] {
        type == "Food" ? ["Main Meal", "Snack", "Dessert"] : ["Water", "Coffee/Tea", "Juice", "Fizzy Drink"]
    }
    
    func amount(for category: String) -> Double {
        record.entries
            .filter { $0.type == type && $0.categoryName == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: min(1.0, progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)
                
                VStack(spacing: 0) {
                    Text("\(Int(current))")
                        .font(.title2.bold())
                    Text("of \(Int(goal))\(unit)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(displayCategories, id: \.self) { cat in
                    HStack(spacing: 4) {
                        Text("\(cat):")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text("\(Int(amount(for: cat)))")
                            .font(.system(size: 13, weight: .bold))
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
