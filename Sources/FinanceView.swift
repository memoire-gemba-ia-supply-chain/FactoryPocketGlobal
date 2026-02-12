import SwiftUI

struct FinanceView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: ROICalculator()) {
                            financeRow(title: L10n.roiCalc, icon: "chart.line.uptrend.xyaxis", subtitle: L10n.roiSub, color: .green)
                        }
                        NavigationLink(destination: NPVCalculator()) {
                            financeRow(title: L10n.npv, icon: "dollarsign.arrow.circlepath", subtitle: L10n.npvSub, color: .green)
                        }
                        NavigationLink(destination: IRRCalculator()) {
                            financeRow(title: L10n.irr, icon: "arrow.triangle.2.circlepath", subtitle: L10n.irrSub, color: .green)
                        }
                    } header: {
                        sectionHeader(title: L10n.investmentAnalysis, color: .green)
                    }
                    
                    Section {
                        NavigationLink(destination: WACCCalculator()) {
                            financeRow(title: L10n.wacc, icon: "percent", subtitle: L10n.waccSub, color: .mint)
                        }
                        NavigationLink(destination: DepreciationCalculator()) {
                            financeRow(title: L10n.depreciation, icon: "arrow.down.right", subtitle: L10n.depreciationSub, color: .mint)
                        }
                        NavigationLink(destination: LoanCalculator()) {
                            financeRow(title: L10n.loanAmortization, icon: "banknote.fill", subtitle: L10n.loanAmortizationSub, color: .mint)
                        }
                    } header: {
                        sectionHeader(title: L10n.capitalPlanning, color: .mint)
                    }
                    
                    Section {
                        NavigationLink(destination: BreakEvenCalculator()) {
                            financeRow(title: L10n.breakeven, icon: "chart.bar.xaxis.ascending", subtitle: L10n.breakevenSub, color: .orange)
                        }
                        NavigationLink(destination: MarginMarkupCalculator()) {
                            financeRow(title: L10n.marginMarkup, icon: "arrow.up.arrow.down", subtitle: L10n.marginMarkupSub, color: .orange)
                        }
                    } header: {
                        sectionHeader(title: L10n.operations, color: .orange)
                    }
                    
                    Section {
                        NavigationLink(destination: CurrencyExchangerView()) {
                            financeRow(title: L10n.currencyExchanger, icon: "arrow.triangle.2.circlepath.circle.fill", subtitle: L10n.currencyExchangerSub, color: .blue)
                        }
                    } header: {
                        sectionHeader(title: L10n.tools, color: .blue)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(L10n.financeTitle)
        }
    }
    
    private func sectionHeader(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 3, height: 14)
            Text(title.uppercased()).font(.caption).fontWeight(.heavy).foregroundColor(color)
        }
    }
    
    private func financeRow(title: String, icon: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.title3).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundColor(.white)
                Text(subtitle).font(.caption).foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

// ── Helper used by all Finance calculators ────────

private struct FinInput: View {
    let label: String
    let unit: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(label).foregroundColor(.white)
            Spacer()
            HStack(spacing: 4) {
                TextField("0", text: $text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption).foregroundColor(.gray)
                        .frame(width: 30, alignment: .leading)
                }
            }
        }
    }
}

private func bigFinResult(value: String, label: String, color: Color = .orange) -> some View {
    VStack(spacing: 6) {
        Text(value)
            .font(.system(size: 36, weight: .black, design: .rounded))
            .foregroundColor(color)
        Text(label)
            .font(.caption).foregroundColor(.gray)
    }
    .frame(maxWidth: .infinity).padding()
}

// ── ROI & PAYBACK ────────────────────────────────

struct ROICalculator: View {
    @State private var investment: String = "100000"
    @State private var netProfit: String = "35000"
    @State private var annualCF: String = "25000"
    
