import SwiftUI

struct TechnicalView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                
                List {
                    Section {
                        NavigationLink(destination: CylinderForceCalculator()) {
                            calcRow(title: L10n.cylinderForce, icon: "drop.fill", subtitle: L10n.cylinderForceSub, color: .cyan)
                        }
                        NavigationLink(destination: HydraulicPowerCalculator()) {
                            calcRow(title: L10n.hydraulicPower, icon: "bolt.horizontal.fill", subtitle: L10n.hydraulicPowerSub, color: .cyan)
                        }
                        NavigationLink(destination: FlowVelocityCalculator()) {
                            calcRow(title: L10n.flowVelocity, icon: "arrow.right.circle.fill", subtitle: L10n.flowVelocitySub, color: .cyan)
                        }
                        NavigationLink(destination: PipePressureLossCalculator()) {
                            calcRow(title: L10n.pipePressureLoss, icon: "pipe.and.drop.fill", subtitle: L10n.pipePressureLossSub, color: .cyan)
                        }
                    } header: {
                        sectionHeader(title: L10n.hydraulics, color: .cyan)
                    }
                    
                    Section {
                        NavigationLink(destination: ClampingForceCalculator()) {
                            calcRow(title: L10n.clampingForce, icon: "cube.transparent.fill", subtitle: L10n.clampingForceSub, color: .blue)
                        }
                        NavigationLink(destination: CoolingTimeCalculator()) {
                            calcRow(title: L10n.coolingTime, icon: "thermometer.snowflake", subtitle: L10n.coolingTimeSub, color: .blue)
                        }
                    } header: {
                        sectionHeader(title: L10n.injectionMolding, color: .blue)
                    }
                    
                    Section {
                        NavigationLink(destination: VoltageDropCalculator()) {
                            calcRow(title: L10n.voltageDrop, icon: "bolt.fill", subtitle: L10n.voltageDropSub, color: .yellow)
                        }
                        NavigationLink(destination: MotorCalculatorView()) {
                            calcRow(title: L10n.threePhaseMotor, icon: "battery.100percent.bolt", subtitle: L10n.threePhaseMotorSub, color: .yellow)
                        }
                        NavigationLink(destination: CableSizingCalculator()) {
                            calcRow(title: L10n.cableSizing, icon: "cable.connector", subtitle: L10n.cableSizingSub, color: .yellow)
                        }
                        NavigationLink(destination: CapacitorBankCalculator()) {
                            calcRow(title: L10n.capacitorBank, icon: "bolt.ring.closed", subtitle: L10n.capacitorBankSub, color: .yellow)
                        }
                        NavigationLink(destination: TransformerSizingCalculator()) {
                            calcRow(title: L10n.transformerSizing, icon: "square.grid.3x3.fill", subtitle: L10n.transformerSizingSub, color: .yellow)
                        }
                    } header: {
                        sectionHeader(title: L10n.electrical, color: .yellow)
                    }
                    
                    Section {
                        NavigationLink(destination: AirLeakCalculator()) {
                            calcRow(title: L10n.airLeakCost, icon: "wind", subtitle: L10n.airLeakCostSub, color: .gray)
                        }
                        NavigationLink(destination: PneumaticCylinderCalculator()) {
                            calcRow(title: L10n.pneumaticCylinder, icon: "arrow.up.and.down.circle.fill", subtitle: L10n.pneumaticCylinderSub, color: .gray)
                        }
                        NavigationLink(destination: ValveCvCalculator()) {
                            calcRow(title: L10n.valveCv, icon: "gauge.with.dots.needle.33percent", subtitle: L10n.valveCvSub, color: .gray)
                        }
                    } header: {
                        sectionHeader(title: L10n.pneumatics, color: .gray)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(L10n.technical)
        }
    }
    
    private func sectionHeader(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3, height: 14)
            Text(title.uppercased())
                .font(.caption).fontWeight(.heavy)
                .foregroundColor(color)
        }
    }
    
    private func calcRow(title: String, icon: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(color)
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
// MARK: - Shared Helpers
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

private func resultRow(label: String, value: String) -> some View {
    HStack {
        Text(label)
        Spacer()
        Text(value)
            .fontWeight(.bold)
            .foregroundColor(.orange)
    }
}

private func bigResult(label: String, value: String, color: Color = .orange) -> some View {
    VStack(spacing: 6) {
        Text(value)
            .font(.system(size: 36, weight: .black, design: .rounded))
            .foregroundColor(color)
        Text(label)
            .font(.caption).foregroundColor(.gray)
    }
    .frame(maxWidth: .infinity)
    .padding()
}

private struct InputField: View {
    let label: String
    let unit: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 4) {
                TextField("0", text: $text)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption).foregroundColor(.gray)
                        .frame(width: 40, alignment: .leading)
                }
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Hydraulics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CylinderForceCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var pressure: String = "200"
    @State private var pistonD: String = "100"
    @State private var rodD: String = "50"
    
    var result: CylinderForceResult {
        if unitManager.isMetric {
            return FormulaEngine.shared.cylinderForceMetric(
                pressureBar: Double(pressure) ?? 0,
                pistonDiameterMM: Double(pistonD) ?? 0,
                rodDiameterMM: Double(rodD) ?? 0
            )
        } else {
            return FormulaEngine.shared.cylinderForceImperial(
                pressurePSI: Double(pressure) ?? 0,
                pistonDiameterInch: Double(pistonD) ?? 0,
                rodDiameterInch: Double(rodD) ?? 0
            )
        }
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.pressureParam, unit: unitManager.pressureUnit, text: $pressure)
                InputField(label: L10n.pistonDiameter, unit: unitManager.lengthUnit, text: $pistonD)
                InputField(label: L10n.rodDiameter, unit: unitManager.lengthUnit, text: $rodD)
            }
            Section(L10n.results) {
                resultRow(label: L10n.pushForce, value: String(format: "%.0f %@", result.pushForce, unitManager.forceUnit))
                resultRow(label: L10n.pullForce, value: String(format: "%.0f %@", result.pullForce, unitManager.forceUnit))
            }
        }
        .navigationTitle(L10n.cylinderForce)
        .preferredColorScheme(.dark)
    }
}

