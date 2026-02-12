import SwiftUI

struct DashboardView: View {
    @Environment(UnitManager.self) private var unitManager
    @Environment(MarketManager.self) private var marketManager
    
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        
                        if let data = marketManager.data {
                            indicesStrip(data.indices)
                            
                            marketSection(title: L10n.energyOil, icon: "drop.fill", color: .orange, items: data.energy)
                            marketSection(title: L10n.metals, icon: "diamond.fill", color: .yellow, items: data.metals)
                            marketSection(title: L10n.currencies, icon: "coloncurrencysign.circle.fill", color: .blue, items: data.currencies)
                            marketSection(title: L10n.agriculture, icon: "leaf.fill", color: .green, items: data.agriculture)

                        } else {
                            emptyState
                        }
                        
                        quickShortcutsGrid
                    }
                    .padding()
                }
            }
            .navigationTitle("Factory Pocket Pro 👑")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            Task { await marketManager.refreshMarketData() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                                .rotationEffect(.degrees(marketManager.isLoading ? 360 : 0))
                                .animation(marketManager.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: marketManager.isLoading)
                        }
                        .disabled(marketManager.isLoading)
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environment(unitManager)
                    .environment(marketManager)
            }
            .task {
                await marketManager.refreshMarketData()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(date: .abbreviated, time: .omitted).uppercased())
                    .font(.caption).fontWeight(.bold).foregroundColor(.gray)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if marketManager.isLoading {
                    ProgressView().tint(.orange)
                } else if !marketManager.auditStatus.isEmpty {
                    Text(marketManager.auditStatus)
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundColor(marketManager.dataIsStale ? .red : .green)
                }
                Text(marketManager.lastUpdateText)
                    .font(.caption2).foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Global Indices Strip
    
    private func indicesStrip(_ items: [MarketItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L10n.globalIndices, systemImage: "chart.bar.fill")
                .font(.headline).foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.caption2).fontWeight(.medium).foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Text(formatPrice(item.price, decimals: item.price > 1000 ? 0 : 2))
                                .font(.subheadline).fontWeight(.black).foregroundColor(.white)
                            if let unit = item.unit, !unit.isEmpty {
                                Text(unit)
                                    .font(.system(size: 8)).foregroundColor(.gray.opacity(0.7))
                            }
                            
                            HStack(spacing: 2) {
                                Image(systemName: item.trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                                    .font(.caption2)
                                Text(String(format: "%+.2f%%", item.trend))
                                    .font(.caption2).fontWeight(.bold)
                            }
                            .foregroundColor(item.trend >= 0 ? .green : .red)
                        }
                        .padding(10)
                        .frame(width: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(white: 0.14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            item.trend >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Market Section (Generic)
    
    private func marketSection(title: String, icon: String, color: Color, items: [MarketItem]) -> some View {
        Group {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .foregroundColor(color)
                            .font(.subheadline)
                        Text(title)
                            .font(.headline).foregroundColor(.white)
                        Spacer()
                        Text("\(items.count)")
                            .font(.caption2).fontWeight(.bold)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(color.opacity(0.15))
                            .foregroundColor(color)
                            .cornerRadius(8)
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.subheadline).fontWeight(.medium).foregroundColor(.white)
                                    Text(item.ticker)
                                        .font(.caption2).foregroundColor(.gray)
                                }
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text(formatPrice(item.price, decimals: item.price > 100 ? 2 : 4))
                                        .fontWeight(.bold).foregroundColor(.white)
                                    if let unit = item.unit, !unit.isEmpty {
                                        Text(unit)
                                            .font(.caption2).foregroundColor(.gray)
                                    } else if let curr = item.currency, !curr.isEmpty {
                                        Text(curr)
                                            .font(.caption2).foregroundColor(.gray)
                                    }
                                }
                                
                                Text(String(format: "%+.1f%%", item.trend))
                                    .font(.caption).fontWeight(.bold)
                                    .foregroundColor(item.trend >= 0 ? .green : .red)
                                    .frame(width: 55, alignment: .trailing)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            
                            if item.id != items.last?.id {
                                Divider().background(Color.gray.opacity(0.15))
                            }
                        }
                    }
                    .background(Color(white: 0.14))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: marketManager.dataIsStale ? "clock.badge.exclamationmark" : "wifi.slash")
                .font(.largeTitle).foregroundColor(marketManager.dataIsStale ? .orange : .gray)
            Text(marketManager.dataIsStale ? L10n.staleData : L10n.marketUnavailable)
                .foregroundColor(.white).fontWeight(.semibold)
            Text(marketManager.dataIsStale ? L10n.staleHint : L10n.loadingHint)
                .font(.caption).foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
            
            if !marketManager.isLoading {
                Button {
                    Task { await marketManager.refreshMarketData() }
                } label: {
                    Label(L10n.refreshNow, systemImage: "arrow.clockwise")
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color(white: 0.14))
        .cornerRadius(12)
    }
    
    // MARK: - Quick Shortcuts
    
    private var quickShortcutsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.quickAccess)
                .font(.headline).foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NavigationLink(destination: SupplyChainView()) {
                    ShortcutCard(title: L10n.supplyChain, icon: "shippingbox.fill", gradient: Gradient(colors: [.orange, .red]))
                }
                NavigationLink(destination: TechnicalView()) {
                    ShortcutCard(title: L10n.engineering, icon: "gearshape.2.fill", gradient: Gradient(colors: [.blue, .cyan]))
                }
                NavigationLink(destination: FinanceView()) {
                    ShortcutCard(title: L10n.finance, icon: "chart.line.uptrend.xyaxis", gradient: Gradient(colors: [.green, .mint]))
                }
                NavigationLink(destination: LibraryView()) {
                    ShortcutCard(title: L10n.library, icon: "books.vertical.fill", gradient: Gradient(colors: [.purple, .indigo]))
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatPrice(_ price: Double, decimals: Int) -> String {
        return String(format: "%.\(decimals)f", price)
    }
}

// MARK: - Shortcut Card

struct ShortcutCard: View {
    let title: String
    let icon: String
    let gradient: Gradient
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.headline).fontWeight(.bold).foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color(white: 0.16))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
        .environment(UnitManager.shared)
        .environment(MarketManager.shared)
}
