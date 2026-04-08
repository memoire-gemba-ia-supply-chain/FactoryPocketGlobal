import SwiftUI

struct EHSView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: FrequencyRateCalculator()) {
                            ehsRow(title: "Frequency Rate", icon: "exclamationmark.bubble.fill", subtitle: "TF = (accidents × 1M) / hours", color: .red)
                        }
                        NavigationLink(destination: SeverityRateCalculator()) {
                            ehsRow(title: "Severity Rate", icon: "exclamationmark.triangle.fill", subtitle: "TG = (days lost × 1K) / hours", color: .red)
                        }
                        NavigationLink(destination: LTIRCalculator()) {
                            ehsRow(title: "LTIR", icon: "bandage.fill", subtitle: "Lost Time Injury Rate", color: .orange)
                        }
                        NavigationLink(destination: TRIRCalculator()) {
                            ehsRow(title: "TRIR", icon: "cross.fill", subtitle: "Total Recordable Incident Rate", color: .orange)
                        }
                    } header: {
                        ehsHeader(title: "Incident Rates", color: .red)
                    }
                    
                    Section {
                        NavigationLink(destination: DARTCalculator()) {
                            ehsRow(title: "DART", icon: "figure.walk", subtitle: "Days Away, Restricted, Transfers", color: .yellow)
                        }
                        NavigationLink(destination: SeverityRateOSHACalculator()) {
                            ehsRow(title: "OSHA Severity", icon: "calendar.badge.exclamationmark", subtitle: "SR = (workdays × 200K) / hours", color: .yellow)
                        }
                        NavigationLink(destination: NearMissRatioCalculator()) {
                            ehsRow(title: "Near Miss Ratio", icon: "checkmark.shield.fill", subtitle: "Near misses / Total incidents", color: .green)
                        }
                    } header: {
                        ehsHeader(title: "Safety Metrics", color: .yellow)
                    }
                    
                    Section {
                        NavigationLink(destination: AccidentCostCalculator()) {
                            ehsRow(title: "Accident Cost", icon: "dollarsign.circle.fill", subtitle: "Bird's ratio: Direct × 4-5", color: .blue)
                        }
                    } header: {
                        ehsHeader(title: "Cost Analysis", color: .blue)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("EHS")
        }
    }
    
    private func ehsHeader(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 3, height: 14)
            Text(title.uppercased()).font(.caption).fontWeight(.heavy).foregroundColor(color)
        }
    }
    
    private func ehsRow(title: String, icon: String, subtitle: String, color: Color) -> some View {
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

private struct EHSInput: View {
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
                    Text(unit).font(.caption).foregroundColor(.secondary).frame(width: 60, alignment: .leading)
                }
            }
        }
    }
}

private func ehsResult(label: String, value: String, color: Color = .orange) -> some View {
    VStack(spacing: 6) {
        Text(value)
            .font(.system(size: 34, weight: .black, design: .rounded))
            .foregroundColor(color)
        Text(label)
            .font(.caption).foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity).padding()
}

