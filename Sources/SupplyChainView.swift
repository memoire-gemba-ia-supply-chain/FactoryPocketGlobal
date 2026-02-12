import SwiftUI

struct SupplyChainView: View {
    @Environment(UnitManager.self) private var unitManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: TurnoverCalculator()) {
                            scRow(title: L10n.turnover, icon: "arrow.triangle.2.circlepath", subtitle: L10n.turnoverSub, color: .blue)
                        }
                        NavigationLink(destination: DSICalculator()) {
                            scRow(title: L10n.dsi, icon: "calendar.badge.clock", subtitle: L10n.dsiSub, color: .blue)
                        }
                        NavigationLink(destination: SafetyStockCalculator()) {
                            scRow(title: L10n.safetyStock, icon: "shield.fill", subtitle: L10n.safetyStockSub, color: .indigo)
                        }
                        NavigationLink(destination: ROPCalculator()) {
                            scRow(title: L10n.rop, icon: "bell.badge.fill", subtitle: L10n.ropSub, color: .indigo)
                        }
                        NavigationLink(destination: EOQCalculator()) {
                            scRow(title: L10n.eoq, icon: "shippingbox.fill", subtitle: L10n.eoqSub, color: .purple)
                        }
                    } header: {
                        scHeader(title: L10n.inventoryMgmt, color: .blue)
                    }
                    
                    Section {
                        NavigationLink(destination: FillRateCalculator()) {
                            scRow(title: L10n.fillRate, icon: "checklist", subtitle: L10n.fillRateSub, color: .green)
                        }
                        NavigationLink(destination: OTDCalculator()) {
                            scRow(title: L10n.otd, icon: "truck.box.fill", subtitle: L10n.otdSub, color: .green)
                        }
                        NavigationLink(destination: FreightCalculator()) {
                            scRow(title: L10n.freightCost, icon: "airplane.departure", subtitle: L10n.freightCostSub, color: .teal)
                        }
                    } header: {
                        scHeader(title: L10n.logisticsFulfill, color: .green)
                    }
                    
                    Section {
                        NavigationLink(destination: TaktTimeCalculator()) {
                            scRow(title: L10n.taktTime, icon: "clock.fill", subtitle: L10n.taktTimeSub, color: .orange)
                        }
                        NavigationLink(destination: OEECalculator()) {
                            scRow(title: L10n.oee, icon: "gauge.with.needle.fill", subtitle: L10n.oeeSub, color: .orange)
                        }
                        NavigationLink(destination: UtilizationCalculator()) {
                            scRow(title: L10n.machineUtil, icon: "gear.circle.fill", subtitle: L10n.machineUtilSub, color: .orange)
                        }
                        NavigationLink(destination: SixSigmaCalculator()) {
                            scRow(title: L10n.sixSigma, icon: "sigma", subtitle: L10n.sixSigmaSub, color: .orange)
                        }
                    } header: {
                        scHeader(title: L10n.leanOps, color: .orange)
                    }
                    
                    Section {
                        NavigationLink(destination: PartWeightCalculator()) {
                            scRow(title: L10n.partWeight, icon: "scalemass.fill", subtitle: L10n.partWeightSub, color: .gray)
                        }
                        NavigationLink(destination: ScrapRateCalculator()) {
                            scRow(title: L10n.scrapRate, icon: "trash.fill", subtitle: L10n.scrapRateSub, color: .gray)
                        }
                    } header: {
                        scHeader(title: L10n.utility, color: .gray)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(L10n.supplyChainTitle)
        }
    }
    
    private func scHeader(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 3, height: 14)
            Text(title.uppercased()).font(.caption).fontWeight(.heavy).foregroundColor(color)
        }
    }
    
    private func scRow(title: String, icon: String, subtitle: String, color: Color) -> some View {
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

private struct SCInput: View {
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
                    Text(unit).font(.caption).foregroundColor(.gray).frame(width: 45, alignment: .leading)
                }
            }
        }
    }
}

private func scResult(label: String, value: String, color: Color = .orange) -> some View {
    VStack(spacing: 6) {
        Text(value)
            .font(.system(size: 34, weight: .black, design: .rounded))
            .foregroundColor(color)
        Text(label)
            .font(.caption).foregroundColor(.gray)
    }
    .frame(maxWidth: .infinity).padding()
}

