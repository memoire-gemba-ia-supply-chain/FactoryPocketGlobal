import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            
            CalculatorsGridView()
                .tabItem {
                    Label("Calculators", systemImage: "square.grid.2x2.fill")
                }
            
            LibraryView()
                .tabItem {
                    Label("Reference", systemImage: "books.vertical.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    MainTabView()
        .environment(UnitManager.shared)
        .environment(MarketManager.shared)
        .environment(ThemeManager.shared)
}
