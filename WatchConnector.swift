import Foundation
import WatchConnectivity
import WidgetKit
import Combine

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnector()
    
    // publishes updates so iOS can catch and save them to SwiftData database
    @Published var syncedFood: Double = 0
    @Published var syncedWater: Double = 0
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // grabs current intake from memory and beams it to the other device
    func syncToOtherDevice() {
        if WCSession.isSupported() {
            let session = WCSession.default
            let defaults = UserDefaults(suiteName: "group.com.philreddy.foodwatertracker")
            
            let food = defaults?.double(forKey: "saved_food_consumed") ?? 0
            let water = defaults?.double(forKey: "saved_water_consumed") ?? 0
            
            let data: [String: Any] = ["food": food, "water": water]
            
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
    
    // runs automatically when data is received from other device - my watch app
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
            
            // tells the receiving device to update its own widgets
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        processReceivedData(message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        processReceivedData(applicationContext)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    // to be required by iOS, ignored by watchOS
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
