import SwiftUI

struct MaintenanceView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: OEEClassicCalculator()) {
                            mainRow(title: "OEE Classic", icon: "gauge.with.needle.fill", subtitle: "Availability × Performance × Quality", color: .orange)
                        }
                        NavigationLink(destination: OEE168Calculator()) {
                            mainRow(title: "OEE 168", icon: "calendar.badge.clock", subtitle: "Weekly OEE score", color: .orange)
                        }
                        NavigationLink(destination: MTBFCalculator()) {
                            mainRow(title: "MTBF", icon: "hourglass.bottomhalf.fill", subtitle: "Mean Time Between Failures", color: .purple)
                        }
                        NavigationLink(destination: MTTRCalculator()) {
                            mainRow(title: "MTTR", icon: "wrench.fill", subtitle: "Mean Time To Repair", color: .purple)
                        }
                    } header: {
                        mainHeader(title: "Availability & Reliability", color: .orange)
                    }
                    
                    Section {
                        NavigationLink(destination: MTTACalculator()) {
                            mainRow(title: "MTTA", icon: "bell.badge.fill", subtitle: "Mean Time To Acknowledge", color: .blue)
                        }
                        NavigationLink(destination: AvailabilityCalculator()) {
                            mainRow(title: "Availability", icon: "checkmark.circle.fill", subtitle: "System uptime ratio", color: .blue)
                        }
                        NavigationLink(destination: FailureRateCalculator()) {
                            mainRow(title: "Failure Rate", icon: "exclamationmark.triangle.fill", subtitle: "Failures per unit time", color: .red)
                        }
                    } header: {
                        mainHeader(title: "Maintenance Metrics", color: .blue)
                    }
                    
                    Section {
                        NavigationLink(destination: MaintenanceCostCalculator()) {
                            mainRow(title: "Maintenance Cost", icon: "dollarsign.circle.fill", subtitle: "Maintenance spend ratio", color: .green)
                        }
                    } header: {
                        mainHeader(title: "Cost Analysis", color: .green)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Maintenance")
        }
    }
    
    private func mainHeader(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 3, height: 14)
            Text(title.uppercased()).font(.caption).fontWeight(.heavy).foregroundColor(color)
        }
    }
    
    private func mainRow(title: String, icon: String, subtitle: String, color: Color) -> some View {
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Shared Input Helper
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

private struct MainInput: View {
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
                    .frame(width: 90)
                if !unit.isEmpty {
                    Text(unit).font(.caption).foregroundColor(.gray).frame(width: 60, alignment: .leading)
                }
            }
        }
    }
}

private func mainResult(label: String, value: String, color: Color = .orange) -> some View {
    VStack(spacing: 6) {
        Text(value)
            .font(.system(size: 34, weight: .black, design: .rounded))
            .foregroundColor(color)
        Text(label)
            .font(.caption).foregroundColor(.gray)
    }
    .frame(maxWidth: .infinity).padding()
}