private func scRow(label: String, value: String) -> some View {
    HStack {
        Text(label)
        Spacer()
        Text(value).fontWeight(.bold).foregroundColor(.orange)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Inventory Calculators
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct TurnoverCalculator: View {
    @State private var cogs: String = "500000"
    @State private var avgInv: String = "100000"
    
    var result: Double {
        FormulaEngine.shared.inventoryTurnover(cogs: Double(cogs) ?? 0, avgInventory: Double(avgInv) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Financial Inputs") {
                SCInput(label: "Cost of Goods Sold", unit: "$/yr", text: $cogs)
                SCInput(label: "Average Inventory", unit: "$", text: $avgInv)
            }
            Section("KPI") {
                scResult(
                    label: "Inventory Turns per Year",
                    value: String(format: "%.2fx", result),
                    color: result >= 6 ? .green : result >= 4 ? .orange : .red
                )
            }
        }
        .navigationTitle("Inventory Turnover")
        .preferredColorScheme(.dark)
    }
}

struct DSICalculator: View {
    @State private var cogs: String = "500000"
    @State private var avgInv: String = "100000"
    
    var result: Double {
        FormulaEngine.shared.daysSalesInventory(avgInventory: Double(avgInv) ?? 0, cogs: Double(cogs) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Financial Inputs") {
                SCInput(label: "Average Inventory", unit: "$", text: $avgInv)
                SCInput(label: "Cost of Goods Sold", unit: "$/yr", text: $cogs)
            }
            Section("KPI") {
                scResult(label: "Days of Stock on Hand", value: String(format: "%.1f days", result))
            }
        }
        .navigationTitle("DSI Calculator")
        .preferredColorScheme(.dark)
    }
}

struct SafetyStockCalculator: View {
    @State private var maxDaily: String = "120"
    @State private var maxLead: String = "15"
    @State private var avgDaily: String = "100"
    @State private var avgLead: String = "10"
    
    var result: Double {
        FormulaEngine.shared.safetyStock(
            maxDailyUsage: Double(maxDaily) ?? 0,
            maxLeadTime: Double(maxLead) ?? 0,
            avgDailyUsage: Double(avgDaily) ?? 0,
            avgLeadTime: Double(avgLead) ?? 0
        )
    }
    
    var body: some View {
        Form {
            Section("Demand Variability") {
                SCInput(label: "Max Daily Usage", unit: "units/d", text: $maxDaily)
                SCInput(label: "Avg Daily Usage", unit: "units/d", text: $avgDaily)
            }
            Section("Lead Time Variability") {
                SCInput(label: "Max Lead Time", unit: "days", text: $maxLead)
                SCInput(label: "Avg Lead Time", unit: "days", text: $avgLead)
            }
            Section("Buffer") {
                scResult(label: "Safety Stock Buffer", value: String(format: "%.0f units", result))
            }
        }
        .navigationTitle("Safety Stock")
        .preferredColorScheme(.dark)
    }
}

struct ROPCalculator: View {
    @State private var avgDaily: String = "100"
    @State private var avgLead: String = "10"
    @State private var safety: String = "800"
    
    var result: Double {
        FormulaEngine.shared.reorderPoint(
            avgDailyUsage: Double(avgDaily) ?? 0,
            avgLeadTime: Double(avgLead) ?? 0,
            safetyStock: Double(safety) ?? 0
        )
    }
    
    var body: some View {
        Form {
            Section("Demand Parameters") {
                SCInput(label: "Avg Daily Usage", unit: "units/d", text: $avgDaily)
                SCInput(label: "Avg Lead Time", unit: "days", text: $avgLead)
                SCInput(label: "Safety Stock", unit: "units", text: $safety)
            }
            Section("Reorder Alert") {
                scResult(label: "Reorder When Stock Reaches", value: String(format: "%.0f units", result), color: .red)
                Text("Place a new purchase order when inventory drops to this level.")
                    .font(.caption).foregroundColor(.gray)
            }
        }
        .navigationTitle("Reorder Point")
        .preferredColorScheme(.dark)
    }
}

struct EOQCalculator: View {
    @State private var demand: String = "10000"
    @State private var orderCost: String = "150"
    @State private var holdCost: String = "2.5"
    
    var result: EOQResult {
        FormulaEngine.shared.eoq(
            annualDemand: Double(demand) ?? 0,
            orderingCost: Double(orderCost) ?? 0,
            holdingCostPerUnit: Double(holdCost) ?? 0
        )
    }
    