struct HydraulicPowerCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var flow: String = "60"
    @State private var pressure: String = "250"
    
    var result: HydraulicPowerResult {
        if unitManager.isMetric {
            return FormulaEngine.shared.hydraulicPowerMetric(
                flowLPM: Double(flow) ?? 0,
                pressureBar: Double(pressure) ?? 0
            )
        } else {
            return FormulaEngine.shared.hydraulicPowerImperial(
                flowGPM: Double(flow) ?? 0,
                pressurePSI: Double(pressure) ?? 0
            )
        }
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.flowRate, unit: unitManager.flowUnit, text: $flow)
                InputField(label: L10n.pressureParam, unit: unitManager.pressureUnit, text: $pressure)
            }
            Section(L10n.results) {
                bigResult(label: L10n.hydraulicPower, value: String(format: "%.2f %@", result.power, result.unit))
            }
        }
        .navigationTitle(L10n.hydraulicPower)
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Injection Molding
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ClampingForceCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var area: String = "500"
    @State private var pressure: String = "300"
    
    var result: Double {
        if unitManager.isMetric {
            return FormulaEngine.shared.clampingForceMetric(
                projectedAreaCm2: Double(area) ?? 0,
                cavityPressureBar: Double(pressure) ?? 0
            )
        } else {
            return FormulaEngine.shared.clampingForceImperial(
                projectedAreaIn2: Double(area) ?? 0,
                cavityPressurePSI: Double(pressure) ?? 0
            )
        }
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.area, unit: unitManager.isMetric ? "cm²" : "in²", text: $area)
                InputField(label: L10n.pressureParam, unit: unitManager.pressureUnit, text: $pressure)
            }
            Section(L10n.results) {
                bigResult(label: L10n.clampingForceLabel, value: String(format: "%.1f %@", result, unitManager.isMetric ? "kN" : "Tons"))
            }
        }
        .navigationTitle(L10n.clampingForce)
        .preferredColorScheme(.dark)
    }
}

