import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let defaults = UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), food: 1200, foodGoal: 2000, water: 1500, waterGoal: 2000, steps: 5400, stepGoal: 10000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), food: 1200, foodGoal: 2000, water: 1500, waterGoal: 2000, steps: 5400, stepGoal: 10000)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // fetch live data from the main iOS app
        let food = defaults?.double(forKey: "saved_food_consumed") ?? 0
        let foodGoal = defaults?.double(forKey: "food_daily_goal") ?? 2000
        let water = defaults?.double(forKey: "saved_water_consumed") ?? 0
        let waterGoal = defaults?.double(forKey: "water_daily_goal") ?? 2000
        let steps = defaults?.double(forKey: "saved_steps_count") ?? 0
        let stepGoal = defaults?.double(forKey: "step_daily_goal") ?? 10000

        let entry = SimpleEntry(date: Date(), food: food, foodGoal: foodGoal, water: water, waterGoal: waterGoal, steps: steps, stepGoal: stepGoal)

        // refreshes when an entry is added and checks every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let food: Double
    let foodGoal: Double
    let water: Double
    let waterGoal: Double
    let steps: Double
    let stepGoal: Double
}

struct HealthTrackerWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // food, water and step count display
            WidgetRow(icon: "flame.fill", color: .orange, title: "Food", current: entry.food, unit: "kcal")
            WidgetRow(icon: "drop.fill", color: .blue, title: "Water", current: entry.water, unit: "ml")
            WidgetRow(icon: "shoeprints.fill", color: .green, title: "Steps", current: entry.steps, unit: "steps")
        }
        .containerBackground(Color(UIColor.systemBackground), for: .widget)
    }
}

struct WidgetRow: View {
    var icon: String
    var color: Color
    var title: String
    var current: Double
    var unit: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.body)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // displays current numbers in kcal, ml or steps
                Text("\(Int(current)) \(unit)")
                    .font(.caption)
                    .bold()
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
        }
    }
}

struct HealthTrackerWidget: Widget {
    let kind: String = "HealthTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HealthTrackerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Tracker")
        .description("Keep an eye on your live calories, water, and steps.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
