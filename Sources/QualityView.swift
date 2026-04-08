import SwiftUI

struct QualityView: View {
    @Environment(UnitManager.self) private var unitManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: CpCalculator()) {
                            qRow(title: "Cp Index", icon: "chart.bar.fill", subtitle: "Capability index", color: .orange)
                        }
                        NavigationLink(destination: CpkCalculator()) {
                            qRow(title: "Cpk Index", icon: "chart.bar.xaxis", subtitle: "Centered capability", color: .orange)
                        }
                        NavigationLink(destination: DPMOCalculator()) {
                            qRow(title: "DPMO", icon: "exclamationmark.circle.fill", subtitle: "Defects per million", color: .red)
                        }
                        NavigationLink(destination: SigmaLevelCalculator()) {
                            qRow(title: "Sigma Level", icon: "sigma", subtitle: "Yield to sigma", color: .purple)
                        }
                    } header: {
                        qHeader(title: "Six Sigma Metrics", color: .orange)
                    }
                    
                    Section {
                        NavigationLink(destination: COPQCalculator()) {
                            qRow(title: "COPQ", icon: "dollarsign.circle.fill", subtitle: "Cost of poor quality", color: .yellow)
                        }
                        NavigationLink(destination: FPYCalculator()) {
                            qRow(title: "FPY", icon: "checkmark.circle.fill", subtitle: "First pass yield", color: .green)
                        }
                        NavigationLink(destination: RTYCalculator()) {
                            qRow(title: "RTY", icon: "checkmark.circle.badge.xmark", subtitle: "Rolled throughput", color: .teal)
                        }
                        NavigationLink(destination: GageRRCalculator()) {
                            qRow(title: "Gage R&R", icon: "scale.3d", subtitle: "Measurement system", color: .blue)
                        }
                    } header: {
                        qHeader(title: "Quality Control", color: .green)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Quality Management")
        }
    }
    
    private func qHeader(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 3, height: 14)
            Text(title.uppercased()).font(.caption).fontWeight(.heavy).foregroundColor(color)
        }
    }
    
    private func qRow(title: String, icon: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.15)).frame(width: 44, height: 44)
                Image(systemName: icon).font(.title3).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundColor(.primary)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Shared Input Helper
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

private struct QInput: View {
    let label: String
    let unit: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(label).foregroundColor(.primary)
            Spacer()
            HStack(spacing: 4) {
                TextField("0", text: $text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
                if !unit.isEmpty {
                    Text(unit).font(.caption).foregroundColor(.secondary).frame(width: 45, alignment: .leading)
                }
            }
        }
    }
}

private func qResult(label: String, value: String, color: Color = .orange) -> some View {
    VStack(spacing: 6) {
        Text(value)
            .font(.system(size: 34, weight: .black, design: .rounded))
            .foregroundColor(color)
        Text(label)
            .font(.caption).foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity).padding()
}