    var roiValue: Double {
        FormulaEngine.shared.roi(netProfit: Double(netProfit) ?? 0, investment: Double(investment) ?? 0)
    }
    var payback: Double {
        FormulaEngine.shared.paybackPeriod(investment: Double(investment) ?? 0, annualCashFlow: Double(annualCF) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Investment Data") {
                FinInput(label: "Initial Investment", unit: "$", text: $investment)
                FinInput(label: "Net Profit", unit: "$", text: $netProfit)
                FinInput(label: "Annual Cash Flow", unit: "$/yr", text: $annualCF)
            }
            Section("Results") {
                bigFinResult(
                    value: String(format: "%.1f%%", roiValue),
                    label: "Return on Investment",
                    color: roiValue > 0 ? .green : .red
                )
                HStack {
                    Text("Payback Period")
                    Spacer()
                    Text(String(format: "%.1f years", payback))
                        .fontWeight(.bold).foregroundColor(.orange)
                }
            }
        }
        .navigationTitle("ROI & Payback")
        .preferredColorScheme(.dark)
    }
}

// ── NPV ──────────────────────────────────────────

struct NPVCalculator: View {
    @State private var investment: String = "200000"
    @State private var rate: String = "10"
    @State private var cf1: String = "60000"
    @State private var cf2: String = "70000"
    @State private var cf3: String = "80000"
    @State private var cf4: String = "90000"
    @State private var cf5: String = "100000"
    
    var result: NPVResult {
        let cfs = [cf1, cf2, cf3, cf4, cf5].compactMap { Double($0) }
        return FormulaEngine.shared.npv(
            initialInvestment: Double(investment) ?? 0,
            cashFlows: cfs,
            discountRate: (Double(rate) ?? 0) / 100.0
        )
    }
    
    var body: some View {
        Form {
            Section("Project Parameters") {
                FinInput(label: "Initial Investment", unit: "$", text: $investment)
                FinInput(label: "Discount Rate", unit: "%", text: $rate)
            }
            Section("Annual Cash Flows") {
                FinInput(label: "Year 1 Cash Flow", unit: "$", text: $cf1)
                FinInput(label: "Year 2 Cash Flow", unit: "$", text: $cf2)
                FinInput(label: "Year 3 Cash Flow", unit: "$", text: $cf3)
                FinInput(label: "Year 4 Cash Flow", unit: "$", text: $cf4)
                FinInput(label: "Year 5 Cash Flow", unit: "$", text: $cf5)
            }
            Section("Decision") {
                bigFinResult(
                    value: String(format: "$%.0f", result.npv),
                    label: "Net Present Value",
                    color: result.isPositive ? .green : .red
                )
                HStack {
                    Text("Recommendation")
                    Spacer()
                    Text(result.isPositive ? "✅ Invest" : "❌ Reject")
                        .fontWeight(.bold)
                        .foregroundColor(result.isPositive ? .green : .red)
                }
            }
        }
        .navigationTitle("NPV Calculator")
        .preferredColorScheme(.dark)
    }
}

// ── WACC ─────────────────────────────────────────

struct WACCCalculator: View {
    @State private var equity: String = "600000"
    @State private var debt: String = "400000"
    @State private var costE: String = "12"
    @State private var costD: String = "6"
    @State private var tax: String = "25"
    
    var result: WACCResult {
        FormulaEngine.shared.wacc(
            equityValue: Double(equity) ?? 0,
            debtValue: Double(debt) ?? 0,
            costOfEquity: (Double(costE) ?? 0) / 100.0,
            costOfDebt: (Double(costD) ?? 0) / 100.0,
            taxRate: (Double(tax) ?? 0) / 100.0
        )
    }
    
    var body: some View {
        Form {
            Section("Capital Structure") {
                FinInput(label: "Equity Value", unit: "$", text: $equity)
                FinInput(label: "Debt Value", unit: "$", text: $debt)
            }
            Section("Cost Rates") {
                FinInput(label: "Cost of Equity", unit: "%", text: $costE)
                FinInput(label: "Cost of Debt", unit: "%", text: $costD)
                FinInput(label: "Corporate Tax Rate", unit: "%", text: $tax)
            }
            Section("Weighted Average") {
                bigFinResult(
                    value: String(format: "%.2f%%", result.wacc),
                    label: "WACC"
                )
                HStack {
                    Text("Equity Weight")
                    Spacer()
                    Text(String(format: "%.1f%%", result.equityWeight * 100)).fontWeight(.bold)
                }
                HStack {
                    Text("Debt Weight")
                    Spacer()
                    Text(String(format: "%.1f%%", result.debtWeight * 100)).fontWeight(.bold)
                }
            }
        }
        .navigationTitle("WACC Calculator")
        .preferredColorScheme(.dark)
    }
}

