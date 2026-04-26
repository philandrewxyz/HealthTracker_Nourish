import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.scheduleReminder()
            }
        }
    }
    
    func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Tracker Reminder"
        content.body = "Don't forget to log your food and water intake today to stay on track!"
        content.sound = .default

        // reminder scheduled for 6 hours (just like my watch app)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 21600, repeats: false)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    func checkMilestones(foodConsumed: Double, foodGoal: Double, waterConsumed: Double, waterGoal: Double) {
        if foodConsumed >= foodGoal && waterConsumed >= waterGoal {
            sendImmediateAlert(id: "both_met", title: "Goals Met!", body: "Incredible! You hit both your food and water goals today.")
        } else if foodConsumed >= foodGoal {
            sendImmediateAlert(id: "food_met", title: "Calorie Goal Met", body: "You reached your caloric intake target!")
        } else if waterConsumed >= waterGoal {
            sendImmediateAlert(id: "water_met", title: "Water Goal Met", body: "You reached your hydration target!")
        }
    }
    
    private func sendImmediateAlert(id: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
