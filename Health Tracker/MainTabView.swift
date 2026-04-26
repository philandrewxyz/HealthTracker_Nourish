import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
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
