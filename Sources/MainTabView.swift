import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label(L10n.tabDashboard, systemImage: "square.grid.2x2.fill")
                }
            
            SupplyChainView()
                .tabItem {
                    Label(L10n.tabSupplyChain, systemImage: "shippingbox.fill")
                }
            
            TechnicalView()
                .tabItem {
                    Label(L10n.tabTechnical, systemImage: "gearshape.2.fill")
                }
            
            FinanceView()
                .tabItem {
                    Label(L10n.tabFinance, systemImage: "chart.line.uptrend.xyaxis")
                }
            
            LibraryView()
                .tabItem {
                    Label(L10n.tabLibrary, systemImage: "books.vertical.fill")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    MainTabView()
        .environment(UnitManager.shared)
        .environment(MarketManager.shared)
}