    var body: some View {
        Form {
            Section("Demand & Costs") {
                SCInput(label: "Annual Demand", unit: "units/yr", text: $demand)
                SCInput(label: "Cost per Order", unit: "$/order", text: $orderCost)
                SCInput(label: "Holding Cost", unit: "$/unit/yr", text: $holdCost)
            }
            Section("Optimal Strategy") {
                scResult(label: "Economic Order Quantity", value: String(format: "%.0f units", result.optimalQuantity))
                scRow(label: "Orders per Year", value: String(format: "%.1f", result.ordersPerYear))
            }
            Section("Annual Cost Breakdown") {
                scRow(label: "Ordering Cost", value: String(format: "$%.0f /yr", result.orderingCostPerYear))
                scRow(label: "Holding Cost", value: String(format: "$%.0f /yr", result.holdingCostPerYear))
                HStack {
                    Text("Total Inventory Cost").fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "$%.0f /yr", result.totalCost))
                        .fontWeight(.black).foregroundColor(.green)
                }
            }
        }
        .navigationTitle("EOQ (Wilson)")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Logistics Calculators
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct FillRateCalculator: View {
    @State private var placed: String = "100"
    @State private var shipped: String = "95"
    
    var result: Double {
        FormulaEngine.shared.orderFillRate(shipped: Double(shipped) ?? 0, placed: Double(placed) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Order Data") {
                SCInput(label: "Orders Shipped Complete", unit: "orders", text: $shipped)
                SCInput(label: "Total Orders Placed", unit: "orders", text: $placed)
            }
            Section("Service Level") {
                scResult(
                    label: "Order Fill Rate",
                    value: String(format: "%.1f%%", result),
                    color: result >= 98 ? .green : result >= 95 ? .orange : .red
                )
            }
        }
        .navigationTitle("Fill Rate")
        .preferredColorScheme(.dark)
    }
}

struct OTDCalculator: View {
    @State private var onTime: String = "90"
    @State private var total: String = "100"
    
    var result: Double {
        FormulaEngine.shared.onTimeDelivery(onTime: Double(onTime) ?? 0, total: Double(total) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Delivery Performance") {
                SCInput(label: "On-Time Deliveries", unit: "orders", text: $onTime)
                SCInput(label: "Total Deliveries", unit: "orders", text: $total)
            }
            Section("KPI") {
                scResult(
                    label: "On-Time Delivery Score",
                    value: String(format: "%.1f%%", result),
                    color: result >= 95 ? .green : .red
                )
            }
        }
        .navigationTitle("On-Time Delivery")
        .preferredColorScheme(.dark)
    }
}

struct FreightCalculator: View {
    @State private var cost: String = "5000"
    @State private var units: String = "2000"
    
    var result: Double {
        FormulaEngine.shared.freightCostPerUnit(totalCost: Double(cost) ?? 0, units: Double(units) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Shipment Data") {
                SCInput(label: "Total Freight Cost", unit: "$", text: $cost)
                SCInput(label: "Units Shipped", unit: "units", text: $units)
            }
            Section("Unit Economics") {
                scResult(label: "Freight Cost per Unit", value: String(format: "$%.2f", result))
            }
        }
        .navigationTitle("Freight Cost")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Lean & Operations
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct TaktTimeCalculator: View {
    @State private var availableTime: String = "3600"
    @State private var demand: String = "60"
    
    var result: Double {
        FormulaEngine.shared.taktTime(availableTimeSeconds: Double(availableTime) ?? 0, customerDemand: Double(demand) ?? 0)
    }
    
    var body: some View {
        Form {
            Section("Production Parameters") {
                SCInput(label: "Available Time", unit: "sec", text: $availableTime)
                SCInput(label: "Customer Demand", unit: "units", text: $demand)
            }
            Section("Pace") {
                scResult(label: "Takt Time", value: String(format: "%.2f sec/unit", result))
            }
        }
        .navigationTitle("Takt Time")
        .preferredColorScheme(.dark)
    }
}

struct OEECalculator: View {
    @State private var avail: Double = 90
    @State private var perf: Double = 90
    @State private var qual: Double = 95
    
    var result: OEEResult {
        FormulaEngine.shared.oee(availability: avail, performance: perf, quality: qual)
    }
    
