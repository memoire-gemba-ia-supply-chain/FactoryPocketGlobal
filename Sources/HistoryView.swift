import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @Environment(UnitManager.self) private var unitManager
    @Environment(MarketManager.self) private var marketManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack {
                    Text("History")
                        .font(.title2)
                        .foregroundColor(themeManager.textPrimary)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HistoryView()
        .environment(ThemeManager.shared)
        .environment(UnitManager.shared)
        .environment(MarketManager.shared)
}
