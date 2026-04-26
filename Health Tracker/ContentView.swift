import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            
            SetGoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        // had to include this as previously, preview used to crash so this would just display mock data for the preview. Now previewing is fine
        .modelContainer(for: [DailyRecord.self, ConsumptionEntry.self, Category.self], inMemory: true)
        .environmentObject(HealthManager())
}
