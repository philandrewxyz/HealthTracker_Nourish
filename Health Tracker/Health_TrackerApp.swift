import SwiftUI
import SwiftData

@main
struct Health_TrackerApp: App {
    @StateObject private var healthManager = HealthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // dark mode for my app as I feel it looks better and matches my watch app perfectly
                .environmentObject(healthManager)
                .onAppear {
                    healthManager.requestAuthorization()
                    NotificationManager.shared.requestAuthorization()
                }
        }
        .modelContainer(for: [DailyRecord.self, ConsumptionEntry.self, Category.self])
    }
}