struct CoolingTimeCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var wallThickness: String = "3.0"
    @State private var diffusivity: String = "0.1"
    @State private var meltTemp: String = "230"
    @State private var moldTemp: String = "40"
    @State private var ejectTemp: String = "90"
    
    var result: Double {
        let thickVal = Double(wallThickness) ?? 0
        let meltVal  = Double(meltTemp) ?? 0
        let moldVal  = Double(moldTemp) ?? 0
        let ejectVal = Double(ejectTemp) ?? 0
        
        let thickMM = unitManager.isMetric ? thickVal : unitManager.inchToMm(thickVal)
        let meltC   = unitManager.isMetric ? meltVal : unitManager.fahrenheitToCelsius(meltVal)
        let moldC   = unitManager.isMetric ? moldVal : unitManager.fahrenheitToCelsius(moldVal)
        let ejectC  = unitManager.isMetric ? ejectVal : unitManager.fahrenheitToCelsius(ejectVal)
        
        return FormulaEngine.shared.coolingTime(
            wallThicknessMM: thickMM,
            thermalDiffusivity: Double(diffusivity) ?? 0.1,
            meltTemp: meltC,
            moldTemp: moldC,
            ejectTemp: ejectC
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.thickness, unit: unitManager.lengthUnit, text: $wallThickness)
                InputField(label: L10n.thermalDiffusivity, unit: "mm²/s", text: $diffusivity)
            }
            Section(L10n.temperatureParam) {
                InputField(label: L10n.meltTemp, unit: unitManager.temperatureUnit, text: $meltTemp)
                InputField(label: L10n.moldTemp, unit: unitManager.temperatureUnit, text: $moldTemp)
                InputField(label: L10n.ejectTemp, unit: unitManager.temperatureUnit, text: $ejectTemp)
            }
            Section(L10n.results) {
                bigResult(label: L10n.coolingTimeLabel, value: String(format: "%.2f s", result))
            }
        }
        .navigationTitle(L10n.coolingTime)
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Electrical
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct VoltageDropCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var length: String = "100"
    @State private var current: String = "20"
    @State private var section: String = "2.5"
    @State private var awgIndex: Int = 0 // 0 = 14 AWG
    @State private var voltage: String = "400"
    @State private var material: ConductorMaterial = .copper
    
    let awgValues: [(String, Double)] = [
        ("14 AWG", 2.08), ("12 AWG", 3.31), ("10 AWG", 5.26),
        ("8 AWG", 8.37), ("6 AWG", 13.3), ("4 AWG", 21.2),
        ("2 AWG", 33.6), ("1 AWG", 42.4), ("1/0 AWG", 53.5),
        ("2/0 AWG", 67.4), ("3/0 AWG", 85.0), ("4/0 AWG", 107.0)
    ]
    
    var result: VoltageDropResult {
        let lenVal = Double(length) ?? 0
        let lenMeters = unitManager.isMetric ? lenVal : lenVal * 0.3048
        
        let sectionMM2: Double
        if unitManager.isMetric {
            sectionMM2 = Double(section) ?? 1.0
        } else {
            sectionMM2 = awgValues[awgIndex].1
        }
        
        return FormulaEngine.shared.voltageDrop(
            conductor: material,
            lengthMeters: lenMeters,
            crossSectionMM2: sectionMM2,
            currentAmps: Double(current) ?? 0,
            cosPhi: 0.85,
            supplyVoltage: Double(voltage) ?? 400
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                Picker("Conductor Material", selection: $material) {
                    ForEach(ConductorMaterial.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                InputField(label: L10n.length, unit: unitManager.lengthUnit, text: $length)
                
                if unitManager.isMetric {
                    InputField(label: "Cross-section", unit: "mm²", text: $section)
                } else {
                    Picker("Wire Size (AWG)", selection: $awgIndex) {
                        ForEach(0..<awgValues.count, id: \.self) { i in
                            Text(awgValues[i].0).tag(i)
                        }
                    }
                }
                
                InputField(label: L10n.currentParam, unit: "A", text: $current)
                InputField(label: L10n.voltageParam, unit: "V", text: $voltage)
            }
            Section(L10n.results) {
                resultRow(label: L10n.voltageDrop, value: String(format: "%.2f V", result.voltageDrop))
                HStack {
                    Text("Drop Percentage")
                    Spacer()
                    Text(String(format: "%.2f%%", result.voltageDropPercent))
                        .fontWeight(.bold)
                        .foregroundColor(result.isAcceptable ? .green : .red)
                }
                HStack {
                    Text("Status")
                    Spacer()
                    Text(result.isAcceptable ? "✅ Acceptable (≤ 5%)" : "⚠️ Exceeds limit")
                        .foregroundColor(result.isAcceptable ? .green : .red)
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle(L10n.voltageDrop)
        .preferredColorScheme(.dark)
    }
}

struct MotorCalculatorView: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var voltage: String = "400"
    @State private var power: String = "11"
    @State private var pf: String = "0.85"
    @State private var efficiency: String = "0.90"
    
    var result: MotorResult {
        let powerVal = Double(power) ?? 0
        let powerKW  = unitManager.isMetric ? powerVal : unitManager.hpToKw(powerVal)
        
        return FormulaEngine.shared.motorCalculator(
            voltageV: Double(voltage) ?? 400,
            powerKW: powerKW,
            powerFactor: Double(pf) ?? 0.85,
            efficiency: Double(efficiency) ?? 0.90
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.voltageParam, unit: "V", text: $voltage)
                InputField(label: L10n.powerParam, unit: unitManager.powerUnit, text: $power)
                InputField(label: L10n.powerFactor, unit: "", text: $pf)
                InputField(label: L10n.efficiency, unit: "", text: $efficiency)
            }
            Section(L10n.results) {
                if unitManager.isMetric {
                    resultRow(label: "Active Power (P)", value: String(format: "%.2f kW", result.activePowerKW))
                } else {
                    resultRow(label: "Active Power (P)", value: String(format: "%.2f HP", unitManager.kwToHp(result.activePowerKW)))
                }
                resultRow(label: "Reactive Power (Q)", value: String(format: "%.2f kVAR", result.reactivePowerKVAR))
                resultRow(label: "Apparent Power (S)", value: String(format: "%.2f kVA", result.apparentPowerKVA))
            }
            Section(L10n.currentParam) {
                bigResult(label: "Full Load Amps (FLA)", value: String(format: "%.1f A", result.fullLoadAmps))
            }
        }
        .navigationTitle(L10n.threePhaseMotor)
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Pneumatics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct AirLeakCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var holeDiam: String = "3.0"
    @State private var pressure: String = "7.0"
    @State private var costKWh: String = "0.12"
    @State private var hours: String = "6000"
    
    var result: AirLeakResult {
        let diamVal = Double(holeDiam) ?? 0
        let pressVal = Double(pressure) ?? 0
        
        let diamMM = unitManager.isMetric ? diamVal : unitManager.inchToMm(diamVal)
        let pressBar = unitManager.isMetric ? pressVal : unitManager.psiToBar(pressVal)
        
        let raw = FormulaEngine.shared.airLeakCost(
            holeDiameterMM: diamMM,
            linePressureBar: pressBar,
            costPerKWh: Double(costKWh) ?? 0,
            annualHours: Double(hours) ?? 0
        )
        
        // If Imperial, convert flow L/min -> CFM (1 L/min = 0.0353147 CFM)
        if !unitManager.isMetric {
            return AirLeakResult(
                leakFlowRateLPM: raw.leakFlowRateLPM * 0.0353147,
                compressorPowerWastedKW: raw.compressorPowerWastedKW,
                annualEnergyCost: raw.annualEnergyCost
            )
        }
        return raw
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.diameter, unit: unitManager.lengthUnit, text: $holeDiam)
                InputField(label: L10n.pressureParam, unit: unitManager.pressureUnit, text: $pressure)
            }
            Section(L10n.energy) {
                InputField(label: L10n.cost, unit: "$/kWh", text: $costKWh)
                InputField(label: L10n.time, unit: "h/yr", text: $hours)
            }
            Section(L10n.results) {
                resultRow(label: L10n.flowRate, value: String(format: "%.1f %@", result.leakFlowRateLPM, unitManager.isMetric ? "L/min" : "CFM"))
                resultRow(label: L10n.powerParam, value: String(format: "%.2f kW", result.compressorPowerWastedKW))
                HStack {
                    Text(L10n.cost)
                    Spacer()
                    Text(String(format: "$%.0f", result.annualEnergyCost))
                        .font(.title3).fontWeight(.black).foregroundColor(.red)
                }
            }
        }
        .navigationTitle(L10n.airLeakCost)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    TechnicalView()
        .environment(UnitManager.shared)
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - New Hydraulics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct FlowVelocityCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var flow: String = "60"
    @State private var diameter: String = "25"
    
    var result: FlowVelocityResult {
        let flowVal = Double(flow) ?? 0
        let diamVal = Double(diameter) ?? 0
        
        let flowLPM = unitManager.isMetric ? flowVal : unitManager.gpmToLpm(flowVal)
        let diamMM  = unitManager.isMetric ? diamVal : unitManager.inchToMm(diamVal)
        
        return FormulaEngine.shared.flowVelocity(
            flowLPM: flowLPM,
            pipeDiameterMM: diamMM
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.flowRate, unit: unitManager.flowUnit, text: $flow)
                InputField(label: "Pipe Inner Diameter", unit: unitManager.lengthUnit, text: $diameter)
            }
            Section(L10n.results) {
                // Result is always m/s for now, could convert to ft/s if needed
                bigResult(
                    label: L10n.velocity,
                    value: String(format: "%.2f m/s", result.velocity),
                    color: result.isAcceptable ? .cyan : .red
                )
                HStack {
                    Text("Status")
                    Spacer()
                    Text(result.isAcceptable ? "✅ Acceptable (≤ 6 m/s)" : "⚠️ High velocity")
                        .foregroundColor(result.isAcceptable ? .green : .red)
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle(L10n.flowVelocity)
        .preferredColorScheme(.dark)
    }
}

