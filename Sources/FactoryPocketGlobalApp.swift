import SwiftUI

@main
struct FactoryPocketGlobalApp: App {
    @State private var unitManager = UnitManager.shared
    @State private var marketManager = MarketManager.shared
    @State private var themeManager = ThemeManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(unitManager)
                .environment(marketManager)
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnboarding = true
                    }
                }
                .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
                    hasSeenOnboarding = true
                }) {
                    OnboardingView(isPresented: $showOnboarding)
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        marketManager.checkDataFreshness()
                    }
                }
        }
    }
}