private func ehsRow(label: String, value: String) -> some View {
    HStack {
        Text(label)
        Spacer()
        Text(value).fontWeight(.bold).foregroundColor(.orange)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Frequency Rate Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct FrequencyRateCalculator: View {
    @State private var accidents: String = "3"
    @State private var hoursWorked: String = "200000"
    
    var result: Double {
        let a = Double(accidents) ?? 0
        let h = Double(hoursWorked) ?? 1
        return (a * 1000000) / h
    }
    
    var body: some View {
        Form {
            Section("Incident Data") {
                EHSInput(label: "Number of Accidents", unit: "count", text: $accidents)
                EHSInput(label: "Total Hours Worked", unit: "h", text: $hoursWorked)
            }
            Section("Frequency Rate") {
                ehsResult(label: "TF (Accidents per 1M hours)", value: String(format: "%.2f", result))
                Text("Standard OSHA metric for comparing incident rates.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("Frequency Rate")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Severity Rate Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SeverityRateCalculator: View {
    @State private var daysLost: String = "15"
    @State private var hoursWorked: String = "200000"
    
    var result: Double {
        let d = Double(daysLost) ?? 0
        let h = Double(hoursWorked) ?? 1
        return (d * 1000) / h
    }
    
    var body: some View {
        Form {
            Section("Impact Data") {
                EHSInput(label: "Days Lost Due to Injury", unit: "days", text: $daysLost)
                EHSInput(label: "Total Hours Worked", unit: "h", text: $hoursWorked)
            }
            Section("Severity Rate") {
                ehsResult(label: "TG (Days lost per 1K hours)", value: String(format: "%.2f", result))
                Text("Measures the severity and impact of injuries, not just frequency.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("Severity Rate")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - LTIR Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct LTIRCalculator: View {
    @State private var lostTimeInjuries: String = "2"
    @State private var hoursWorked: String = "200000"
    
    var result: Double {
        let lti = Double(lostTimeInjuries) ?? 0
        let h = Double(hoursWorked) ?? 1
        return (lti * 200000) / h
    }
    
    var body: some View {
        Form {
            Section("Injury Data") {
                EHSInput(label: "Lost Time Injuries", unit: "count", text: $lostTimeInjuries)
                EHSInput(label: "Total Hours Worked", unit: "h", text: $hoursWorked)
            }
            Section("Lost Time Injury Rate") {
                ehsResult(
                    label: "LTIR",
                    value: String(format: "%.2f", result),
                    color: result < 3 ? .green : result < 6 ? .orange : .red
                )
                Text("Injuries causing loss of work time per 200K hours (US standard).")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("LTIR")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - TRIR Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct TRIRCalculator: View {
    @State private var recordableIncidents: String = "5"
    @State private var hoursWorked: String = "200000"
    
    var result: Double {
        let ri = Double(recordableIncidents) ?? 0
        let h = Double(hoursWorked) ?? 1
        return (ri * 200000) / h
    }
    
    var body: some View {
        Form {
            Section("Incident Data") {
                EHSInput(label: "Recordable Incidents", unit: "count", text: $recordableIncidents)
                EHSInput(label: "Total Hours Worked", unit: "h", text: $hoursWorked)
            }
            Section("Total Recordable Incident Rate") {
                ehsResult(
                    label: "TRIR",
                    value: String(format: "%.2f", result),
                    color: result < 3 ? .green : result < 6 ? .orange : .red
                )
                Text("All recordable injuries and illnesses per 200K hours.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("TRIR")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - DART Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct DARTCalculator: View {
    @State private var dartCases: String = "3"
    @State private var hoursWorked: String = "200000"
    
    var result: Double {
        let d = Double(dartCases) ?? 0
        let h = Double(hoursWorked) ?? 1
        return (d * 200000) / h
    }
    
    var body: some View {
        Form {
            Section("DART Case Data") {
                EHSInput(label: "DART Cases", unit: "count", text: $dartCases)
                EHSInput(label: "Total Hours Worked", unit: "h", text: $hoursWorked)
            }
            Section("DART Rate") {
                ehsResult(
                    label: "DART",
                    value: String(format: "%.2f", result),
                    color: result < 2 ? .green : result < 4 ? .orange : .red
                )
                Text("Days Away, Restricted, Transfers per 200K hours (OSHA standard).")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("DART")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - OSHA Severity Rate Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SeverityRateOSHACalculator: View {
    @State private var lostWorkdays: String = "25"
    @State private var hoursWorked: String = "200000"
    
    var result: Double {
        let lwd = Double(lostWorkdays) ?? 0
        let h = Double(hoursWorked) ?? 1
        return (lwd * 200000) / h
    }
    
    var body: some View {
        Form {
            Section("Workday Data") {
                EHSInput(label: "Lost Work Days", unit: "days", text: $lostWorkdays)
                EHSInput(label: "Total Hours Worked", unit: "h", text: $hoursWorked)
            }
            Section("OSHA Severity Rate") {
                ehsResult(label: "SR (Days per 200K hours)", value: String(format: "%.2f", result))
                Text("Measures lost work days per 200,000 hours worked (US OSHA standard).")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("OSHA Severity Rate")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Near Miss Ratio Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct NearMissRatioCalculator: View {
    @State private var nearMisses: String = "45"
    @State private var totalIncidents: String = "50"
    
    var result: Double {
        let nm = Double(nearMisses) ?? 0
        let ti = Double(totalIncidents) ?? 1
        return (nm / ti) * 100
    }
    
    var body: some View {
        Form {
            Section("Safety Events") {
                EHSInput(label: "Near Miss Events", unit: "count", text: $nearMisses)
                EHSInput(label: "Total Incidents", unit: "count", text: $totalIncidents)
            }
            Section("Near Miss Ratio") {
                ehsResult(
                    label: "Near Miss Ratio %",
                    value: String(format: "%.1f%%", result),
                    color: result >= 80 ? .green : result >= 60 ? .orange : .red
                )
                Text("High ratio indicates effective hazard identification and prevention culture.")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("Near Miss Ratio")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Accident Cost Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct AccidentCostCalculator: View {
    @State private var directCost: String = "50000"
    @State private var ratio: String = "4"
    
    var indirectCost: Double {
        let dc = Double(directCost) ?? 0
        let r = Double(ratio) ?? 1
        return dc * r
    }
    
    var totalCost: Double {
        let dc = Double(directCost) ?? 0
        return dc + indirectCost
    }
    
    var body: some View {
        Form {
            Section("Accident Costs") {
                EHSInput(label: "Direct Cost", unit: "$", text: $directCost)
                EHSInput(label: "Indirect/Direct Ratio", unit: "ratio", text: $ratio)
            }
            Section("Bird's Ratio Model") {
                ehsRow(label: "Direct Costs", value: String(format: "$%.0f", Double(directCost) ?? 0))
                ehsRow(label: "Indirect Costs", value: String(format: "$%.0f", indirectCost))
            }
            Section("Total Accident Cost") {
                ehsResult(label: "Total Cost", value: String(format: "$%.0f", totalCost), color: .red)
                Text("Bird's ratio estimates indirect costs at 4-5× direct costs (medical, lost time, equipment damage).")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .navigationTitle("Accident Cost")
    }
}
