import SwiftUI
import SwiftData
import WidgetKit

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var dailyRecord: DailyRecord
    
    @State private var entryType: String = "Food" // "Food" or "Water"
    @State private var amount: String = ""
    @State private var categoryName: String = "Main Meal"
    
    let foodCategories = ["Main Meal", "Snack", "Dessert"]
    let waterCategories = ["Water", "Coffee/Tea", "Juice", "Fizzy Drink"]
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $entryType) {
                    Text("Food").tag("Food")
                    Text("Water").tag("Water")
                }
                .pickerStyle(.segmented)
                
                Section(header: Text("Details")) {
                    Picker("Category", selection: $categoryName) {
                        ForEach(entryType == "Food" ? foodCategories : waterCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
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
                    .disabled(amount.isEmpty)                }
            }
        }
        .onChange(of: entryType) { _, newValue in
            // automatically select the first item when switching between Food and Water
            categoryName = newValue == "Food" ? foodCategories[0] : waterCategories[0]
        }
    }
    
    private func saveEntry() {
            guard let amountValue = Double(amount) else { return }
            
            let newEntry = ConsumptionEntry(type: entryType, amount: amountValue, categoryName: categoryName)
            dailyRecord.entries.append(newEntry)
            
            let defaults = UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")
            if entryType == "Food" {
                defaults?.set(dailyRecord.totalFood, forKey: "saved_food_consumed")
            } else {
                defaults?.set(dailyRecord.totalWater, forKey: "saved_water_consumed")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
            NotificationManager.shared.scheduleReminder()
            
            // beams new data to Apple Watch
            WatchConnector.shared.syncToOtherDevice()
            
            dismiss()
        }
}
