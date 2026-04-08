import SwiftUI

struct LeanView: View {
    @Environment(UnitManager.self) private var unitManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: LeadTimeCalculator()) {
                            lRow(title: "Lead Time", icon: "hourglass.bottomhalf.fill", subtitle: "Total cycle time", color: .blue)
                        }
                        NavigationLink(destination: CycleEfficiencyCalculator()) {
                            lRow(title: "PCE", icon: "chart.line.uptrend.xyaxis", subtitle: "Process efficiency", color: .blue)
                        }
                        NavigationLink(destination: WIPCalculator()) {
                            lRow(title: "WIP", icon: "square.stack.fill", subtitle: "Work in progress", color: .indigo)
                        }
                        NavigationLink(destination: LineBalancingCalculator()) {
                            lRow(title: "Line Balance", icon: "line.horizontal.3.decrease", subtitle: "Production balance", color: .purple)
                        }
                    } header: {
                        lHeader(title: "Process Metrics", color: .blue)
                    }
                    
                    Section {
                        NavigationLink(destination: KanbanCalculator()) {
                            lRow(title: "Kanban Cards", icon: "square.on.square.fill", subtitle: "Pull system sizing", color: .green)
                        }
                        NavigationLink(destination: SMEDCalculator()) {
                            lRow(title: "SMED", icon: "bolt.fill", subtitle: "Setup time reduction", color: .green)
                        }
                        NavigationLink(destination: ThroughputCalculator()) {
                            lRow(title: "Throughput", icon: "speedometer", subtitle: "Production rate", color: .teal)
                        }
                        NavigationLink(destination: VSECalculator()) {
                            lRow(title: "VSE", icon: "percent", subtitle: "Value stream eff.", color: .orange)
                        }
                    } header: {
                        lHeader(title: "Lean Optimization", color: .green)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Lean Manufacturing")
        }
    }
    
    private func lHeader(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 3, height: 14)
            Text(title.uppercased()).font(.caption).fontWeight(.heavy).foregroundColor(color)
        }
    }
    
    private func lRow(title: String, icon: String, subtitle: String, color: Color) -> some View {
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

private struct LInput: View {
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

private func lResult(label: String, value: String, color: Color = .orange) -> some View {
    VStack(spacing: 6) {
        Text(value)
            .font(.system(size: 34, weight: .black, design: .rounded))
            .foregroundColor(color)
        Text(label)
            .font(.caption).foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity).padding()
}

private func lRow(label: String, value: String) -> some View {
    HStack {
        Text(label)
        Spacer()
        Text(value).fontWeight(.bold).foregroundColor(.orange)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Lead Time Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct LeadTimeCalculator: View {
    @State private var processing: String = "10"
    @State private var waiting: String = "20"
    @State private var transport: String = "5"
    @State private var inspection: String = "3"
    
    var totalLeadTime: Double {
        let p: Double = Double(processing) ?? 0
        let w: Double = Double(waiting) ?? 0
        let t: Double = Double(transport) ?? 0
        let i: Double = Double(inspection) ?? 0
        return p + w + t + i
    }
    
    var body: some View {
        Form {
            Section("Time Components") {
                LInput(label: "Processing Time", unit: "hrs", text: $processing)
                LInput(label: "Waiting Time", unit: "hrs", text: $waiting)
                LInput(label: "Transport Time", unit: "hrs", text: $transport)
                LInput(label: "Inspection Time", unit: "hrs", text: $inspection)
            }
            Section("Result") {
                lResult(label: "Total Lead Time", value: String(format: "%.1f hrs", totalLeadTime), color: .blue)
            }
        }
        .navigationTitle("Lead Time Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Cycle Efficiency Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CycleEfficiencyCalculator: View {
    @State private var valueAddedTime: String = "12"
    @State private var leadTime: String = "38"
    
    var pce: Double {
        let va = Double(valueAddedTime) ?? 0
        let lt = Double(leadTime) ?? 1
        return (va / lt) * 100
    }
    
    var body: some View {
        Form {
            Section("Process Data") {
                LInput(label: "Value-Added Time", unit: "hrs", text: $valueAddedTime)
                LInput(label: "Total Lead Time", unit: "hrs", text: $leadTime)
            }
            Section("Result") {
                lResult(label: "Process Cycle Efficiency", value: String(format: "%.1f%%", pce), color: .blue)
            }
        }
        .navigationTitle("PCE Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - WIP Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct WIPCalculator: View {
    @State private var throughput: String = "50"
    @State private var leadTime: String = "8"
    
    var wip: Double {
        (Double(throughput) ?? 0) * (Double(leadTime) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Little's Law") {
                LInput(label: "Throughput", unit: "units/hr", text: $throughput)
                LInput(label: "Lead Time", unit: "hours", text: $leadTime)
            }
            Section("Result") {
                lResult(label: "Work in Progress", value: String(format: "%.0f units", wip), color: .indigo)
            }
        }
        .navigationTitle("WIP Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Kanban Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct KanbanCalculator: View {
    @State private var dailyDemand: String = "100"
    @State private var leadTimeDays: String = "2"
    @State private var safetyFactor: String = "1.1"
    @State private var containerSize: String = "20"
    
    var kanbanCards: Int {
        let demand = Double(dailyDemand) ?? 0
        let lt = Double(leadTimeDays) ?? 0
        let sf = Double(safetyFactor) ?? 1
        let container = Double(containerSize) ?? 1
        let quantity = (demand * lt * sf) / container
        return Int(ceil(quantity))
    }
    
    var body: some View {
        Form {
            Section("Demand & Lead Time") {
                LInput(label: "Daily Demand", unit: "units", text: $dailyDemand)
                LInput(label: "Lead Time", unit: "days", text: $leadTimeDays)
                LInput(label: "Safety Factor", unit: "", text: $safetyFactor)
            }
            Section("Container") {
                LInput(label: "Container Size", unit: "units", text: $containerSize)
            }
            Section("Result") {
                lResult(label: "Kanban Cards Needed", value: String(format: "%d", kanbanCards), color: .green)
            }
        }
        .navigationTitle("Kanban Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Line Balancing Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct LineBalancingCalculator: View {
    @State private var totalTaskTime: String = "240"
    @State private var numStations: String = "6"
    @State private var bottleneckTime: String = "45"
    
    var efficiency: Double {
        let sum = Double(totalTaskTime) ?? 0
        let stations = Double(numStations) ?? 1
        let bottleneck = Double(bottleneckTime) ?? 1
        return (sum / (stations * bottleneck)) * 100
    }
    
    var body: some View {
        Form {
            Section("Production Line") {
                LInput(label: "Total Task Time", unit: "min", text: $totalTaskTime)
                LInput(label: "Number of Stations", unit: "", text: $numStations)
                LInput(label: "Bottleneck Time", unit: "min", text: $bottleneckTime)
            }
            Section("Result") {
                lResult(label: "Line Efficiency", value: String(format: "%.1f%%", efficiency), color: .purple)
            }
        }
        .navigationTitle("Line Balancing Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - SMED Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SMEDCalculator: View {
    @State private var internalSetup: String = "15"
    @State private var externalSetup: String = "25"
    
    var totalChangeover: Double {
        (Double(internalSetup) ?? 0) + (Double(externalSetup) ?? 0)
    }
    
    var externalRatio: Double {
        let external = Double(externalSetup) ?? 0
        let total = totalChangeover
        return total > 0 ? (external / total) * 100 : 0
    }
    
    var improvementPotential: String {
        let ratio = externalRatio
        if ratio >= 50 { return "High" }
        if ratio >= 30 { return "Medium" }
        return "Low"
    }
    
    var body: some View {
        Form {
            Section("Setup Times") {
                LInput(label: "Internal Setup Time", unit: "min", text: $internalSetup)
                LInput(label: "External Setup Time", unit: "min", text: $externalSetup)
            }
            Section("Result") {
                lResult(label: "Total Changeover", value: String(format: "%.1f min", totalChangeover), color: .green)
                lRow(label: "External Setup Ratio", value: String(format: "%.1f%%", externalRatio))
                lRow(label: "Improvement Potential", value: improvementPotential)
            }
        }
        .navigationTitle("SMED Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Throughput Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ThroughputCalculator: View {
    @State private var totalUnits: String = "500"
    @State private var timePeriodHours: String = "8"
    
    var unitsPerHour: Double {
        (Double(totalUnits) ?? 0) / (Double(timePeriodHours) ?? 1)
    }
    
    var unitsPerMinute: Double {
        unitsPerHour / 60
    }
    
    var body: some View {
        Form {
            Section("Production Data") {
                LInput(label: "Total Units Produced", unit: "", text: $totalUnits)
                LInput(label: "Time Period", unit: "hours", text: $timePeriodHours)
            }
            Section("Result") {
                lResult(label: "Throughput", value: String(format: "%.1f units/hr", unitsPerHour), color: .teal)
                lRow(label: "Units per Minute", value: String(format: "%.2f", unitsPerMinute))
            }
        }
        .navigationTitle("Throughput Calculator")
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - VSE Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct VSECalculator: View {
    @State private var processingTime: String = "10"
    @State private var inspectionTime: String = "2"
    @State private var totalLeadTime: String = "38"
    
    var vse: Double {
        let processing = Double(processingTime) ?? 0
        let inspection = Double(inspectionTime) ?? 0
        let total = Double(totalLeadTime) ?? 1
        return ((processing + inspection) / total) * 100
    }
    
    var body: some View {
        Form {
            Section("Value Stream Components") {
                LInput(label: "Processing Time", unit: "hrs", text: $processingTime)
                LInput(label: "Inspection Time", unit: "hrs", text: $inspectionTime)
                LInput(label: "Total Lead Time", unit: "hrs", text: $totalLeadTime)
            }
            Section("Result") {
                lResult(label: "Value Stream Efficiency", value: String(format: "%.1f%%", vse), color: .orange)
            }
        }
        .navigationTitle("VSE Calculator")
    }
}
