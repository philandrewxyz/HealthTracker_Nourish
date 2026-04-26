import Foundation
import SwiftData

@Model
class DailyRecord {
    @Attribute(.unique) var dateString: String // format of yyyy-mm-dd
    var date: Date
    
    // daily targets of user
    var foodGoal: Double
    var waterGoal: Double
    var stepGoal: Double // historic step goals (if they change)
    var stepCount: Double = 0.0 // total steps tracked today
    
    @Relationship(deleteRule: .cascade, inverse: \ConsumptionEntry.dailyRecord)
    var entries: [ConsumptionEntry] = []
    
    // initialise new day with default goals (recommended daily intake and goal)
    init(date: Date, foodGoal: Double = 2000, waterGoal: Double = 2000, stepGoal: Double = 10000) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateString = formatter.string(from: date)
        self.date = date
        self.foodGoal = foodGoal
        self.waterGoal = waterGoal
        self.stepGoal = stepGoal
    }
    
    var totalFood: Double {
        entries.filter { $0.type == "Food" }.reduce(0) { $0 + $1.amount }
    }
    
    var totalWater: Double {
        entries.filter { $0.type == "Water" }.reduce(0) { $0 + $1.amount }
    }
}

@Model
class ConsumptionEntry {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var type: String // "Food" or "Water"
    var amount: Double
    var categoryName: String    // for Coffee/Tea, Snack, Main Meal, etc.
    
    var dailyRecord: DailyRecord?
    
    init(type: String, amount: Double, categoryName: String) {
        self.type = type
        self.amount = amount
        self.categoryName = categoryName
    }
}

@Model
class Category {
    @Attribute(.unique) var name: String
    var type: String // "Food" or "Water"
    
    init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}
