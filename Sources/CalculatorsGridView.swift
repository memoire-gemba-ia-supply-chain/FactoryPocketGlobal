import SwiftUI

struct CalculatorsGridView: View {
    @State private var searchText = ""
    @Environment(ThemeManager.self) private var themeManager
    
    let modules: [(name: String, icon: String, color: Color, count: Int, destination: AnyView)] = [
        ("Supply Chain", "shippingbox.fill", .blue, 14, AnyView(SupplyChainView())),
        ("Technical", "wrench.and.screwdriver.fill", .purple, 16, AnyView(TechnicalView())),
        ("Finance", "dollarsign.circle.fill", .green, 9, AnyView(FinanceView())),
        ("Mechanical", "gearshape.2.fill", .gray, 6, AnyView(MechanicalView())),
        ("Maintenance", "wrench.adjustable.fill", .red, 8, AnyView(MaintenanceView())),
        ("EHS", "cross.case.fill", .orange, 8, AnyView(EHSView())),
        ("Quality", "checkmark.seal.fill", .teal, 8, AnyView(QualityView())),
        ("Lean / CI", "chart.line.uptrend.xyaxis", .indigo, 8, AnyView(LeanView())),
    ]
    
    var filteredModules: [(name: String, icon: String, color: Color, count: Int, destination: AnyView)] {
        if searchText.isEmpty {
            return modules
        }
        return modules.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    SearchBar(text: $searchText, placeholder: "Search calculators")
                        .padding()
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredModules, id: \.name) { module in
                                NavigationLink(destination: module.destination) {
                                    ModuleCard(
                                        name: module.name,
                                        icon: module.icon,
                                        color: module.color,
                                        count: module.count
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Calculators")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ModuleCard: View {
    let name: String
    let icon: String
    let color: Color
    let count: Int
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Spacer()
                
                Badge(count: count)
            }
            
            Text(name)
                .font(.headline)
                .foregroundColor(themeManager.textPrimary)
                .lineLimit(2)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .frame(minHeight: 140)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
    }
}

struct Badge: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.orange)
            
            Text("\(count)")
                .font(.caption.bold())
                .foregroundColor(.white)
        }
        .frame(width: 32, height: 32)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.textSecondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.textSecondary)
                }
            }
        }
    }
}

#Preview {
    CalculatorsGridView()
        .environment(ThemeManager.shared)
        .environment(UnitManager.shared)
        .environment(MarketManager.shared)
}