// ── BREAK-EVEN ───────────────────────────────────

struct BreakEvenCalculator: View {
    @State private var fixedCosts: String = "50000"
    @State private var price: String = "25"
    @State private var varCost: String = "15"
    
    var bepUnits: Double {
        FormulaEngine.shared.breakEvenQuantity(
            fixedCosts: Double(fixedCosts) ?? 0,
            sellingPricePerUnit: Double(price) ?? 0,
            variableCostPerUnit: Double(varCost) ?? 0
        )
    }
    var bepRevenue: Double {
        bepUnits * (Double(price) ?? 0)
    }
    var margin: Double {
        (Double(price) ?? 0) - (Double(varCost) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Cost Structure") {
                FinInput(label: "Fixed Costs", unit: "$/yr", text: $fixedCosts)
                FinInput(label: "Selling Price", unit: "$/unit", text: $price)
                FinInput(label: "Variable Cost", unit: "$/unit", text: $varCost)
            }
            Section("Break-Even Point") {
                bigFinResult(
                    value: String(format: "%.0f units", bepUnits),
                    label: "Quantity to Break Even"
                )
                HStack {
                    Text("Revenue at BEP")
                    Spacer()
                    Text(String(format: "$%.0f", bepRevenue))
                        .fontWeight(.bold).foregroundColor(.green)
                }
                HStack {
                    Text("Contribution Margin")
                    Spacer()
                    Text(String(format: "$%.2f /unit", margin))
                        .fontWeight(.bold)
                }
            }
        }
        .navigationTitle("Break-Even")
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FinanceView()
}

// ── IRR ──────────────────────────────────────────

struct IRRCalculator: View {
    @State private var investment: String = "200000"
    @State private var cf1: String = "60000"
    @State private var cf2: String = "70000"
    @State private var cf3: String = "80000"
    @State private var cf4: String = "90000"
    @State private var cf5: String = "100000"
    
    var irrValue: Double {
        let cfs = [cf1, cf2, cf3, cf4, cf5].compactMap { Double($0) }
        return FormulaEngine.shared.irr(
            initialInvestment: Double(investment) ?? 0,
            cashFlows: cfs
        )
    }
    
    var body: some View {
        Form {
            Section("Project Investment") {
                FinInput(label: "Initial Investment", unit: "$", text: $investment)
            }
            Section("Annual Cash Flows") {
                FinInput(label: "Year 1", unit: "$", text: $cf1)
                FinInput(label: "Year 2", unit: "$", text: $cf2)
                FinInput(label: "Year 3", unit: "$", text: $cf3)
                FinInput(label: "Year 4", unit: "$", text: $cf4)
                FinInput(label: "Year 5", unit: "$", text: $cf5)
            }
            Section("Result") {
                bigFinResult(
                    value: String(format: "%.2f%%", irrValue),
                    label: "Internal Rate of Return",
                    color: irrValue > 0 ? .green : .red
                )
            }
        }
        .navigationTitle("IRR Calculator")
        .preferredColorScheme(.dark)
    }
}

// ── DEPRECIATION ─────────────────────────────────

struct DepreciationCalculator: View {
    @State private var cost: String = "100000"
    @State private var salvage: String = "10000"
    @State private var life: String = "5"
    @State private var method: Int = 0  // 0 = SL, 1 = DDB
    
    var result: DepreciationResult {
        let c = Double(cost) ?? 0
        let s = Double(salvage) ?? 0
        let l = Int(life) ?? 5
        if method == 0 {
            return FormulaEngine.shared.straightLineDepreciation(cost: c, salvageValue: s, usefulLife: l)
        } else {
            return FormulaEngine.shared.doubleDecliningDepreciation(cost: c, salvageValue: s, usefulLife: l)
        }
    }
    
