import WidgetKit
import SwiftUI

struct FoodWaterEntry: TimelineEntry {
    let date: Date
    let foodConsumed: Double
    let waterConsumed: Double
    let foodGoal: Double
    let waterGoal: Double
}

struct Provider: TimelineProvider {
    let appGroupID = "group.com.philreddy.foodwatertracker"
    
    func currentEntry() -> FoodWaterEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        return FoodWaterEntry(
            date: Date(),
            foodConsumed: defaults?.double(forKey: "saved_food_consumed") ?? 0,
            waterConsumed: defaults?.double(forKey: "saved_water_consumed") ?? 0,
            foodGoal: defaults?.double(forKey: "food_daily_goal") ?? 2000,
            waterGoal: defaults?.double(forKey: "water_daily_goal") ?? 2000
        )
    }

    func placeholder(in context: Context) -> FoodWaterEntry { currentEntry() }
    func getSnapshot(in context: Context, completion: @escaping (FoodWaterEntry) -> Void) { completion(currentEntry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<FoodWaterEntry>) -> Void) {
        let timeline = Timeline(entries: [currentEntry()], policy: .atEnd)
        completion(timeline)
    }
}

struct FoodWaterWidgetEntryView: View {
    var entry: FoodWaterEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading, spacing: 10) {
                Text("Today")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "fork.knife").foregroundColor(.orange)
                        Text("\(Int(entry.foodConsumed)) / \(Int(entry.foodGoal))")
                            .font(.system(size: 14, weight: .bold))
                    }
                    HStack {
                        Image(systemName: "drop.fill").foregroundColor(.blue)
                        Text("\(Int(entry.waterConsumed)) / \(Int(entry.waterGoal))")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }
            .padding()
            
        case .systemMedium:
            HStack {
                VStack(alignment: .leading) {
                    Text("Daily Progress")
                        .font(.headline)
                    Spacer()
                    HStack {
                        Image(systemName: "fork.knife").foregroundColor(.orange)
                        Text("\(Int(entry.foodConsumed)) / \(Int(entry.foodGoal)) kcal")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "drop.fill").foregroundColor(.blue)
                        Text("\(Int(entry.waterConsumed)) / \(Int(entry.waterGoal)) ml")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
        default:
            Text("Unsupported Size")
        }
    }
}

struct FoodWaterWidget: Widget {
    let kind: String = "FoodWaterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FoodWaterWidgetEntryView(entry: entry)
                .containerBackground(Color(UIColor.systemBackground), for: .widget)
        }
        .configurationDisplayName("Food & Water")
        .description("Track your daily consumption.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