    var body: some View {
        Form {
            Section("OEE Factors (%)") {
                VStack(spacing: 4) {
                    HStack { Text("Availability"); Spacer(); Text(String(format: "%.0f%%", avail)).foregroundColor(.orange) }
                    Slider(value: $avail, in: 0...100, step: 1).tint(.orange)
                }
                VStack(spacing: 4) {
                    HStack { Text("Performance"); Spacer(); Text(String(format: "%.0f%%", perf)).foregroundColor(.blue) }
                    Slider(value: $perf, in: 0...100, step: 1).tint(.blue)
                }
                VStack(spacing: 4) {
                    HStack { Text("Quality"); Spacer(); Text(String(format: "%.0f%%", qual)).foregroundColor(.green) }
                    Slider(value: $qual, in: 0...100, step: 1).tint(.green)
                }
            }
            Section("Overall Equipment Effectiveness") {
                VStack(spacing: 12) {
                    Text(String(format: "%.1f%%", result.oee))
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .foregroundColor(.orange)
                    Text(result.rating.rawValue)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity).padding()
            }
        }
        .navigationTitle("OEE Calculator")
        .preferredColorScheme(.dark)
    }
}

struct SixSigmaCalculator: View {
    @State private var usl: String = "10.1"
    @State private var lsl: String = "9.9"
    @State private var mean: String = "10.0"
    @State private var sigma: String = "0.02"
    
    var result: SixSigmaResult {
        FormulaEngine.shared.sixSigma(usl: Double(usl) ?? 0, lsl: Double(lsl) ?? 0, mean: Double(mean) ?? 0, sigma: Double(sigma) ?? 0.0001)
    }
    
    var body: some View {
        Form {
            Section("Process Specification") {
                SCInput(label: "Upper Spec Limit (USL)", unit: "", text: $usl)
                SCInput(label: "Lower Spec Limit (LSL)", unit: "", text: $lsl)
                SCInput(label: "Process Mean (μ)", unit: "", text: $mean)
                SCInput(label: "Std Deviation (σ)", unit: "", text: $sigma)
            }
            Section("Capability Indices") {
                scRow(label: "Cp", value: String(format: "%.3f", result.cp))
                scRow(label: "Cpk", value: String(format: "%.3f", result.cpk))
                scRow(label: "Sigma Level", value: String(format: "%.2fσ", result.sigmaLevel))
            }
            Section("Assessment") {
                Text(result.capability.rawValue).fontWeight(.bold).foregroundColor(.orange)
            }
        }
        .navigationTitle("Six Sigma")
        .preferredColorScheme(.dark)
    }
}

struct UtilizationCalculator: View {
    @State private var runTime: String = "7.5"
    @State private var totalTime: String = "8.0"
    
    var rate: Double { FormulaEngine.shared.machineUtilization(runTime: Double(runTime) ?? 0, totalTime: Double(totalTime) ?? 0) }
    
    var body: some View {
        Form {
            Section("Shift Data") {
                SCInput(label: "Actual Run Time", unit: "hours", text: $runTime)
                SCInput(label: "Total Available Time", unit: "hours", text: $totalTime)
            }
            Section("KPI") {
                scResult(
                    label: "Machine Utilization",
                    value: String(format: "%.1f%%", rate),
                    color: rate > 85 ? .green : rate > 60 ? .orange : .red
                )
            }
        }
        .navigationTitle("Machine Utilization")
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Utility
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct PartWeightCalculator: View {
    @State private var volume: String = "100"
    @State private var density: String = "0.95"
    
    var weight: Double { FormulaEngine.shared.partWeight(volumeCm3: Double(volume) ?? 0, density: Double(density) ?? 0) }
    
    var body: some View {
        Form {
            Section("Material Inputs") {
                SCInput(label: "Part Volume", unit: "cm³", text: $volume)
                SCInput(label: "Material Density", unit: "g/cm³", text: $density)
            }
            Section("Result") {
                scResult(label: "Calculated Part Weight", value: String(format: "%.2f g", weight))
            }
        }
        .navigationTitle("Part Weight")
        .preferredColorScheme(.dark)
    }
}

struct ScrapRateCalculator: View {
    @State private var total: String = "1000"
    @State private var scrap: String = "25"
    
    var rate: Double { FormulaEngine.shared.scrapRate(totalParts: Double(total) ?? 0, scrapParts: Double(scrap) ?? 0) }
    
    var body: some View {
        Form {
            Section("Production Run") {
                SCInput(label: "Total Parts Produced", unit: "pcs", text: $total)
                SCInput(label: "Scrap / Rejected Parts", unit: "pcs", text: $scrap)
            }
            Section("Quality KPI") {
                scResult(
                    label: "Scrap Rate",
                    value: String(format: "%.2f%%", rate),
                    color: rate > 5 ? .red : rate > 2 ? .orange : .green
                )
            }
        }
        .navigationTitle("Scrap Rate")
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SupplyChainView()
        .environment(UnitManager.shared)
}
