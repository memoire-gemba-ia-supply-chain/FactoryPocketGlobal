import SwiftUI

struct CurrencyExchangerView: View {
    @Environment(MarketManager.self) private var marketManager
    
    @State private var amount: String = "100"
    @State private var sourceCurrency: String = "USD"
    @State private var targetCurrency: String = "EUR"
    
    var rates: [String: Double] {
        marketManager.exchangerRates
    }
    
    var availableCurrencies: [String] {
        rates.keys.sorted()
    }
    
    var conversionResult: Double {
        guard let amountVal = Double(amount),
              let sourceRate = rates[sourceCurrency],
              let targetRate = rates[targetCurrency],
              sourceRate > 0 else { return 0 }
        
        // Logic: Convert Source -> USD -> Target
        // Rate is "1 USD = X Currency"
        // So: Amount_Source / Rate_Source = Amount_USD
        // Amount_USD * Rate_Target = Amount_Target
        
        let amountInUSD = amountVal / sourceRate
        let amountInTarget = amountInUSD * targetRate
        return amountInTarget
    }
    
    var body: some View {
        Form {
            if rates.isEmpty {
                Section {
                    ContentUnavailableView(L10n.loadingRates, systemImage: "arrow.triangle.2.circlepath")
                }
            } else {
                Section(L10n.amount) {
                    HStack {
                        TextField(L10n.amount, text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2.bold())
                        
                        Text(sourceCurrency)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                    }
                }
                
                Section(L10n.currencyTitle) {
                    Picker(L10n.from, selection: $sourceCurrency) {
                        ForEach(availableCurrencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    
                    Picker(L10n.to, selection: $targetCurrency) {
                        ForEach(availableCurrencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                    
                    // Swap button
                    Button(action: swapCurrencies) {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.up.arrow.down")
                            Text(L10n.swap)
                            Spacer()
                        }
                    }
                    .foregroundColor(.orange)
                }
                
                Section(L10n.result) {
                    VStack(spacing: 8) {
                        Text(String(format: "%.2f %@", conversionResult, targetCurrency))
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                        
                        Text("1 \(sourceCurrency) = \(String(format: "%.4f", conversionRate)) \(targetCurrency)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section {
                   Text(L10n.lastUpdated(marketManager.lastUpdateText))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle(L10n.currencyExchanger)
        .preferredColorScheme(.dark)
        .onAppear {
            if rates.isEmpty {
                Task { await marketManager.refreshMarketData() }
            }
        }
    }
    
    private var conversionRate: Double {
        guard let sourceRate = rates[sourceCurrency],
              let targetRate = rates[targetCurrency],
              sourceRate > 0 else { return 0 }
        return targetRate / sourceRate
    }
    
    private func swapCurrencies() {
        let temp = sourceCurrency
        sourceCurrency = targetCurrency
        targetCurrency = temp
    }
}

#Preview {
    NavigationStack {
        CurrencyExchangerView()
            .environment(MarketManager.shared)
    }
}
