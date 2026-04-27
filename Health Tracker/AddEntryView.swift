import SwiftUI
import SwiftData
import WidgetKit

struct AddEntryView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // specific daily record being added
    var dailyRecord: DailyRecord
    
    @State private var entryType: String = "Food" // "Food" or "Water"
    @State private var amount: String = ""
    @State private var categoryName: String = "Main Meal"
    
    // predetermined categories for selection
    let foodCategories = ["Main Meal", "Snack", "Dessert"]
    let waterCategories = ["Water", "Coffee/Tea", "Juice", "Fizzy Drink"]
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // to toggle between Food and Water logging
                Picker("Type", selection: $entryType) {
                    Text("Food").tag("Food")
                    Text("Water").tag("Water")
                }
                .pickerStyle(.segmented)
                
                Section(header: Text("Details")) {
                    // category selection based on type
                    Picker("Category", selection: $categoryName) {
                        ForEach(entryType == "Food" ? foodCategories : waterCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    // numeric input for the amount
                    TextField(entryType == "Food" ? "Amount (kcal)" : "Amount (ml)", text: $amount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add \(entryType)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
        .onChange(of: entryType) { _, newValue in
            // automatically select the first item when switching between Food and Water
            categoryName = newValue == "Food" ? foodCategories[0] : waterCategories[0]
        }
    }
        
        private func saveEntry() {
            guard let amountValue = Double(amount) else { return }
            
            // create the new entry and link it to today's record
            let newEntry = ConsumptionEntry(type: entryType, amount: amountValue, categoryName: categoryName)
            dailyRecord.entries.append(newEntry)
            
            // tells SwiftData to process the calculation immediately so the totals are accurate
            try? modelContext.save()
            
            // update the App Group memory for all data so the iPhone doesn't accidentally beam a 0
            let defaults = UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")
            
            defaults?.set(dailyRecord.totalFood, forKey: "saved_food_consumed")
            defaults?.set(dailyRecord.totalWater, forKey: "saved_water_consumed")
            defaults?.set(dailyRecord.foodGoal, forKey: "food_daily_goal")
            defaults?.set(dailyRecord.waterGoal, forKey: "water_daily_goal")
            
            // refreshes UI elements and schedule notifications
            WidgetCenter.shared.reloadAllTimelines()
            NotificationManager.shared.scheduleReminder()
            
            // sync the fully updated data to the Apple Watch
            WatchConnector.shared.syncToOtherDevice()
            
            dismiss()
        }
}
