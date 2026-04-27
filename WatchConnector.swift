import Foundation
import WatchConnectivity
import WidgetKit
import Combine

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnector()
    
    @Published var syncedFood: Double = 0
    @Published var syncedWater: Double = 0
    @Published var syncedFoodGoal: Double = 0
    @Published var syncedWaterGoal: Double = 0
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // grabs current intake and goals from memory and beams it to the other device
    func syncToOtherDevice() {
        if WCSession.isSupported() {
            let session = WCSession.default
            let defaults = UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")
            
            // prevents from sending iPhone to watch app to 0
            let foodToSend = defaults?.object(forKey: "saved_food_consumed") as? Double ?? 0.0
            let waterToSend = defaults?.object(forKey: "saved_water_consumed") as? Double ?? 0.0
            let foodGoal = defaults?.object(forKey: "food_daily_goal") as? Double ?? 2000.0
            let waterGoal = defaults?.object(forKey: "water_daily_goal") as? Double ?? 2000.0
            let stepGoal = defaults?.object(forKey: "step_daily_goal") as? Double ?? 10000.0
            
            let data: [String: Any] = [
                "food": foodToSend,
                "water": waterToSend,
                "foodGoal": foodGoal,
                "waterGoal": waterGoal,
                "stepGoal": stepGoal
            ]
            
            do {
                try session.updateApplicationContext(data)
            } catch {
                print("Failed to sync context: \(error.localizedDescription)")
            }
            
            if session.isReachable {
                session.sendMessage(data, replyHandler: nil, errorHandler: nil)
            }
        }
    }
    
    private func processReceivedData(_ data: [String: Any]) {
        DispatchQueue.main.async {
            let defaults = UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")
            
            if let newFood = data["food"] as? Double {
                self.syncedFood = newFood
                defaults?.set(newFood, forKey: "saved_food_consumed")
            }
            if let newWater = data["water"] as? Double {
                self.syncedWater = newWater
                defaults?.set(newWater, forKey: "saved_water_consumed")
            }
            
            if let newFoodGoal = data["foodGoal"] as? Double {
                self.syncedFoodGoal = newFoodGoal
                defaults?.set(newFoodGoal, forKey: "food_daily_goal")
            }
            if let newWaterGoal = data["waterGoal"] as? Double {
                self.syncedWaterGoal = newWaterGoal
                defaults?.set(newWaterGoal, forKey: "water_daily_goal")
            }
            if let newStepGoal = data["stepGoal"] as? Double {
                defaults?.set(newStepGoal, forKey: "step_daily_goal")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) { processReceivedData(message) }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) { processReceivedData(applicationContext) }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
    #endif
}