struct PipePressureLossCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var flow: String = "60"
    @State private var diameter: String = "25"
    @State private var length: String = "10"

    @State private var density: String = "870"
    @State private var viscosity: String = "32"
    
    var result: PipePressureLossResult {
        let flowVal = Double(flow) ?? 0
        let diamVal = Double(diameter) ?? 0
        let lenVal  = Double(length) ?? 0
        
        let flowLPM = unitManager.isMetric ? flowVal : unitManager.gpmToLpm(flowVal)
        let diamMM  = unitManager.isMetric ? diamVal : unitManager.inchToMm(diamVal)
        let lenM    = unitManager.isMetric ? lenVal  : lenVal * 0.3048 // ft to m
        
        // Density/Viscosity usually kept in SI/Metric even in US for engineering, or specific units.
        // Keeping as is for now, assuming user inputs standard values.
        
        let rawResult = FormulaEngine.shared.pipePressureLoss(
            flowLPM: flowLPM,
            pipeDiameterMM: diamMM,
            pipeLengthM: lenM,
            fluidDensity: Double(density) ?? 870,
            kinematicViscosity: (Double(viscosity) ?? 32) * 1e-6
        )
        
        if unitManager.isMetric {
            return rawResult
        } else {
            return PipePressureLossResult(
                pressureDrop: unitManager.barToPsi(rawResult.pressureDrop),
                frictionFactor: rawResult.frictionFactor
            )
        }
    }
    
    var body: some View {
        Form {
            Section("Pipe & Fluid") {
                InputField(label: L10n.flowRate, unit: unitManager.flowUnit, text: $flow)
                InputField(label: "Inner Diameter", unit: unitManager.lengthUnit, text: $diameter)
                InputField(label: L10n.length, unit: unitManager.isMetric ? "m" : "ft", text: $length)
            }
            Section("Fluid Properties") {
                InputField(label: "Fluid Density", unit: "kg/m³", text: $density)
                InputField(label: "Kinematic Viscosity", unit: "cSt", text: $viscosity)
            }
            Section(L10n.results) {
                bigResult(
                    label: L10n.pressureDropLabel,
                    value: String(format: "%.3f %@", result.pressureDrop, unitManager.pressureUnit)
                )
                resultRow(label: "Friction Factor (f)", value: String(format: "%.4f", result.frictionFactor))
            }
        }
        .navigationTitle(L10n.pipePressureLoss)
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - New Electrical
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct CableSizingCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var length: String = "100"
    @State private var current: String = "32"
    @State private var voltage: String = "400"
    @State private var maxDrop: String = "3"
    @State private var material: ConductorMaterial = .copper
    
    var result: CableSizingResult {
        let lenVal = Double(length) ?? 0
        let lenMters = unitManager.isMetric ? lenVal : lenVal * 0.3048
        
        if unitManager.isMetric {
            return FormulaEngine.shared.cableSizing(
                conductor: material,
                lengthMeters: lenMters,
                currentAmps: Double(current) ?? 0,
                supplyVoltage: Double(voltage) ?? 400,
                maxDropPercent: Double(maxDrop) ?? 3
            )
        } else {
            return FormulaEngine.shared.cableSizingAWG(
                conductor: material,
                lengthMeters: lenMters,
                currentAmps: Double(current) ?? 0,
                supplyVoltage: Double(voltage) ?? 400,
                maxDropPercent: Double(maxDrop) ?? 3
            )
        }
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                Picker("Conductor", selection: $material) {
                    ForEach(ConductorMaterial.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                InputField(label: L10n.length, unit: unitManager.lengthUnit, text: $length)
                InputField(label: L10n.currentParam, unit: "A", text: $current)
                InputField(label: L10n.voltageParam, unit: "V", text: $voltage)
                InputField(label: "Max Allowed Drop", unit: "%", text: $maxDrop)
            }
            Section("Recommendation") {
                bigResult(
                    label: "Minimum Cross-Section",
                    value: result.recommended
                )
                resultRow(label: "Actual Voltage Drop", value: String(format: "%.2f%%", result.actualDrop))
            }
        }
        .navigationTitle(L10n.cableSizing)
        .preferredColorScheme(.dark)
    }
}