    var body: some View {
        Form {
            Section("Asset Data") {
                FinInput(label: "Asset Cost", unit: "$", text: $cost)
                FinInput(label: "Salvage Value", unit: "$", text: $salvage)
                FinInput(label: "Useful Life", unit: "yrs", text: $life)
            }
            Section("Method") {
                Picker("Depreciation Method", selection: $method) {
                    Text("Straight-Line").tag(0)
                    Text("Double Declining").tag(1)
                }
                .pickerStyle(.segmented)
            }
            Section("Result") {
                bigFinResult(
                    value: String(format: "$%.0f /yr", result.annualDepreciation),
                    label: method == 0 ? "Straight-Line Depreciation" : "Year 1 DDB Depreciation"
                )
            }
            if !result.schedule.isEmpty {
                Section("Book Value Schedule") {
                    ForEach(Array(result.schedule.enumerated()), id: \.offset) { i, val in
                        HStack {
                            Text("Year \(i + 1)")
                            Spacer()
                            Text(String(format: "$%.0f", val))
                                .fontWeight(.bold).foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .navigationTitle("Depreciation")
        .preferredColorScheme(.dark)
    }
}

// ── MARGIN vs MARKUP ─────────────────────────────

struct MarginMarkupCalculator: View {
    @State private var sellingPrice: String = "100"
    @State private var costPrice: String = "60"
    
    var result: MarginMarkupResult {
        FormulaEngine.shared.marginMarkup(
            sellingPrice: Double(sellingPrice) ?? 0,
            costPrice: Double(costPrice) ?? 0
        )
    }
    
    var body: some View {
        Form {
            Section("Pricing Data") {
                FinInput(label: "Selling Price", unit: "$", text: $sellingPrice)
                FinInput(label: "Cost Price", unit: "$", text: $costPrice)
            }
            Section("Analysis") {
                HStack {
                    VStack(spacing: 6) {
                        Text(String(format: "%.1f%%", result.margin))
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                        Text("Margin").font(.caption).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 6) {
                        Text(String(format: "%.1f%%", result.markup))
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                        Text("Markup").font(.caption).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                
                HStack {
                    Text("Unit Profit")
                    Spacer()
                    Text(String(format: "$%.2f", result.profit))
                        .fontWeight(.bold).foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Margin vs Markup")
        .preferredColorScheme(.dark)
    }
}

// ── LOAN AMORTIZATION ────────────────────────────

struct LoanCalculator: View {
    @State private var principal: String = "250000"
    @State private var rate: String = "5.0"
    @State private var termYears: String = "10"
    
    var result: LoanAmortizationResult {
        FormulaEngine.shared.loanAmortization(
            principal: Double(principal) ?? 0,
            annualRate: Double(rate) ?? 0,
            termMonths: (Int(termYears) ?? 0) * 12
        )
    }
    
    var body: some View {
        Form {
            Section("Loan Parameters") {
                FinInput(label: "Principal Amount", unit: "$", text: $principal)
                FinInput(label: "Annual Interest Rate", unit: "%", text: $rate)
                FinInput(label: "Term", unit: "yrs", text: $termYears)
            }
            Section("Monthly Payment") {
                bigFinResult(
                    value: String(format: "$%.2f", result.monthlyPayment),
                    label: "Monthly Payment"
                )
            }
            Section("Loan Summary") {
                HStack {
                    Text("Total Payment")
                    Spacer()
                    Text(String(format: "$%.0f", result.totalPayment))
                        .fontWeight(.bold)
                }
                HStack {
                    Text("Total Interest")
                    Spacer()
                    Text(String(format: "$%.0f", result.totalInterest))
                        .fontWeight(.bold).foregroundColor(.red)
                }
                HStack {
                    Text("Interest-to-Principal Ratio")
                    Spacer()
                    let ratio = (Double(principal) ?? 1) > 0 ? result.totalInterest / (Double(principal) ?? 1) * 100 : 0
                    Text(String(format: "%.1f%%", ratio))
                        .fontWeight(.bold).foregroundColor(.orange)
                }
            }
        }
        .navigationTitle("Loan Amortization")
        .preferredColorScheme(.dark)
    }
}
