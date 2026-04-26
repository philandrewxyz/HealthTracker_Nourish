import Foundation

struct DailyRecord: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let food: Double
    let water: Double
}

class HistoryManager {
    static let shared = HistoryManager()
    private let appGroupID = "group.com.philreddy.foodwatertracker"
    private let historyKey = "saved_history_records"

    func getHistory() -> [DailyRecord] {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: historyKey),
              let records = try? JSONDecoder().decode([DailyRecord].self, from: data) else {
            return []
        }
        return records
    }

    func saveRecord(date: Date, food: Double, water: Double) {
        var records = getHistory()
        
        // adds new record to history
        records.append(DailyRecord(date: date, food: food, water: water))
        
        // to keep only the last 7 days, saving space and minimal
        if records.count > 7 {
            records = Array(records.suffix(7))
        }

        // saves it back to UserDefaults
        if let defaults = UserDefaults(suiteName: appGroupID),
           let encoded = try? JSONEncoder().encode(records) {
            defaults.set(encoded, forKey: historyKey)
        }
    }
}