struct CapacitorBankCalculator: View {
    @State private var power: String = "100"
    @State private var currentPF: String = "0.70"
    @State private var targetPF: String = "0.95"
    @State private var voltage: String = "400"
    @State private var frequency: String = "50"
    
    var result: CapacitorBankResult {
        FormulaEngine.shared.capacitorBank(
            activePowerKW: Double(power) ?? 0,
            currentPF: Double(currentPF) ?? 0.7,
            targetPF: Double(targetPF) ?? 0.95,
            voltageV: Double(voltage) ?? 400,
            frequencyHz: Double(frequency) ?? 50
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.powerParam, unit: "kW", text: $power)
                InputField(label: "Current PF (cos φ)", unit: "", text: $currentPF)
                InputField(label: "Target PF", unit: "", text: $targetPF)
            }
            Section("System") {
                InputField(label: L10n.voltageParam, unit: "V", text: $voltage)
                InputField(label: L10n.frequency, unit: "Hz", text: $frequency)
            }
            Section(L10n.results) {
                bigResult(
                    label: "Reactive Power Needed",
                    value: String(format: "%.1f kVAR", result.reactivePowerNeeded)
                )
                resultRow(label: "Capacitance per Phase", value: String(format: "%.0f µF", result.capacitance))
            }
        }
        .navigationTitle(L10n.capacitorBank)
        .preferredColorScheme(.dark)
    }
}

