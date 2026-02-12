import SwiftUI

struct SettingsView: View {
    @Environment(UnitManager.self) private var unitManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.1).ignoresSafeArea()
                
                List {
                    Section(L10n.globalUnits) {
                        Picker(L10n.system, selection: Bindable(unitManager).unitSystem) {
                            ForEach(UnitSystem.allCases, id: \.self) { system in
                                Text("\(system.flag) \(system.rawValue)").tag(system)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        unitPreviewSection
                    }
                    
                    Section {
                        Button(L10n.resetCache, role: .destructive) {
                            UserDefaults.standard.removeObject(forKey: MarketManager.cacheKey)
                        }
                    } footer: {
                        Text(L10n.resetCacheFooter)
                    }
                    
                    Section {
                        HStack {
                            Text(L10n.version)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(L10n.settings)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.done) { dismiss() }
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private var unitPreviewSection: some View {
        Group {
            HStack {
                Text(L10n.pressure)
                Spacer()
                Text(unitManager.pressureUnit).foregroundColor(.gray)
            }
            HStack {
                Text(L10n.temperature)
                Spacer()
                Text(unitManager.temperatureUnit).foregroundColor(.gray)
            }
            HStack {
                Text(L10n.power)
                Spacer()
                Text(unitManager.powerUnit).foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(UnitManager.shared)
        .environment(MarketManager.shared)
}
