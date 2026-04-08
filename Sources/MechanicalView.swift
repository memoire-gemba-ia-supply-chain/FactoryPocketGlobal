// ──────────────────────────────────────────────
// MechanicalView.swift
// Factory Pocket Pro
//
// 6 premium mechanical engineering calculators
// with gradient results & polished UI.
// ──────────────────────────────────────────────

import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Bolt Torque Calculator 🔩
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BoltTorqueCalculator: View {
    @State private var boltDiam: String = "10"
    @State private var clampForce: String = "25"
    @State private var conditionIndex: Int = 0
    
    let conditions: [(String, Double)] = [
        ("Dry Steel (K=0.20)", 0.20),
        ("Lubricated (K=0.15)", 0.15),
        ("MoS₂ / Wax (K=0.12)", 0.12),
    ]
    
    var result: BoltTorqueResult {
        FormulaEngine.shared.boltTorque(
            boltDiameterMM: Double(boltDiam) ?? 0,
            clampForceKN: Double(clampForce) ?? 0,
            kFactor: conditions[conditionIndex].1
        )
    }
    
    var stress: (stressMPa: Double, stressAreaMm2: Double) {
        FormulaEngine.shared.boltStress(
            clampForceKN: Double(clampForce) ?? 0,
            boltDiameterMM: Double(boltDiam) ?? 0
        )
    }
    
    var body: some View {
        Form {
            Section("Bolt Parameters") {
                MechInput(label: "Bolt Diameter", unit: "mm", text: $boltDiam)
                MechInput(label: "Required Clamp Force", unit: "kN", text: $clampForce)
            }
            Section("Surface Condition") {
                Picker("Condition", selection: $conditionIndex) {
                    ForEach(0..<conditions.count, id: \.self) { i in
                        Text(conditions[i].0).tag(i)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Results") {
                mechHeroResult(
                    icon: "wrench.and.screwdriver.fill",
                    label: L10n.isFrench ? "Couple de Serrage" : "Tightening Torque",
                    value: String(format: "%.1f", result.torque),
                    unit: "N·m",
                    gradient: [.orange, .red]
                )
                mechDetailRow(label: "Bolt Stress", value: String(format: "%.0f MPa", stress.stressMPa), icon: "bolt.fill")
                mechDetailRow(label: "Stress Area", value: String(format: "%.1f mm²", stress.stressAreaMm2), icon: "circle.dashed")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.08))
        .navigationTitle(L10n.isFrench ? "Couple de Serrage" : "Bolt Torque")
        .calculatorToolbar(id: "bolt_torque", name: "Bolt Torque", category: "Mechanical", icon: "wrench.fill", colorName: "red", unitSystem: "Metric", inputs: {
            ["Bolt Diameter": boltDiam, "Clamp Force": clampForce, "Condition": conditions[conditionIndex].0]
        }, results: {
            ["Torque": String(format: "%.1f N·m", result.torque), "Stress": String(format: "%.0f MPa", stress.stressMPa)]
        })
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Beam Stress Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BeamStressCalculator: View {
    @State private var force: String = "5000"
    @State private var span: String = "1000"
    @State private var width: String = "50"
    @State private var height: String = "100"
    
    var result: BeamStressResult {
        FormulaEngine.shared.beamBendingStress(
            forceN: Double(force) ?? 0,
            spanMM: Double(span) ?? 0,
            widthMM: Double(width) ?? 0,
            heightMM: Double(height) ?? 0
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.isFrench ? "Chargement" : "Loading") {
                MechInput(label: L10n.isFrench ? "Force Appliquée" : "Applied Force", unit: "N", text: $force)
                MechInput(label: L10n.isFrench ? "Portée" : "Span Length", unit: "mm", text: $span)
            }
            Section(L10n.isFrench ? "Section Rectangulaire" : "Rectangular Cross-Section") {
                MechInput(label: L10n.isFrench ? "Largeur (b)" : "Width (b)", unit: "mm", text: $width)
                MechInput(label: L10n.isFrench ? "Hauteur (h)" : "Height (h)", unit: "mm", text: $height)
            }
            Section("Results") {
                mechHeroResult(
                    icon: "arrow.down.to.line.compact",
                    label: L10n.isFrench ? "Contrainte Max" : "Max Bending Stress",
                    value: String(format: "%.1f", result.maxStressMPa),
                    unit: "MPa",
                    gradient: result.maxStressMPa > 235 ? [.red, .pink] : [.green, .mint]
                )
                mechDetailRow(label: L10n.isFrench ? "Flèche Max" : "Max Deflection", value: String(format: "%.3f mm", result.maxDeflectionMM), icon: "arrow.down")
                mechDetailRow(label: "Moment (M)", value: String(format: "%.0f N·mm", result.bendingMomentNmm), icon: "arrow.triangle.turn.up.right.circle")
                mechDetailRow(label: "I (Inertia)", value: String(format: "%.0f mm⁴", result.momentOfInertiaMM4), icon: "square.dashed")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.08))
        .navigationTitle(L10n.isFrench ? "Résistance Poutre" : "Beam Stress")
        .calculatorToolbar(id: "beam_stress", name: "Beam Stress", category: "Mechanical", icon: "rectangle.split.3x1", colorName: "red", unitSystem: "Metric", inputs: {
            ["Force": force, "Span": span, "Width": width, "Height": height]
        }, results: {
            ["Max Stress": String(format: "%.1f MPa", result.maxStressMPa), "Deflection": String(format: "%.3f mm", result.maxDeflectionMM)]
        })
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Weld Strength Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct WeldStrengthCalculator: View {
    @State private var throat: String = "5"
    @State private var length: String = "100"
    @State private var ultimate: String = "430"
    @State private var steelGrade: Int = 0
    
    let grades: [(String, Double)] = [
        ("S235 (βw=0.80)", 0.80),
        ("S275 (βw=0.85)", 0.85),
        ("S355 (βw=0.90)", 0.90),
    ]
    
    var result: WeldStrengthResult {
        FormulaEngine.shared.filletWeldStrength(
            throatMM: Double(throat) ?? 0,
            lengthMM: Double(length) ?? 0,
            ultimateMPa: Double(ultimate) ?? 430,
            betaW: grades[steelGrade].1
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.isFrench ? "Géométrie du Cordon" : "Weld Geometry") {
                MechInput(label: L10n.isFrench ? "Gorge (a)" : "Throat (a)", unit: "mm", text: $throat)
                MechInput(label: L10n.isFrench ? "Longueur (L)" : "Length (L)", unit: "mm", text: $length)
            }
            Section(L10n.isFrench ? "Matériau" : "Material") {
                MechInput(label: "fu (UTS)", unit: "MPa", text: $ultimate)
                Picker(L10n.isFrench ? "Nuance Acier" : "Steel Grade", selection: $steelGrade) {
                    ForEach(0..<grades.count, id: \.self) { i in
                        Text(grades[i].0).tag(i)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Results") {
                mechHeroResult(
                    icon: "flame.fill",
                    label: L10n.isFrench ? "Résistance de Calcul" : "Design Resistance",
                    value: String(format: "%.1f", result.designResistanceKN),
                    unit: "kN",
                    gradient: [.orange, .red]
                )
                mechDetailRow(label: L10n.isFrench ? "Contrainte Cisaillement" : "Shear Stress", value: String(format: "%.0f MPa", result.shearStressMPa), icon: "arrow.left.and.right")
                mechDetailRow(label: L10n.isFrench ? "Surface Cordon" : "Weld Area", value: String(format: "%.0f mm²", result.weldAreaMM2), icon: "rectangle.fill")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.08))
        .navigationTitle(L10n.isFrench ? "Soudure" : "Weld Strength")
        .calculatorToolbar(id: "weld_strength", name: "Weld Strength", category: "Mechanical", icon: "flame.fill", colorName: "red", unitSystem: "Metric", inputs: {
            ["Throat": throat, "Length": length, "UTS": ultimate]
        }, results: {
            ["Resistance": String(format: "%.1f kN", result.designResistanceKN)]
        })
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Gear Transmission Calculator ⚙️
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct GearTransmissionCalculator: View {
    @State private var z1: String = "20"
    @State private var z2: String = "60"
    @State private var speed: String = "1500"
    @State private var torque: String = "10"
    @State private var eff: String = "97"
    
    var result: GearTransmissionResult {
        FormulaEngine.shared.gearTransmission(
            teethDriver: Int(z1) ?? 20,
            teethDriven: Int(z2) ?? 60,
            inputSpeedRPM: Double(speed) ?? 0,
            inputTorqueNm: Double(torque) ?? 0,
            efficiency: (Double(eff) ?? 97) / 100.0
        )
    }
    
    var body: some View {
        Form {
            Section(L10n.isFrench ? "Pignon Menant (Entrée)" : "Driver Gear (Input)") {
                MechInput(label: L10n.isFrench ? "Dents Z₁" : "Teeth Z₁", unit: "", text: $z1)
                MechInput(label: L10n.isFrench ? "Vitesse Entrée" : "Input Speed", unit: "RPM", text: $speed)
                MechInput(label: L10n.isFrench ? "Couple Entrée" : "Input Torque", unit: "N·m", text: $torque)
            }
            Section(L10n.isFrench ? "Roue Menée (Sortie)" : "Driven Gear (Output)") {
                MechInput(label: L10n.isFrench ? "Dents Z₂" : "Teeth Z₂", unit: "", text: $z2)
                MechInput(label: L10n.isFrench ? "Rendement" : "Efficiency", unit: "%", text: $eff)
            }
            Section("Results") {
                mechHeroResult(
                    icon: "gearshape.2.fill",
                    label: L10n.isFrench ? "Rapport de Transmission" : "Gear Ratio",
                    value: String(format: "%.2f : 1", result.ratio),
                    unit: "",
                    gradient: [.purple, .blue]
                )
                mechDetailRow(label: L10n.isFrench ? "Vitesse Sortie" : "Output Speed", value: String(format: "%.0f RPM", result.outputSpeedRPM), icon: "arrow.clockwise")
                mechDetailRow(label: L10n.isFrench ? "Couple Sortie" : "Output Torque", value: String(format: "%.1f N·m", result.outputTorqueNm), icon: "arrow.triangle.2.circlepath")
                mechDetailRow(label: L10n.isFrench ? "Puissance" : "Power", value: String(format: "%.2f kW", result.outputPowerKW), icon: "bolt.fill")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.08))
        .navigationTitle(L10n.isFrench ? "Transmission" : "Gear Transmission")
        .calculatorToolbar(id: "gear_transmission", name: "Gear Transmission", category: "Mechanical", icon: "gearshape.2.fill", colorName: "red", unitSystem: "Metric", inputs: {
            ["Z1": z1, "Z2": z2, "Speed": speed, "Torque": torque]
        }, results: {
            ["Ratio": String(format: "%.2f", result.ratio), "Output Speed": String(format: "%.0f RPM", result.outputSpeedRPM)]
        })
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Bearing Life L₁₀ Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct BearingLifeCalculator: View {
    @State private var loadRating: String = "50"
    @State private var eqLoad: String = "10"
    @State private var speed: String = "1500"
    @State private var typeIndex: Int = 0
    
    let bearingTypes: [(String, Double)] = [
        ("Ball Bearing (p=3)", 3.0),
        ("Roller Bearing (p=10/3)", 10.0/3.0),
    ]
    
    var result: BearingLifeResult {
        FormulaEngine.shared.bearingLifeL10(
            dynamicLoadRatingKN: Double(loadRating) ?? 0,
            equivalentLoadKN: Double(eqLoad) ?? 0,
            exponent: bearingTypes[typeIndex].1,
            speedRPM: Double(speed) ?? 0
        )
    }
    
    private var lifeColor: [Color] {
        if result.lifeHours > 20_000 { return [.green, .mint] }
        if result.lifeHours > 5_000 { return [.orange, .yellow] }
        return [.red, .pink]
    }
    
    var body: some View {
        Form {
            Section(L10n.isFrench ? "Données Roulement" : "Bearing Data") {
                MechInput(label: L10n.isFrench ? "Charge Dynamique (C)" : "Dynamic Load (C)", unit: "kN", text: $loadRating)
                MechInput(label: L10n.isFrench ? "Charge Équivalente (P)" : "Equiv. Load (P)", unit: "kN", text: $eqLoad)
                MechInput(label: L10n.isFrench ? "Vitesse Rotation" : "Shaft Speed", unit: "RPM", text: $speed)
            }
            Section(L10n.isFrench ? "Type de Roulement" : "Bearing Type") {
                Picker("Type", selection: $typeIndex) {
                    ForEach(0..<bearingTypes.count, id: \.self) { i in
                        Text(bearingTypes[i].0).tag(i)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("L₁₀ Life") {
                mechHeroResult(
                    icon: "clock.fill",
                    label: L10n.isFrench ? "Durée de Vie L₁₀" : "Basic Rating Life L₁₀",
                    value: String(format: "%.0f", result.lifeHours),
                    unit: "hours",
                    gradient: lifeColor
                )
                mechDetailRow(label: L10n.isFrench ? "En Années (~24/7)" : "Years (~24/7)", value: String(format: "%.1f yrs", result.lifeYears), icon: "calendar")
                mechDetailRow(label: "Revolutions", value: String(format: "%.0f M rev", result.lifeRevolutions / 1_000_000.0), icon: "arrow.clockwise")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.08))
        .navigationTitle(L10n.isFrench ? "Roulements L₁₀" : "Bearing Life L₁₀")
        .calculatorToolbar(id: "bearing_life", name: "Bearing Life", category: "Mechanical", icon: "circle.dotted.circle", colorName: "red", unitSystem: "Metric", inputs: {
            ["C": loadRating, "P": eqLoad, "Speed": speed]
        }, results: {
            ["Life": String(format: "%.0f h", result.lifeHours)]
        })
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Spring Rate Calculator 🔧
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct SpringRateCalculator: View {
    @State private var wireDiam: String = "2.0"
    @State private var meanCoilDiam: String = "15"
    @State private var activeCoils: String = "8"
    @State private var materialIndex: Int = 0
    
    let materials: [(String, Double)] = [
        ("Spring Steel (G=79.3 GPa)", 79_300.0),
        ("Stainless 302 (G=69 GPa)", 69_000.0),
        ("Phosphor Bronze (G=41.4 GPa)", 41_400.0),
    ]
    
    var result: SpringRateResult {
        FormulaEngine.shared.springRate(
            wireDiameterMM: Double(wireDiam) ?? 0,
            meanCoilDiameterMM: Double(meanCoilDiam) ?? 0,
            activeCoils: Double(activeCoils) ?? 0,
            shearModulusMPa: materials[materialIndex].1
        )
    }
    
    private var indexOK: Bool { result.springIndex >= 4 && result.springIndex <= 12 }
    
    var body: some View {
        Form {
            Section(L10n.isFrench ? "Géométrie du Ressort" : "Spring Geometry") {
                MechInput(label: L10n.isFrench ? "Diamètre Fil (d)" : "Wire Diameter (d)", unit: "mm", text: $wireDiam)
                MechInput(label: L10n.isFrench ? "Diamètre Moyen (D)" : "Mean Coil Ø (D)", unit: "mm", text: $meanCoilDiam)
                MechInput(label: L10n.isFrench ? "Spires Actives" : "Active Coils", unit: "", text: $activeCoils)
            }
            Section(L10n.isFrench ? "Matériau" : "Material") {
                Picker("", selection: $materialIndex) {
                    ForEach(0..<materials.count, id: \.self) { i in
                        Text(materials[i].0).tag(i)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Results") {
                mechHeroResult(
                    icon: "arrow.up.and.down.and.sparkles",
                    label: L10n.isFrench ? "Raideur du Ressort" : "Spring Rate (k)",
                    value: String(format: "%.2f", result.rateNperMM),
                    unit: "N/mm",
                    gradient: [.cyan, .blue]
                )
                
                // Spring Index with status badge
                HStack(spacing: 12) {
                    Image(systemName: "circle.grid.cross.fill")
                        .foregroundColor(indexOK ? .green : .red)
                        .frame(width: 24)
                    Text("Spring Index (C = D/d)")
                        .font(.subheadline)
                    Spacer()
                    HStack(spacing: 6) {
                        Text(String(format: "%.1f", result.springIndex))
                            .fontWeight(.black)
                            .foregroundColor(indexOK ? .green : .red)
                        Text(indexOK ? "✅" : "⚠️")
                            .font(.caption)
                    }
                }
                
                if !indexOK {
                    Text(L10n.isFrench ? "⚠️ L'index doit être entre 4 et 12" : "⚠️ Index should be between 4 and 12")
                        .font(.caption2).foregroundColor(.red.opacity(0.8))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(white: 0.08))
        .navigationTitle(L10n.isFrench ? "Ressorts" : "Spring Rate")
        .calculatorToolbar(id: "spring_rate", name: "Spring Rate", category: "Mechanical", icon: "arrow.up.and.down.and.sparkles", colorName: "red", unitSystem: "Metric", inputs: {
            ["Wire d": wireDiam, "Mean D": meanCoilDiam, "Coils": activeCoils]
        }, results: {
            ["Rate": String(format: "%.2f N/mm", result.rateNperMM), "Index": String(format: "%.1f", result.springIndex)]
        })
        .preferredColorScheme(.dark)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Premium Shared Helpers
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Styled input row with icon
private struct MechInput: View {
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
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color(white: 0.12))
                    .cornerRadius(8)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption).fontWeight(.medium)
                        .foregroundColor(.gray)
                        .frame(width: 40, alignment: .leading)
                }
            }
        }
    }
}

/// Premium hero result with gradient value and icon
private func mechHeroResult(icon: String, label: String, value: String, unit: String, gradient: [Color]) -> some View {
    VStack(spacing: 8) {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(colors: gradient.map { $0.opacity(0.15) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 48, height: 48)
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing))
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(gradient.first?.opacity(0.7) ?? .orange)
            }
        }
        
        Text(label)
            .font(.caption).foregroundColor(.gray)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
}

/// Detail row with icon
private func mechDetailRow(label: String, value: String, icon: String) -> some View {
    HStack(spacing: 10) {
        Image(systemName: icon)
            .font(.caption)
            .foregroundColor(.orange.opacity(0.6))
            .frame(width: 20)
        Text(label)
            .font(.subheadline)
        Spacer()
        Text(value)
            .font(.subheadline).fontWeight(.bold)
            .foregroundColor(.orange)
    }
}


// MARK: - Main Mechanical View

struct MechanicalView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                List {
                    Section {
                        NavigationLink {
                            BoltTorqueCalculator()
                        } label: {
                            Label("Bolt Torque", systemImage: "wrench.fill")
                        }
                        NavigationLink {
                            BeamStressCalculator()
                        } label: {
                            Label("Beam Stress", systemImage: "rectangle.3.group")
                        }
                        NavigationLink {
                            WeldStrengthCalculator()
                        } label: {
                            Label("Weld Strength", systemImage: "flame.fill")
                        }
                        NavigationLink {
                            GearTransmissionCalculator()
                        } label: {
                            Label("Gear Transmission", systemImage: "gearshape.2.fill")
                        }
                        NavigationLink {
                            BearingLifeCalculator()
                        } label: {
                            Label("Bearing Life L₁₀", systemImage: "circle.dotted")
                        }
                        NavigationLink {
                            SpringRateCalculator()
                        } label: {
                            Label("Spring Rate", systemImage: "arrow.up.arrow.down")
                        }
                    } header: {
                        Text("Mechanical Engineering")
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Mechanical ⚙️")
        }
    }
}