struct TransformerSizingCalculator: View {
    @State private var totalLoad: String = "75"
    @State private var pf: String = "0.85"
    @State private var efficiency: String = "0.98"
    @State private var voltage: String = "400"
    
    var result: TransformerSizingResult {
        FormulaEngine.shared.transformerSizing(
            totalLoadKW: Double(totalLoad) ?? 0,
            powerFactor: Double(pf) ?? 0.85,
            efficiency: Double(efficiency) ?? 0.98,
            voltageV: Double(voltage) ?? 400
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: "Total Active Load", unit: "kW", text: $totalLoad)
                InputField(label: L10n.powerFactor, unit: "", text: $pf)
                InputField(label: "Transformer Efficiency", unit: "", text: $efficiency)
                InputField(label: "Secondary Voltage", unit: "V", text: $voltage)
            }
            Section("Sizing") {
                bigResult(
                    label: "Recommended Transformer",
                    value: result.recommended
                )
                resultRow(label: "Apparent Power", value: String(format: "%.1f kVA", result.apparentPower))
                resultRow(label: "Full Load Current", value: String(format: "%.1f A", result.fullLoadCurrent))
            }
        }
        .navigationTitle(L10n.transformerSizing)
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - New Pneumatics
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct PneumaticCylinderCalculator: View {
    @Environment(UnitManager.self) private var unitManager
    @State private var pressure: String = "6"
    @State private var bore: String = "50"
    @State private var rod: String = "20"
    
    var result: PneumaticCylinderResult {
        let pressVal = Double(pressure) ?? 0
        let boreVal = Double(bore) ?? 0
        let rodVal  = Double(rod) ?? 0
        
        let pressBar = unitManager.isMetric ? pressVal : unitManager.psiToBar(pressVal)
        let boreMM   = unitManager.isMetric ? boreVal  : unitManager.inchToMm(boreVal)
        let rodMM    = unitManager.isMetric ? rodVal   : unitManager.inchToMm(rodVal)
        
        let raw = FormulaEngine.shared.pneumaticCylinderForce(
            pressureBar: pressBar,
            boreDiameterMM: boreMM,
            rodDiameterMM: rodMM
        )
        
        if unitManager.isMetric {
            return raw
        } else {
            return PneumaticCylinderResult(
                pushForce: unitManager.newtonsToLbf(raw.pushForce),
                pullForce: unitManager.newtonsToLbf(raw.pullForce),
                unit: "lbf"
            )
        }
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.pressureParam, unit: unitManager.pressureUnit, text: $pressure)
                InputField(label: L10n.boreDiameter, unit: unitManager.lengthUnit, text: $bore)
                InputField(label: L10n.rodDiameter, unit: unitManager.lengthUnit, text: $rod)
            }
            Section(L10n.results) {
                resultRow(label: L10n.pushForce, value: String(format: "%.0f %@", result.pushForce, result.unit))
                resultRow(label: L10n.pullForce, value: String(format: "%.0f %@", result.pullForce, result.unit))
            }
        }
        .navigationTitle(L10n.pneumaticCylinder)
        .preferredColorScheme(.dark)
    }
}

struct ValveCvCalculator: View {
    @State private var flow: String = "10"
    @State private var pressureDrop: String = "5"
    @State private var sg: String = "1.0"
    
    var result: ValveCvResult {
        FormulaEngine.shared.valveCv(
            flowGPM: Double(flow) ?? 0,
            pressureDropPSI: Double(pressureDrop) ?? 0,
            specificGravity: Double(sg) ?? 1.0
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.inputs) {
                InputField(label: L10n.flowRate, unit: "GPM", text: $flow)
                InputField(label: L10n.pressureDropLabel, unit: "psi", text: $pressureDrop)
                InputField(label: "Specific Gravity", unit: "", text: $sg)
            }
            Section(L10n.results) {
                bigResult(
                    label: "Valve Flow Coefficient",
                    value: String(format: "Cv = %.2f", result.cv)
                )
            }
        }
        .navigationTitle(L10n.valveCv)
        .preferredColorScheme(.dark)
    }
}