private func mainRow(label: String, value: String) -> some View {
    HStack {
        Text(label)
        Spacer()
        Text(value).fontWeight(.bold).foregroundColor(.orange)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - OEE Classic Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct OEEClassicCalculator: View {
    @State private var plannedTime: String = "480"
    @State private var downtime: String = "30"
    @State private var idealCycleTime: String = "2.0"
    @State private var totalCount: String = "200"
    @State private var goodCount: String = "190"
    
    var results: (oee: Double, availability: Double, performance: Double, quality: Double) {
        let pt = Double(plannedTime) ?? 0
        let dt = Double(downtime) ?? 0
        let ict = Double(idealCycleTime) ?? 0
        let tc = Double(totalCount) ?? 0
        let gc = Double(goodCount) ?? 0
        
        let availability = pt > 0 ? ((pt - dt) / pt) * 100 : 0
        let performance = tc > 0 && ict > 0 ? ((gc * ict) / (pt * 60)) * 100 : 0
        let quality = tc > 0 ? (gc / tc) * 100 : 0
        let oee = (availability * performance * quality) / 10000
        
        return (oee, availability, performance, quality)
    }
    
    var body: some View {
        Form {
            Section("Availability Inputs") {
                MainInput(label: "Planned Production Time", unit: "min", text: $plannedTime)
                MainInput(label: "Downtime (Stops)", unit: "min", text: $downtime)
            }
            Section("Performance Inputs") {
                MainInput(label: "Ideal Cycle Time", unit: "sec", text: $idealCycleTime)
                MainInput(label: "Total Production Count", unit: "units", text: $totalCount)
            }
            Section("Quality Inputs") {
                MainInput(label: "Good Units", unit: "units", text: $goodCount)
            }
            Section("OEE Breakdown") {
                mainRow(label: "Availability %", value: String(format: "%.1f%%", results.availability))
                mainRow(label: "Performance %", value: String(format: "%.1f%%", results.performance))
                mainRow(label: "Quality %", value: String(format: "%.1f%%", results.quality))
            }
            Section("Overall Equipment Effectiveness") {
                mainResult(
                    label: "OEE Score",
                    value: String(format: "%.1f%%", results.oee),
                    color: results.oee >= 85 ? .green : results.oee >= 65 ? .orange : .red
                )
            }
        }
        .navigationTitle("OEE Classic")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - OEE 168 Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct OEE168Calculator: View {
    @State private var goodCount: String = "950"
    @State private var idealCycleTime: String = "30"
    
    var result: Double {
        let gc = Double(goodCount) ?? 0
        let ict = Double(idealCycleTime) ?? 0
        return (gc * ict) / (168 * 3600) * 100
    }
    
    var body: some View {
        Form {
            Section("Weekly Production") {
                MainInput(label: "Total Good Units (168h)", unit: "units", text: $goodCount)
                MainInput(label: "Ideal Cycle Time", unit: "sec", text: $idealCycleTime)
            }
            Section("Weekly Score") {
                mainResult(
                    label: "OEE 168 %",
                    value: String(format: "%.1f%%", result),
                    color: result >= 85 ? .green : result >= 65 ? .orange : .red
                )
            }
        }
        .navigationTitle("OEE 168")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - MTBF Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MTBFCalculator: View {
    @State private var totalUptime: String = "8760"
    @State private var failures: String = "2"
    
    var result: Double {
        let tu = Double(totalUptime) ?? 0
        let f = Double(failures) ?? 1
        return tu / f
    }
    
    var body: some View {
        Form {
            Section("Reliability Data") {
                MainInput(label: "Total Operating Hours", unit: "h", text: $totalUptime)
                MainInput(label: "Number of Failures", unit: "count", text: $failures)
            }
            Section("Mean Time Between Failures") {
                mainResult(label: "MTBF", value: String(format: "%.0f hours", result))
                Text("Hours of operation expected between failures.")
                    .font(.caption).foregroundColor(.gray)
            }
        }
        .navigationTitle("MTBF")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - MTTR Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MTTRCalculator: View {
    @State private var totalRepairTime: String = "12"
    @State private var repairs: String = "3"
    
    var result: Double {
        let trt = Double(totalRepairTime) ?? 0
        let r = Double(repairs) ?? 1
        return trt / r
    }
    
    var body: some View {
        Form {
            Section("Repair Data") {
                MainInput(label: "Total Repair Time", unit: "h", text: $totalRepairTime)
                MainInput(label: "Number of Repairs", unit: "count", text: $repairs)
            }
            Section("Mean Time To Repair") {
                mainResult(label: "MTTR", value: String(format: "%.2f hours", result))
                Text("Average time required to restore service after a failure.")
                    .font(.caption).foregroundColor(.gray)
            }
        }
        .navigationTitle("MTTR")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - MTTA Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MTTACalculator: View {
    @State private var totalAckTime: String = "45"
    @State private var incidents: String = "10"
    
    var result: Double {
        let tat = Double(totalAckTime) ?? 0
        let i = Double(incidents) ?? 1
        return tat / i
    }
    
    var body: some View {
        Form {
            Section("Incident Data") {
                MainInput(label: "Total Acknowledge Time", unit: "min", text: $totalAckTime)
                MainInput(label: "Number of Incidents", unit: "count", text: $incidents)
            }
            Section("Mean Time To Acknowledge") {
                mainResult(label: "MTTA", value: String(format: "%.1f min", result))
                Text("Average time to acknowledge and respond to an incident.")
                    .font(.caption).foregroundColor(.gray)
            }
        }
        .navigationTitle("MTTA")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Availability Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct AvailabilityCalculator: View {
    @State private var mtbf: String = "4380"
    @State private var mttr: String = "4"
    
    var result: Double {
        let m_bf = Double(mtbf) ?? 0
        let m_tr = Double(mttr) ?? 0
        return (m_bf / (m_bf + m_tr)) * 100
    }
    
    var body: some View {
        Form {
            Section("Reliability Metrics") {
                MainInput(label: "MTBF", unit: "hours", text: $mtbf)
                MainInput(label: "MTTR", unit: "hours", text: $mttr)
            }
            Section("System Availability") {
                mainResult(
                    label: "Availability %",
                    value: String(format: "%.2f%%", result),
                    color: result >= 99.5 ? .green : result >= 95 ? .orange : .red
                )
            }
        }
        .navigationTitle("Availability")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Failure Rate Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct FailureRateCalculator: View {
    @State private var mtbf: String = "4380"
    @State private var showFailureMethod: Bool = false
    @State private var failures: String = "5"
    @State private var hours: String = "8760"
    
    var resultFromMTBF: Double {
        let m_bf = Double(mtbf) ?? 1
        return 1.0 / m_bf
    }
    
    var resultFromCount: Double {
        let f = Double(failures) ?? 0
        let h = Double(hours) ?? 1
        return f / h
    }
    
    var finalResult: Double {
        return showFailureMethod ? resultFromCount : resultFromMTBF
    }
    
    var body: some View {
        Form {
            Section("Calculation Method") {
                Picker("Method", selection: $showFailureMethod) {
                    Text("From MTBF").tag(false)
                    Text("From Count").tag(true)
                }
            }
            
            if !showFailureMethod {
                Section("MTBF Method") {
                    MainInput(label: "MTBF", unit: "hours", text: $mtbf)
                }
            } else {
                Section("Count Method") {
                    MainInput(label: "Number of Failures", unit: "count", text: $failures)
                    MainInput(label: "Total Hours", unit: "h", text: $hours)
                }
            }
            
            Section("Failure Rate") {
                mainResult(label: "λ (Failure Rate)", value: String(format: "%.6f /h", finalResult))
                mainRow(label: "Failures per 1,000 hours", value: String(format: "%.2f", finalResult * 1000))
            }
        }
        .navigationTitle("Failure Rate")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Maintenance Cost Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MaintenanceCostCalculator: View {
    @State private var preventive: String = "25000"
    @State private var corrective: String = "15000"
    @State private var parts: String = "10000"
    @State private var assetValue: String = "500000"
    
    var result: Double {
        let p = Double(preventive) ?? 0
        let c = Double(corrective) ?? 0
        let pt = Double(parts) ?? 0
        let av = Double(assetValue) ?? 1
        let total = p + c + pt
        return (total / av) * 100
    }
    
    var body: some View {
        Form {
            Section("Maintenance Costs") {
                MainInput(label: "Preventive Maintenance", unit: "$", text: $preventive)
                MainInput(label: "Corrective Maintenance", unit: "$", text: $corrective)
                MainInput(label: "Parts & Materials", unit: "$", text: $parts)
            }
            Section("Asset Value") {
                MainInput(label: "Asset Value", unit: "$", text: $assetValue)
            }
            Section("Maintenance Cost Ratio") {
                mainResult(
                    label: "Cost Ratio %",
                    value: String(format: "%.2f%%", result),
                    color: result <= 5 ? .green : result <= 10 ? .orange : .red
                )
                Text("Annual maintenance spend as % of asset value. Target: 3-5%")
                    .font(.caption).foregroundColor(.gray)
            }
        }
        .navigationTitle("Maintenance Cost")
        .preferredColorScheme(.dark)
    }
}