private func qRow(label: String, value: String) -> some View {
    HStack {
        Text(label)
        Spacer()
        Text(value).fontWeight(.bold).foregroundColor(.orange)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Cp Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CpCalculator: View {
    @State private var usl: String = "100"
    @State private var lsl: String = "80"
    @State private var sigma: String = "3.33"
    
    var result: Double {
        let upper = Double(usl) ?? 0
        let lower = Double(lsl) ?? 0
        let std = Double(sigma) ?? 1
        return (upper - lower) / (6 * std)
    }
    
    var interpretation: String {
        if result >= 2.0 { return "Excellent" }
        if result >= 1.67 { return "Good" }
        if result >= 1.33 { return "Capable" }
        return "Inadequate"
    }
    
    var color: Color {
        if result >= 2.0 { return .green }
        if result >= 1.67 { return .yellow }
        if result >= 1.33 { return .orange }
        return .red
    }
    
    var body: some View {
        Form {
            Section("Specification Limits") {
                QInput(label: "Upper Spec Limit (USL)", unit: "", text: $usl)
                QInput(label: "Lower Spec Limit (LSL)", unit: "", text: $lsl)
                QInput(label: "Standard Deviation (σ)", unit: "", text: $sigma)
            }
            Section("Result") {
                qResult(label: "Cp Index", value: String(format: "%.3f", result), color: color)
                qRow(label: "Status", value: interpretation)
            }
        }
        .navigationTitle("Cp Index Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Cpk Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CpkCalculator: View {
    @State private var usl: String = "100"
    @State private var lsl: String = "80"
    @State private var mean: String = "90"
    @State private var sigma: String = "3.33"
    
    var result: Double {
        let upper = Double(usl) ?? 0
        let lower = Double(lsl) ?? 0
        let avg = Double(mean) ?? 0
        let std = Double(sigma) ?? 1
        let cpupper = (upper - avg) / (3 * std)
        let clower = (avg - lower) / (3 * std)
        return min(cpupper, clower)
    }
    
    var interpretation: String {
        if result >= 2.0 { return "Excellent" }
        if result >= 1.67 { return "Good" }
        if result >= 1.33 { return "Capable" }
        return "Inadequate"
    }
    
    var color: Color {
        if result >= 2.0 { return .green }
        if result >= 1.67 { return .yellow }
        if result >= 1.33 { return .orange }
        return .red
    }
    
    var body: some View {
        Form {
            Section("Specification & Process") {
                QInput(label: "Upper Spec Limit (USL)", unit: "", text: $usl)
                QInput(label: "Lower Spec Limit (LSL)", unit: "", text: $lsl)
                QInput(label: "Process Mean", unit: "", text: $mean)
                QInput(label: "Standard Deviation (σ)", unit: "", text: $sigma)
            }
            Section("Result") {
                qResult(label: "Cpk Index", value: String(format: "%.3f", result), color: color)
                qRow(label: "Status", value: interpretation)
            }
        }
        .navigationTitle("Cpk Index Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - DPMO Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct DPMOCalculator: View {
    @State private var defects: String = "15"
    @State private var units: String = "1000"
    @State private var opportunities: String = "10"
    
    var dpmo: Double {
        let d = Double(defects) ?? 0
        let u = Double(units) ?? 1
        let o = Double(opportunities) ?? 1
        return (d * 1_000_000) / (u * o)
    }
    
    var sigmaLevel: String {
        if dpmo <= 3.4 { return "6σ (99.9997%)" }
        if dpmo <= 233 { return "5σ (99.977%)" }
        if dpmo <= 6210 { return "4σ (99.38%)" }
        if dpmo <= 66807 { return "3σ (93.32%)" }
        return "< 3σ"
    }
    
    var body: some View {
        Form {
            Section("Process Data") {
                QInput(label: "Number of Defects", unit: "", text: $defects)
                QInput(label: "Total Units", unit: "", text: $units)
                QInput(label: "Opportunities per Unit", unit: "", text: $opportunities)
            }
            Section("Result") {
                qResult(label: "DPMO", value: String(format: "%.0f", dpmo), color: .red)
                qRow(label: "Sigma Level", value: sigmaLevel)
            }
        }
        .navigationTitle("DPMO Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Sigma Level Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SigmaLevelCalculator: View {
    @State private var yield: String = "99.73"
    
    var yieldDouble: Double {
        Double(yield) ?? 0
    }
    
    var sigmaLevel: String {
        if yieldDouble >= 99.9997 { return "6σ" }
        if yieldDouble >= 99.977 { return "5σ" }
        if yieldDouble >= 99.38 { return "4σ" }
        if yieldDouble >= 93.32 { return "3σ" }
        if yieldDouble >= 68.27 { return "2σ" }
        if yieldDouble >= 30.85 { return "1σ" }
        return "< 1σ"
    }
    
    var dpmo: Double {
        let y = yieldDouble / 100
        if y >= 1 { return 0 }
        let defectRate = 1 - y
        return defectRate * 1_000_000
    }
    
    var body: some View {
        Form {
            Section("Process Yield") {
                QInput(label: "Yield Percentage", unit: "%", text: $yield)
            }
            Section("Result") {
                qResult(label: "Sigma Level", value: sigmaLevel, color: .purple)
                qRow(label: "DPMO", value: String(format: "%.0f", dpmo))
            }
        }
        .navigationTitle("Sigma Level Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - COPQ Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct COPQCalculator: View {
    @State private var internalCost: String = "50000"
    @State private var externalCost: String = "75000"
    @State private var appraisalCost: String = "100000"
    @State private var preventionCost: String = "50000"
    @State private var revenue: String = "5000000"
    
    var totalCOPQ: Double {
        let ic: Double = Double(internalCost) ?? 0
        let ec: Double = Double(externalCost) ?? 0
        let ac: Double = Double(appraisalCost) ?? 0
        let pc: Double = Double(preventionCost) ?? 0
        return ic + ec + ac + pc
    }
    
    var copqPercent: Double {
        let rev = Double(revenue) ?? 1
        return (totalCOPQ / rev) * 100
    }
    
    var body: some View {
        Form {
            Section("Cost Components") {
                QInput(label: "Internal Failure Costs", unit: "$", text: $internalCost)
                QInput(label: "External Failure Costs", unit: "$", text: $externalCost)
                QInput(label: "Appraisal Costs", unit: "$", text: $appraisalCost)
                QInput(label: "Prevention Costs", unit: "$", text: $preventionCost)
            }
            Section("Revenue") {
                QInput(label: "Annual Revenue", unit: "$", text: $revenue)
            }
            Section("Result") {
                qResult(label: "Total COPQ", value: String(format: "$%.0f", totalCOPQ), color: .yellow)
                qRow(label: "COPQ as % of Revenue", value: String(format: "%.2f%%", copqPercent))
            }
        }
        .navigationTitle("COPQ Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - FPY Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct FPYCalculator: View {
    @State private var goodUnits: String = "950"
    @State private var totalUnits: String = "1000"
    
    var fpy: Double {
        let good = Double(goodUnits) ?? 0
        let total = Double(totalUnits) ?? 1
        return (good / total) * 100
    }
    
    var body: some View {
        Form {
            Section("Units") {
                QInput(label: "Good Units (No Rework)", unit: "", text: $goodUnits)
                QInput(label: "Total Units Produced", unit: "", text: $totalUnits)
            }
            Section("Result") {
                qResult(label: "First Pass Yield", value: String(format: "%.2f%%", fpy), color: .green)
            }
        }
        .navigationTitle("FPY Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - RTY Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct RTYCalculator: View {
    @State private var fpyValues: String = "0.95, 0.90, 0.98"
    
    var rty: Double {
        let values = fpyValues.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .compactMap { Double($0) }
        
        if values.isEmpty { return 0 }
        return values.reduce(1.0, { $0 * $1 }) * 100
    }
    
    var body: some View {
        Form {
            Section("FPY Values") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Comma-separated FPY decimals").font(.caption).foregroundColor(.secondary)
                    TextEditor(text: $fpyValues)
                        .frame(height: 80)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)
                }
            }
            Section("Result") {
                qResult(label: "Rolled Throughput Yield", value: String(format: "%.2f%%", rty), color: .teal)
            }
        }
        .navigationTitle("RTY Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Gage R&R Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct GageRRCalculator: View {
    @State private var ev: String = "2.5"
    @State private var av: String = "1.8"
    @State private var tv: String = "10"
    
    var grr: Double {
        let equipment = Double(ev) ?? 0
        let appraiser = Double(av) ?? 0
        let total = Double(tv) ?? 1
        let gage = sqrt(pow(equipment, 2) + pow(appraiser, 2))
        return (gage / total) * 100
    }
    
    var interpretation: String {
        if grr < 10 { return "Acceptable" }
        if grr <= 30 { return "Marginal" }
        return "Unacceptable"
    }
    
    var color: Color {
        if grr < 10 { return .green }
        if grr <= 30 { return .orange }
        return .red
    }
    
    var body: some View {
        Form {
            Section("Measurement System") {
                QInput(label: "Equipment Variation", unit: "", text: $ev)
                QInput(label: "Appraiser Variation", unit: "", text: $av)
                QInput(label: "Total Variation", unit: "", text: $tv)
            }
            Section("Result") {
                qResult(label: "%GRR", value: String(format: "%.2f%%", grr), color: color)
                qRow(label: "Status", value: interpretation)
            }
        }
        .navigationTitle("Gage R&R Calculator")
    }
}
