import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    
    // to read the latest saved data, it must be connected to the Group ID
    private let appGroupID = "group.com.philreddy.foodwatertracker"

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
                // schedule the very first reminder once users accepts/allows notifications
                self.scheduleReminder()
            } else if let error = error {
                print("Error requesting notifications: \(error.localizedDescription)")
            }
        }
    }
    
    // checking goal milestones are met
    func checkMilestones() {
        // wait to ensure @AppStorage has finished saving the new numbers before checking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let defaults = UserDefaults(suiteName: self.appGroupID)
            let foodConsumed = defaults?.double(forKey: "saved_food_consumed") ?? 0
            let foodGoal = defaults?.double(forKey: "food_daily_goal") ?? 2000
            let waterConsumed = defaults?.double(forKey: "saved_water_consumed") ?? 0
            let waterGoal = defaults?.double(forKey: "water_daily_goal") ?? 2000
            
            // check the memory if user has already been notified
            let foodNotified = defaults?.bool(forKey: "food_goal_notified") ?? false
            let waterNotified = defaults?.bool(forKey: "water_goal_notified") ?? false
            let bothNotified = defaults?.bool(forKey: "both_goals_notified") ?? false
            
            let foodMet = foodConsumed >= foodGoal && foodGoal > 0
            let waterMet = waterConsumed >= waterGoal && waterGoal > 0
            
            // check if both are met
            if foodMet && waterMet && !bothNotified {
                self.sendImmediateAlert(id: "both_met", title: "Congratulations!", body: "You reached both your food and water goals today! Great job!")
                defaults?.set(true, forKey: "both_goals_notified")
                defaults?.set(true, forKey: "food_goal_notified")
                defaults?.set(true, forKey: "water_goal_notified")
            }
            // check if only food is met
            else if foodMet && !foodNotified {
                self.sendImmediateAlert(id: "food_met", title: "Caloric Goal Achieved", body: "Congratulations! You have reached your Caloric Intake Goal today.")
                defaults?.set(true, forKey: "food_goal_notified")
            }
            // check if only water is met
            else if waterMet && !waterNotified {
                self.sendImmediateAlert(id: "water_met", title: "Water Goal Achieved", body: "Congratulations! You have reached your Water Intake Goal today.")
                defaults?.set(true, forKey: "water_goal_notified")
            }
        }
    }
        
    // to send the notification after 3 seconds
    private func sendImmediateAlert(id: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
            
        // to trigger immediately if there is an error (changed to 3 seconds so the watch face can appear)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling goal notification: \(error.localizedDescription)")
            }
        }
    }

    func scheduleReminder() {
        let defaults = UserDefaults(suiteName: appGroupID)
        let foodConsumed = defaults?.double(forKey: "saved_food_consumed") ?? 0
        let foodGoal = defaults?.double(forKey: "food_daily_goal") ?? 2000
        let waterConsumed = defaults?.double(forKey: "saved_water_consumed") ?? 0
        let waterGoal = defaults?.double(forKey: "water_daily_goal") ?? 2000

        let content = UNMutableNotificationContent()
        content.title = "Time to Eat or Drink Water!"
        content.body = "You have consumed \(Int(foodConsumed))/\(Int(foodGoal))kcal and \(Int(waterConsumed))/\(Int(waterGoal))ml so far. Don't forget to eat/drink to reach your goals."
        content.sound = .default

        // 6 hours = 21,600 seconds, this could also be set to any amount or 5 seconds for testing
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // this will automatically cancel any previously scheduled notification
        let request = UNNotificationRequest(identifier: "6_hour_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
