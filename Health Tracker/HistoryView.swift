import SwiftUI
import SwiftData

struct HistoryView: View {
    
    // to fetch daily record, from newest first at the top
    @Query(sort: \DailyRecord.date, order: .reverse) private var history: [DailyRecord]
    
    // then finds the specific record for today/present day to display at the top progress rings
    var todayRecord: DailyRecord? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        return history.first(where: { $0.dateString == todayString })
    }
    
    // main body to visualise today's progress, daily records of caloric, water intake and step count
    var body: some View {
        NavigationStack {
            List {
                if let today = todayRecord {
                    Section(header: Text("Progress Today")
                        .frame(maxWidth: .infinity, alignment: .center)) {
                        HStack {
                            Spacer()
                            ProgressRingView(
                                progress: today.foodGoal > 0 ? today.totalFood / today.foodGoal : 0,
                                color: .orange,
                                icon: "fork.knife",
                                current: today.totalFood,
                                goal: today.foodGoal,
                                unit: "kcal"
                            )
                            Spacer()
                            ProgressRingView(
                                progress: today.waterGoal > 0 ? today.totalWater / today.waterGoal : 0,
                                color: .blue,
                                icon: "drop.fill",
                                current: today.totalWater,
                                goal: today.waterGoal,
                                unit: "ml"
                            )
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .listRowBackground(Color.clear)
                    }
                }
                
                Section(header: Text("History")) {
                    if history.isEmpty {
                        Text("No data yet. Start tracking!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(history) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(record.date, format: .dateTime.month().day().year())
                                    .font(.headline)
                                
                                HStack {
                                    Label("\(Int(record.totalFood)) / \(Int(record.foodGoal)) kcal", systemImage: "flame.fill")
                                        .foregroundColor(.orange)
                                    Spacer()
                                    Label("\(Int(record.totalWater)) / \(Int(record.waterGoal)) ml", systemImage: "drop.fill")
                                        .foregroundColor(.blue)
                                }
                                .font(.subheadline)
                                
                                // Added Steps to history view
                                HStack {
                                    Label("\(Int(record.stepCount)) / \(Int(record.stepGoal)) steps", systemImage: "shoeprints.fill")
                                        .foregroundColor(.green)
                                }
                                .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}
