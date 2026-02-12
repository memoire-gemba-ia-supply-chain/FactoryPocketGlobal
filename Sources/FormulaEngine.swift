// ──────────────────────────────────────────────
// FormulaEngine.swift
// Factory Pocket Pro
//
// The mathematical brain of the application.
// Pure calculation layer — ZERO UI dependencies.
// All 25+ formulas organized into 6 engineering domains.
// ──────────────────────────────────────────────

import Foundation

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Result Types
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MARK: OEE

enum OEERating: String, CaseIterable {
    case worldClass = "World Class (≥ 85%)"
    case good       = "Good (65–85%)"
    case average    = "Average (40–65%)"
    case poor       = "Needs Improvement (< 40%)"

    var color: String {
        switch self {
        case .worldClass: return "green"
        case .good:       return "blue"
        case .average:    return "orange"
        case .poor:       return "red"
        }
    }
}

struct OEEResult {
    let availability: Double   // input %
    let performance: Double    // input %
    let quality: Double        // input %
    let oee: Double            // calculated %

    var rating: OEERating {
        switch oee {
        case 85...:      return .worldClass
        case 65..<85:    return .good
        case 40..<65:    return .average
        default:         return .poor
        }
    }
}

// MARK: Six Sigma

enum ProcessCapability: String {
    case excellent  = "Excellent (Cpk ≥ 1.67)"
    case capable    = "Capable (1.33 ≤ Cpk < 1.67)"
    case marginal   = "Marginal (1.0 ≤ Cpk < 1.33)"
    case incapable  = "Incapable (Cpk < 1.0)"
}

struct SixSigmaResult {
    let cp: Double
    let cpk: Double
    let sigmaLevel: Double
    let estimatedPPM: Double

    var capability: ProcessCapability {
        switch cpk {
        case 1.67...:     return .excellent
        case 1.33..<1.67: return .capable
        case 1.0..<1.33:  return .marginal
        default:          return .incapable
        }
    }
}

// MARK: EOQ

struct EOQResult {
    let optimalQuantity: Double
    let totalCost: Double
    let ordersPerYear: Double
    let orderingCostPerYear: Double
    let holdingCostPerYear: Double
}

// MARK: Hydraulics

struct CylinderForceResult {
    let pushForce: Double   // N (metric) or lbf (imperial)
    let pullForce: Double   // N (metric) or lbf (imperial)
}

struct HydraulicPowerResult {
    let power: Double
    let unit: String        // "kW" or "HP"
}

enum FlowRegime: String {
    case laminar      = "Laminar (Re < 2,000)"
    case transitional = "Transitional (2,000 – 4,000)"
    case turbulent    = "Turbulent (Re > 4,000)"
}

struct ReynoldsResult {
    let reynoldsNumber: Double
    let regime: FlowRegime
}

// MARK: Electrical

enum ConductorMaterial: String, CaseIterable, Identifiable {
    case copper   = "Copper"
    case aluminum = "Aluminum"

    var id: String { rawValue }

    /// Resistivity in Ω·mm²/m at 20 °C
    var resistivity: Double {
        switch self {
        case .copper:   return 0.017_241
        case .aluminum: return 0.028_264
        }
    }

    var symbol: String {
        switch self {
        case .copper:   return "Cu"
        case .aluminum: return "Al"
        }
    }
}

struct VoltageDropResult {
    let voltageDrop: Double          // V
    let voltageDropPercent: Double   // %
    let isAcceptable: Bool           // typically ≤ 3–5 %
}

struct MotorResult {
    let activePowerKW: Double     // P — kW
    let reactivePowerKVAR: Double // Q — kVAR
    let apparentPowerKVA: Double  // S — kVA
    let fullLoadAmps: Double      // I — A
}

// MARK: Pneumatics

struct AirLeakResult {
    let leakFlowRateLPM: Double          // Free-air L/min
    let compressorPowerWastedKW: Double  // kW
    let annualEnergyCost: Double         // Currency unit
}

struct PneumaticCylinderResult {
    let pushForce: Double   // N or lbf
    let pullForce: Double   // N or lbf
    let unit: String        // "N" or "lbf"
}

struct ValveCvResult {
    let cv: Double
    let flowRate: Double    // GPM or L/min
    let flowUnit: String
}

// MARK: Finance

struct NPVResult {
    let npv: Double
    let isPositive: Bool
    let discountedCashFlows: [Double]
}

struct WACCResult {
    let wacc: Double       // as percentage (e.g. 8.5)
    let equityWeight: Double
    let debtWeight: Double
}

struct DepreciationResult {
    let annualDepreciation: Double
    let schedule: [Double]  // book value at end of each year
}

struct LoanAmortizationResult {
    let monthlyPayment: Double
    let totalPayment: Double
    let totalInterest: Double
}

struct MarginMarkupResult {
    let margin: Double      // as percentage
    let markup: Double      // as percentage
    let profit: Double
}

// MARK: Electrical (extended)

struct CableSizingResult {
    let minCrossSection: Double  // mm²
    let actualDrop: Double       // %
    let recommended: String      // e.g. "6 mm²"
}

struct CapacitorBankResult {
    let reactivePowerNeeded: Double  // kVAR
    let capacitance: Double          // µF per phase
}

struct TransformerSizingResult {
    let apparentPower: Double   // kVA
    let fullLoadCurrent: Double // A
    let recommended: String     // e.g. "100 kVA"
}

struct FlowVelocityResult {
    let velocity: Double    // m/s
    let isAcceptable: Bool  // typical max 3–6 m/s for hydraulics
}

struct PipePressureLossResult {
    let pressureDrop: Double  // bar
    let frictionFactor: Double
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Formula Engine
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class FormulaEngine: Sendable {

    static let shared = FormulaEngine()
    private init() {}

    // ─────────────────────────────────────────
    // MARK: A · LEAN MANUFACTURING & QUALITY 🏭
    // ─────────────────────────────────────────

    /// **Takt Time** — pace of production to match demand.
    ///
    /// `Takt = Available Time (s) ÷ Customer Demand (units)`
    ///
    /// - Returns: Seconds per unit.
    func taktTime(
        availableTimeSeconds: Double,
        customerDemand: Double
    ) -> Double {
        guard customerDemand > 0 else { return 0 }
        return availableTimeSeconds / customerDemand
    }

    /// **OEE (Overall Equipment Effectiveness / TRS)**
    ///
    /// `OEE = Availability × Performance × Quality`
    ///
    /// All inputs and output in **percent** (0–100).
    func oee(
        availability: Double,
        performance: Double,
        quality: Double
    ) -> OEEResult {
        let value = (availability / 100.0)
                   * (performance / 100.0)
                   * (quality / 100.0) * 100.0
        return OEEResult(
            availability: availability,
            performance: performance,
            quality: quality,
            oee: value
        )
    }

    /// **Six Sigma Process Capability**
    ///
    /// - `Cp  = (USL − LSL) / (6σ)`
    /// - `Cpk = min((USL − μ) / 3σ, (μ − LSL) / 3σ)`
    /// - `Sigma Level ≈ Cpk × 3`
    func sixSigma(
        usl: Double,
        lsl: Double,
        mean: Double,
        sigma: Double
    ) -> SixSigmaResult {
        guard sigma > 0 else {
            return SixSigmaResult(cp: 0, cpk: 0, sigmaLevel: 0, estimatedPPM: 1_000_000)
        }

        let cp       = (usl - lsl) / (6.0 * sigma)
        let cpUpper  = (usl - mean) / (3.0 * sigma)
        let cpLower  = (mean - lsl) / (3.0 * sigma)
        let cpk      = min(cpUpper, cpLower)
        let sigmaLvl = cpk * 3.0
        let ppm      = Self.estimatePPM(sigmaLevel: sigmaLvl)

        return SixSigmaResult(
            cp: cp, cpk: cpk,
            sigmaLevel: sigmaLvl,
            estimatedPPM: ppm
        )
    }

    /// Approximate PPM from sigma level (with standard 1.5σ shift).
    private static func estimatePPM(sigmaLevel: Double) -> Double {
        // Standard lookup table values
        switch sigmaLevel {
        case 6...:    return 0.002
        case 5..<6:   return 3.4
        case 4..<5:   return 233
        case 3..<4:   return 6_210
        case 2..<3:   return 66_807
        case 1..<2:   return 308_537
        default:      return 690_000
        }
    }

    /// **Little's Law**: `WIP = Throughput × Lead Time`
    func littlesLawWIP(throughput: Double, leadTime: Double) -> Double {
        return throughput * leadTime
    }

    /// Inverse: Throughput = WIP / Lead Time
    func littlesLawThroughput(wip: Double, leadTime: Double) -> Double {
        guard leadTime > 0 else { return 0 }
        return wip / leadTime
    }

    /// Inverse: Lead Time = WIP / Throughput
    func littlesLawLeadTime(wip: Double, throughput: Double) -> Double {
        guard throughput > 0 else { return 0 }
        return wip / throughput
    }

    /// **EOQ — Wilson Formula** (Economic Order Quantity)
    ///
    /// `Q* = √(2 × D × S / H)`
    ///
    /// - D: Annual demand (units)
    /// - S: Ordering cost per order ($)
    /// - H: Holding cost per unit per year ($)
    func eoq(
        annualDemand: Double,
        orderingCost: Double,
        holdingCostPerUnit: Double
    ) -> EOQResult {
        guard holdingCostPerUnit > 0 else {
            return EOQResult(optimalQuantity: 0, totalCost: 0,
                             ordersPerYear: 0, orderingCostPerYear: 0,
                             holdingCostPerYear: 0)
        }

        let q = sqrt((2.0 * annualDemand * orderingCost) / holdingCostPerUnit)
        guard q > 0 else {
            return EOQResult(optimalQuantity: 0, totalCost: 0,
                             ordersPerYear: 0, orderingCostPerYear: 0,
                             holdingCostPerYear: 0)
        }

        let ordersPerYear        = annualDemand / q
        let orderingCostPerYear  = ordersPerYear * orderingCost
        let holdingCostPerYear   = (q / 2.0) * holdingCostPerUnit
        let totalCost            = orderingCostPerYear + holdingCostPerYear

        return EOQResult(
            optimalQuantity: q,
            totalCost: totalCost,
            ordersPerYear: ordersPerYear,
            orderingCostPerYear: orderingCostPerYear,
            holdingCostPerYear: holdingCostPerYear
        )
    }

    // ─────────────────────────────────────────
    // MARK: B · INJECTION MOLDING 🔩
    // ─────────────────────────────────────────

    /// **Clamping Force** (Metric)
    ///
    /// `F(kN) = (Area cm² × Pressure bar × SF) / 10`
    func clampingForceMetric(
        projectedAreaCm2: Double,
        cavityPressureBar: Double,
        safetyFactor: Double = 1.1
    ) -> Double {
        return projectedAreaCm2 * cavityPressureBar * safetyFactor / 10.0
    }

    /// **Clamping Force** (Imperial)
    ///
    /// `F(US Tons) = (Area in² × Pressure psi × SF) / 2000`
    func clampingForceImperial(
        projectedAreaIn2: Double,
        cavityPressurePSI: Double,
        safetyFactor: Double = 1.1
    ) -> Double {
        return projectedAreaIn2 * cavityPressurePSI * safetyFactor / 2000.0
    }

    /// **Cooling Time** (Theoretical)
    ///
    /// `t = (s² / (π² × α)) × ln((4/π) × ((T_melt − T_mold) / (T_eject − T_mold)))`
    ///
    /// - wallThicknessMM: Part wall thickness (mm)
    /// - thermalDiffusivity: Thermal diffusivity of the resin (mm²/s),
    ///   typical range 0.06–0.12 for thermoplastics
    /// - meltTemp / moldTemp / ejectTemp: Temperatures in °C
    func coolingTime(
        wallThicknessMM: Double,
        thermalDiffusivity: Double,
        meltTemp: Double,
        moldTemp: Double,
        ejectTemp: Double
    ) -> Double {
        guard thermalDiffusivity > 0,
              ejectTemp > moldTemp,
              meltTemp > moldTemp else { return 0 }

        let s = wallThicknessMM
        let ratio = (4.0 / Double.pi) * ((meltTemp - moldTemp) / (ejectTemp - moldTemp))
        guard ratio > 0 else { return 0 }

        return (s * s / (Double.pi * Double.pi * thermalDiffusivity)) * log(ratio)
    }

    /// **Shot Capacity** — barrel utilization percentage.
    ///
    /// `% = (Shot Weight / Max Barrel Capacity) × 100`
    ///
    /// Ideal range: 20–80 % for quality parts.
    func shotCapacity(
        shotWeightGrams: Double,
        maxBarrelCapacityGrams: Double
    ) -> Double {
        guard maxBarrelCapacityGrams > 0 else { return 0 }
        return (shotWeightGrams / maxBarrelCapacityGrams) * 100.0
    }

    /// **Residence Time**
    ///
    /// `t(s) = Barrel Inventory (g) / Throughput (g/s)`
    ///
    /// Where Throughput = Shot Weight / Cycle Time.
    func residenceTime(
        barrelInventoryGrams: Double,
        shotWeightGrams: Double,
        cycleTimeSeconds: Double
    ) -> Double {
        guard shotWeightGrams > 0, cycleTimeSeconds > 0 else { return 0 }
        let throughput = shotWeightGrams / cycleTimeSeconds
        return barrelInventoryGrams / throughput
    }

    // ─────────────────────────────────────────
    // MARK: C · HYDRAULICS 💧
    // ─────────────────────────────────────────

    /// **Cylinder Force** (Metric — bars & mm)
    ///
    /// - Push: `F = P(bar) × A_piston(mm²) / 10` → Newtons
    /// - Pull: `F = P(bar) × (A_piston − A_rod)(mm²) / 10` → Newtons
    func cylinderForceMetric(
        pressureBar: Double,
        pistonDiameterMM: Double,
        rodDiameterMM: Double
    ) -> CylinderForceResult {
        let aPiston = Double.pi / 4.0 * pistonDiameterMM * pistonDiameterMM
        let aRod    = Double.pi / 4.0 * rodDiameterMM * rodDiameterMM

        let push = pressureBar * aPiston / 10.0
        let pull = pressureBar * (aPiston - aRod) / 10.0

        return CylinderForceResult(pushForce: push, pullForce: pull)
    }

    /// **Cylinder Force** (Imperial — PSI & inches)
    ///
    /// - Push: `F = P(psi) × A_piston(in²)` → lbf
    /// - Pull: `F = P(psi) × (A_piston − A_rod)(in²)` → lbf
    func cylinderForceImperial(
        pressurePSI: Double,
        pistonDiameterInch: Double,
        rodDiameterInch: Double
    ) -> CylinderForceResult {
        let aPiston = Double.pi / 4.0 * pistonDiameterInch * pistonDiameterInch
        let aRod    = Double.pi / 4.0 * rodDiameterInch * rodDiameterInch

        let push = pressurePSI * aPiston
        let pull = pressurePSI * (aPiston - aRod)

        return CylinderForceResult(pushForce: push, pullForce: pull)
    }

    /// **Hydraulic Power** (Metric)
    ///
    /// `P(kW) = Q(L/min) × p(bar) / 600`
    func hydraulicPowerMetric(flowLPM: Double, pressureBar: Double) -> HydraulicPowerResult {
        let power = (flowLPM * pressureBar) / 600.0
        return HydraulicPowerResult(power: power, unit: "kW")
    }

    /// **Hydraulic Power** (Imperial)
    ///
    /// `P(HP) = Q(GPM) × p(PSI) / 1714`
    func hydraulicPowerImperial(flowGPM: Double, pressurePSI: Double) -> HydraulicPowerResult {
        let power = (flowGPM * pressurePSI) / 1714.0
        return HydraulicPowerResult(power: power, unit: "HP")
    }

    /// **Reynolds Number** — predicts laminar vs. turbulent flow.
    ///
    /// `Re = (V × D) / ν`
    ///
    /// - flowLPM: Volumetric flow in L/min
    /// - pipeDiameterMM: Pipe inner diameter in mm
    /// - kinematicViscosity: ν in m²/s (hydraulic oil 32 cSt = 32 × 10⁻⁶ m²/s)
    func reynoldsNumber(
        flowLPM: Double,
        pipeDiameterMM: Double,
        kinematicViscosity: Double
    ) -> ReynoldsResult {
        guard pipeDiameterMM > 0, kinematicViscosity > 0 else {
            return ReynoldsResult(reynoldsNumber: 0, regime: .laminar)
        }

        let d        = pipeDiameterMM / 1000.0          // → meters
        let area     = Double.pi / 4.0 * d * d          // m²
        let flowM3S  = flowLPM / 60_000.0               // L/min → m³/s
        let velocity = flowM3S / area                    // m/s
        let re       = (velocity * d) / kinematicViscosity

        let regime: FlowRegime
        switch re {
        case ..<2_000:        regime = .laminar
        case 2_000...4_000:   regime = .transitional
        default:              regime = .turbulent
        }

        return ReynoldsResult(reynoldsNumber: re, regime: regime)
    }

    /// **Heat Load** for oil-cooler sizing.
    ///
    /// `Q_heat = P_input × (1 − η_pump × η_system)`
    ///
    /// Returns heat in kW.
    func heatLoad(
        inputPowerKW: Double,
        pumpEfficiency: Double = 0.85,
        systemEfficiency: Double = 0.75
    ) -> Double {
        return inputPowerKW * (1.0 - pumpEfficiency * systemEfficiency)
    }

    /// **Flow Velocity** in a pipe.
    ///
    /// `v = Q / A` where `A = π/4 × d²`
    func flowVelocity(
        flowLPM: Double,
        pipeDiameterMM: Double
    ) -> FlowVelocityResult {
        guard pipeDiameterMM > 0 else {
            return FlowVelocityResult(velocity: 0, isAcceptable: true)
        }
        let d    = pipeDiameterMM / 1000.0
        let area = Double.pi / 4.0 * d * d
        let flowM3S = flowLPM / 60_000.0
        let v = flowM3S / area
        return FlowVelocityResult(velocity: v, isAcceptable: v <= 6.0)
    }

    /// **Pipe Pressure Loss** (Darcy-Weisbach, simplified for turbulent flow).
    ///
    /// `ΔP = f × (L/D) × (ρ × v² / 2)`
    ///
    /// Uses Moody friction factor approximation for turbulent flow in smooth pipes.
    func pipePressureLoss(
        flowLPM: Double,
        pipeDiameterMM: Double,
        pipeLengthM: Double,
        fluidDensity: Double = 870.0,  // kg/m³ typical hydraulic oil
        kinematicViscosity: Double = 32e-6  // m²/s
    ) -> PipePressureLossResult {
        guard pipeDiameterMM > 0, kinematicViscosity > 0 else {
            return PipePressureLossResult(pressureDrop: 0, frictionFactor: 0)
        }
        let d = pipeDiameterMM / 1000.0
        let area = Double.pi / 4.0 * d * d
        let flowM3S = flowLPM / 60_000.0
        let v = flowM3S / area
        let re = (v * d) / kinematicViscosity

        // Friction factor: Blasius for turbulent, 64/Re for laminar
        let f: Double
        if re < 2000 {
            f = re > 0 ? 64.0 / re : 0
        } else {
            f = 0.316 / pow(re, 0.25)  // Blasius correlation
        }

        let deltaP_Pa = f * (pipeLengthM / d) * (fluidDensity * v * v / 2.0)
        let deltaP_bar = deltaP_Pa / 100_000.0

        return PipePressureLossResult(pressureDrop: deltaP_bar, frictionFactor: f)
    }

    // ─────────────────────────────────────────
    // MARK: D · ELECTRICAL ⚡
    // ─────────────────────────────────────────

    /// **Voltage Drop**
    ///
    /// `ΔU = b × (ρ × L / S) × I × cos(φ)`
    ///
    /// - conductor: Copper (ρ = 0.0172) or Aluminum (ρ = 0.0283)
    /// - lengthMeters: One-way cable run length
    /// - crossSectionMM2: Conductor cross-section (mm²)
    /// - currentAmps: Load current
    /// - cosPhi: Power factor
    /// - supplyVoltage: Nominal supply voltage (for % calculation)
    /// - phaseCoefficient: `2` for single-phase, `√3 ≈ 1.732` for three-phase
    func voltageDrop(
        conductor: ConductorMaterial,
        lengthMeters: Double,
        crossSectionMM2: Double,
        currentAmps: Double,
        cosPhi: Double,
        supplyVoltage: Double,
        phaseCoefficient: Double = 2.0
    ) -> VoltageDropResult {
        guard crossSectionMM2 > 0, supplyVoltage > 0 else {
            return VoltageDropResult(voltageDrop: 0, voltageDropPercent: 0, isAcceptable: true)
        }

        let rho    = conductor.resistivity
        let deltaU = phaseCoefficient * (rho * lengthMeters / crossSectionMM2)
                     * currentAmps * cosPhi
        let pct    = (deltaU / supplyVoltage) * 100.0

        return VoltageDropResult(
            voltageDrop: deltaU,
            voltageDropPercent: pct,
            isAcceptable: pct <= 5.0
        )
    }

    /// **3-Phase Motor Calculator**
    ///
    /// Given mechanical power (kW), voltage, power-factor, and efficiency,
    /// computes P, Q, S, and full-load amps.
    ///
    /// - `S = P / (PF × η)`
    /// - `Q = S × sin(φ)`
    /// - `I = P(W) / (√3 × V × PF × η)`
    func motorCalculator(
        voltageV: Double,
        powerKW: Double,
        powerFactor: Double,
        efficiency: Double = 0.90
    ) -> MotorResult {
        guard voltageV > 0, powerFactor > 0, efficiency > 0 else {
            return MotorResult(activePowerKW: 0, reactivePowerKVAR: 0,
                               apparentPowerKVA: 0, fullLoadAmps: 0)
        }

        let P      = powerKW
        let S      = P / (powerFactor * efficiency)                       // kVA
        let sinPhi = sqrt(1.0 - powerFactor * powerFactor)
        let Q      = S * sinPhi                                           // kVAR
        let I      = (P * 1000.0) / (sqrt(3.0) * voltageV
                      * powerFactor * efficiency)                         // A

        return MotorResult(
            activePowerKW: P,
            reactivePowerKVAR: Q,
            apparentPowerKVA: S,
            fullLoadAmps: I
        )
    }

    /// **VFD Speed Calculator** — frequency to RPM.
    ///
    /// `RPM = (120 × f) / Poles`
    func vfdSpeed(frequencyHz: Double, numberOfPoles: Int) -> Double {
        guard numberOfPoles > 0 else { return 0 }
        return (120.0 * frequencyHz) / Double(numberOfPoles)
    }

    /// Inverse: required Hz for a target RPM.
    ///
    /// `f = (RPM × Poles) / 120`
    func vfdFrequency(targetRPM: Double, numberOfPoles: Int) -> Double {
        guard numberOfPoles > 0 else { return 0 }
        return (targetRPM * Double(numberOfPoles)) / 120.0
    }

    /// **Cable Sizing** (Metric)
    func cableSizing(
        conductor: ConductorMaterial,
        lengthMeters: Double,
        currentAmps: Double,
        supplyVoltage: Double,
        cosPhi: Double = 0.85,
        maxDropPercent: Double = 3.0
    ) -> CableSizingResult {
        let standardSections: [Double] = [1.5, 2.5, 4, 6, 10, 16, 25, 35, 50, 70, 95, 120, 150, 185, 240]
        let rho = conductor.resistivity

        for section in standardSections {
            let deltaU = 2.0 * (rho * lengthMeters / section) * currentAmps * cosPhi
            let pct = (deltaU / supplyVoltage) * 100.0
            if pct <= maxDropPercent {
                return CableSizingResult(
                    minCrossSection: section,
                    actualDrop: pct,
                    recommended: "\(Int(section)) mm²"
                )
            }
        }
        // Nothing fits
        let largest = standardSections.last!
        let deltaU = 2.0 * (rho * lengthMeters / largest) * currentAmps * cosPhi
        let pct = (deltaU / supplyVoltage) * 100.0
        return CableSizingResult(minCrossSection: largest, actualDrop: pct, recommended: "\(Int(largest)) mm² ⚠️")
    }
    
    /// **Cable Sizing** (Imperial - AWG)
    /// Checks standard AWG sizes: 14, 12, 10, 8, 6, 4, 2, 1, 0(1/0), 00(2/0), 000(3/0), 0000(4/0).
    /// Uses approximate cross-sections.
    func cableSizingAWG(
        conductor: ConductorMaterial,
        lengthMeters: Double,
        currentAmps: Double,
        supplyVoltage: Double,
        cosPhi: Double = 0.85,
        maxDropPercent: Double = 3.0
    ) -> CableSizingResult {
        // AWG to mm2 map (approx)
        let awgMap: [(String, Double)] = [
            ("14 AWG", 2.08), ("12 AWG", 3.31), ("10 AWG", 5.26),
            ("8 AWG", 8.37), ("6 AWG", 13.3), ("4 AWG", 21.2),
            ("2 AWG", 33.6), ("1 AWG", 42.4), ("1/0 AWG", 53.5),
            ("2/0 AWG", 67.4), ("3/0 AWG", 85.0), ("4/0 AWG", 107.0)
        ]
        
        let rho = conductor.resistivity // Ohm mm2/m
        
        // length is in meters (caller must convert feet -> meters)
        
        for (label, area) in awgMap {
            let deltaU = 2.0 * (rho * lengthMeters / area) * currentAmps * cosPhi
            let pct = (deltaU / supplyVoltage) * 100.0
            if pct <= maxDropPercent {
                return CableSizingResult(
                    minCrossSection: area,
                    actualDrop: pct,
                    recommended: label
                )
            }
        }
        
        // Largest check
        let (label, area) = awgMap.last!
        let deltaU = 2.0 * (rho * lengthMeters / area) * currentAmps * cosPhi
        let pct = (deltaU / supplyVoltage) * 100.0
        return CableSizingResult(minCrossSection: area, actualDrop: pct, recommended: "\(label) ⚠️")
    }

    /// **Capacitor Bank Sizing** (Power Factor Correction).
    ///
    /// `Qc = P × (tan φ₁ − tan φ₂)`
    func capacitorBank(
        activePowerKW: Double,
        currentPF: Double,
        targetPF: Double,
        voltageV: Double = 400,
        frequencyHz: Double = 50
    ) -> CapacitorBankResult {
        guard currentPF > 0, currentPF < 1, targetPF > currentPF else {
            return CapacitorBankResult(reactivePowerNeeded: 0, capacitance: 0)
        }
        let phi1 = acos(currentPF)
        let phi2 = acos(targetPF)
        let qc = activePowerKW * (tan(phi1) - tan(phi2))  // kVAR

        // C per phase = Qc × 10⁶ / (2π × f × V²)  → µF
        let cPerPhase = (qc * 1000.0 * 1e6) / (2.0 * Double.pi * frequencyHz * voltageV * voltageV / 3.0)

        return CapacitorBankResult(reactivePowerNeeded: qc, capacitance: cPerPhase)
    }

    /// **Transformer Sizing**
    ///
    /// `S(kVA) = P / (PF × η)`
    func transformerSizing(
        totalLoadKW: Double,
        powerFactor: Double = 0.85,
        efficiency: Double = 0.98,
        voltageV: Double = 400
    ) -> TransformerSizingResult {
        guard powerFactor > 0, efficiency > 0, voltageV > 0 else {
            return TransformerSizingResult(apparentPower: 0, fullLoadCurrent: 0, recommended: "—")
        }
        let sKVA = totalLoadKW / (powerFactor * efficiency)
        let fla = (sKVA * 1000.0) / (sqrt(3.0) * voltageV)

        // Standard transformer sizes
        let standards: [Double] = [25, 50, 75, 100, 150, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000]
        let recommended = standards.first(where: { $0 >= sKVA * 1.1 }) ?? standards.last!

        return TransformerSizingResult(
            apparentPower: sKVA,
            fullLoadCurrent: fla,
            recommended: "\(Int(recommended)) kVA"
        )
    }

    // ─────────────────────────────────────────
    // MARK: E · PNEUMATICS 💨
    // ─────────────────────────────────────────

    /// **Air Leak Cost Estimator**
    ///
    /// Approximates the free-air leak flow through an orifice, then
    /// derives the compressor power wasted and the annual energy cost.
    ///
    /// - holeDiameterMM: Equivalent leak hole diameter
    /// - linePressureBar: System gauge pressure
    /// - costPerKWh: Electricity price per kWh
    /// - annualHours: Operating hours per year
    /// - dischargeCoefficient: Orifice Cd (default 0.65)
    func airLeakCost(
        holeDiameterMM: Double,
        linePressureBar: Double,
        costPerKWh: Double,
        annualHours: Double,
        dischargeCoefficient: Double = 0.65
    ) -> AirLeakResult {
        let d        = holeDiameterMM / 1000.0                        // → m
        let area     = Double.pi / 4.0 * d * d                        // m²
        let pPa      = linePressureBar * 100_000.0                    // → Pa
        let rhoAir   = 1.225                                          // kg/m³
        let velocity = dischargeCoefficient * sqrt(2.0 * pPa / rhoAir) // m/s
        let flowM3S  = area * velocity                                 // m³/s
        let flowLPM  = flowM3S * 60_000.0                              // Free-air L/min

        // Industry rule-of-thumb: ~7 kW per 1000 L/min of free air
        let compressorKW  = (flowLPM / 1000.0) * 7.0
        let annualCost    = compressorKW * annualHours * costPerKWh

        return AirLeakResult(
            leakFlowRateLPM: flowLPM,
            compressorPowerWastedKW: compressorKW,
            annualEnergyCost: annualCost
        )
    }

    /// **Receiver Tank Sizing**
    ///
    /// Prevents short-cycling of the compressor.
    ///
    /// `V(L) = Q(L/s) × t(s) × P_atm / ΔP`
    ///
    /// - compressorOutputLPM: Compressor free-air delivery (L/min)
    /// - maxPressureBar / minPressureBar: Cut-in/cut-out pressures
    /// - allowableDropTimeSec: Desired coast-down time (s)
    /// - Returns: Tank volume in liters.
    func receiverTankSize(
        compressorOutputLPM: Double,
        maxPressureBar: Double,
        minPressureBar: Double,
        allowableDropTimeSec: Double = 30.0
    ) -> Double {
        let deltaP = maxPressureBar - minPressureBar
        guard deltaP > 0 else { return 0 }

        let pAtm    = 1.013_25                              // bar
        let flowLPS = compressorOutputLPM / 60.0            // L/s

        return (flowLPS * allowableDropTimeSec * pAtm) / deltaP
    }

    /// **Pneumatic Cylinder Force**
    ///
    /// - Push: `F = P × A_piston`
    /// - Pull: `F = P × (A_piston − A_rod)`
    func pneumaticCylinderForce(
        pressureBar: Double,
        boreDiameterMM: Double,
        rodDiameterMM: Double
    ) -> PneumaticCylinderResult {
        let aBore = Double.pi / 4.0 * boreDiameterMM * boreDiameterMM  // mm²
        let aRod  = Double.pi / 4.0 * rodDiameterMM * rodDiameterMM
        // 1 bar = 0.1 N/mm²
        let push = pressureBar * 0.1 * aBore   // N
        let pull = pressureBar * 0.1 * (aBore - aRod)
        return PneumaticCylinderResult(pushForce: push, pullForce: pull, unit: "N")
    }

    /// **Valve Flow Coefficient (Cv)**
    ///
    /// `Q = Cv × √(ΔP / SG)`  (GPM with ΔP in psi)
    func valveCv(
        flowGPM: Double,
        pressureDropPSI: Double,
        specificGravity: Double = 1.0
    ) -> ValveCvResult {
        guard pressureDropPSI > 0, specificGravity > 0 else {
            return ValveCvResult(cv: 0, flowRate: flowGPM, flowUnit: "GPM")
        }
        let cv = flowGPM / sqrt(pressureDropPSI / specificGravity)
        return ValveCvResult(cv: cv, flowRate: flowGPM, flowUnit: "GPM")
    }

    /// **Flow from Cv** — given a valve Cv, compute the max flow.
    func flowFromCv(
        cv: Double,
        pressureDropPSI: Double,
        specificGravity: Double = 1.0
    ) -> Double {
        guard pressureDropPSI > 0, specificGravity > 0 else { return 0 }
        return cv * sqrt(pressureDropPSI / specificGravity)
    }

    // ─────────────────────────────────────────
    // MARK: F · FINANCE 💰
    // ─────────────────────────────────────────

    /// **ROI** — Return on Investment.
    ///
    /// `ROI(%) = (Net Profit / Investment) × 100`
    func roi(netProfit: Double, investment: Double) -> Double {
        guard investment != 0 else { return 0 }
        return (netProfit / investment) * 100.0
    }

    /// **Payback Period** (simple).
    ///
    /// `Payback (years) = Investment / Annual Cash Flow`
    func paybackPeriod(investment: Double, annualCashFlow: Double) -> Double {
        guard annualCashFlow > 0 else { return .infinity }
        return investment / annualCashFlow
    }

    /// **NPV** — Net Present Value.
    ///
    /// `NPV = −I₀ + Σ (CF_t / (1 + r)^t)`
    ///
    /// - discountRate: Expressed as decimal (e.g. 0.10 for 10 %).
    func npv(
        initialInvestment: Double,
        cashFlows: [Double],
        discountRate: Double
    ) -> NPVResult {
        var npvValue = -initialInvestment
        var discounted: [Double] = []

        for (i, cf) in cashFlows.enumerated() {
            let t  = Double(i + 1)
            let pv = cf / pow(1.0 + discountRate, t)
            discounted.append(pv)
            npvValue += pv
        }

        return NPVResult(
            npv: npvValue,
            isPositive: npvValue > 0,
            discountedCashFlows: discounted
        )
    }

    /// **WACC** — Weighted Average Cost of Capital.
    ///
    /// `WACC = (E/V × Rₑ) + (D/V × R_d × (1 − Tc))`
    ///
    /// All rates (costOfEquity, costOfDebt, taxRate) as decimals.
    func wacc(
        equityValue: Double,
        debtValue: Double,
        costOfEquity: Double,
        costOfDebt: Double,
        taxRate: Double
    ) -> WACCResult {
        let V = equityValue + debtValue
        guard V > 0 else {
            return WACCResult(wacc: 0, equityWeight: 0, debtWeight: 0)
        }

        let wE   = equityValue / V
        let wD   = debtValue / V
        let wacc = (wE * costOfEquity) + (wD * costOfDebt * (1.0 - taxRate))

        return WACCResult(wacc: wacc * 100.0, equityWeight: wE, debtWeight: wD)
    }

    /// **Break-Even Quantity**
    ///
    /// `BEP = Fixed Costs / (Price − Variable Cost)`
    func breakEvenQuantity(
        fixedCosts: Double,
        sellingPricePerUnit: Double,
        variableCostPerUnit: Double
    ) -> Double {
        let margin = sellingPricePerUnit - variableCostPerUnit
        guard margin > 0 else { return .infinity }
        return fixedCosts / margin
    }

    /// **Break-Even Revenue**
    ///
    /// `BEP($) = Fixed Costs / Contribution Margin Ratio`
    func breakEvenRevenue(
        fixedCosts: Double,
        contributionMarginRatio: Double
    ) -> Double {
        guard contributionMarginRatio > 0 else { return .infinity }
        return fixedCosts / contributionMarginRatio
    }

    /// **IRR** — Internal Rate of Return (Newton-Raphson).
    ///
    /// Finds the rate `r` where `NPV(r) = 0`.
    func irr(
        initialInvestment: Double,
        cashFlows: [Double],
        maxIterations: Int = 100,
        tolerance: Double = 1e-7
    ) -> Double {
        var guess = 0.10  // start at 10%

        for _ in 0..<maxIterations {
            var npv = -initialInvestment
            var dNPV = 0.0  // derivative

            for (i, cf) in cashFlows.enumerated() {
                let t = Double(i + 1)
                let denom = pow(1.0 + guess, t)
                npv  += cf / denom
                dNPV -= t * cf / pow(1.0 + guess, t + 1)
            }

            guard abs(dNPV) > 1e-12 else { break }
            let newGuess = guess - npv / dNPV
            if abs(newGuess - guess) < tolerance { return newGuess * 100.0 }
            guess = newGuess
        }
        return guess * 100.0  // return as percentage
    }

    /// **Straight-Line Depreciation**
    ///
    /// `Annual = (Cost − Salvage) / Life`
    func straightLineDepreciation(
        cost: Double,
        salvageValue: Double,
        usefulLife: Int
    ) -> DepreciationResult {
        guard usefulLife > 0 else {
            return DepreciationResult(annualDepreciation: 0, schedule: [])
        }
        let annual = (cost - salvageValue) / Double(usefulLife)
        var schedule: [Double] = []
        var book = cost
        for _ in 1...usefulLife {
            book -= annual
            schedule.append(max(book, salvageValue))
        }
        return DepreciationResult(annualDepreciation: annual, schedule: schedule)
    }

    /// **Double Declining Balance Depreciation**
    ///
    /// `Annual = Book Value × (2 / Life)`
    func doubleDecliningDepreciation(
        cost: Double,
        salvageValue: Double,
        usefulLife: Int
    ) -> DepreciationResult {
        guard usefulLife > 0 else {
            return DepreciationResult(annualDepreciation: 0, schedule: [])
        }
        let rate = 2.0 / Double(usefulLife)
        var schedule: [Double] = []
        var book = cost
        var firstYear = 0.0
        for i in 1...usefulLife {
            let dep = max(min(book * rate, book - salvageValue), 0)
            book -= dep
            schedule.append(book)
            if i == 1 { firstYear = dep }
        }
        return DepreciationResult(annualDepreciation: firstYear, schedule: schedule)
    }

    /// **Margin vs Markup**
    func marginMarkup(
        sellingPrice: Double,
        costPrice: Double
    ) -> MarginMarkupResult {
        let profit = sellingPrice - costPrice
        let margin = sellingPrice > 0 ? (profit / sellingPrice) * 100.0 : 0
        let markup = costPrice > 0 ? (profit / costPrice) * 100.0 : 0
        return MarginMarkupResult(margin: margin, markup: markup, profit: profit)
    }

    /// **Loan Amortization** (fixed-rate monthly payment).
    ///
    /// `PMT = P × [r(1+r)^n] / [(1+r)^n − 1]`
    func loanAmortization(
        principal: Double,
        annualRate: Double,   // as percentage e.g. 5.0
        termMonths: Int
    ) -> LoanAmortizationResult {
        guard termMonths > 0, annualRate >= 0 else {
            return LoanAmortizationResult(monthlyPayment: 0, totalPayment: 0, totalInterest: 0)
        }
        if annualRate == 0 {
            let pmt = principal / Double(termMonths)
            return LoanAmortizationResult(monthlyPayment: pmt, totalPayment: principal, totalInterest: 0)
        }
        let r = (annualRate / 100.0) / 12.0
        let n = Double(termMonths)
        let factor = pow(1.0 + r, n)
        let pmt = principal * (r * factor) / (factor - 1.0)
        let total = pmt * n
        return LoanAmortizationResult(monthlyPayment: pmt, totalPayment: total, totalInterest: total - principal)
    }
    
    // ─────────────────────────────────────────
    // MARK: G · GENERAL UTILITY 🛠️
    // ─────────────────────────────────────────
    
    /// **Part Weight Calculator**
    ///
    /// `W(g) = Volume(cm³) × Density(g/cm³)`
    func partWeight(volumeCm3: Double, density: Double) -> Double {
        return volumeCm3 * density
    }
    
    /// **Scrap Rate Calculator**
    ///
    /// `Scrap Rate(%) = (Scrap Parts / Total Parts Produced) × 100`
    func scrapRate(totalParts: Double, scrapParts: Double) -> Double {
        guard totalParts > 0 else { return 0 }
        return (scrapParts / totalParts) * 100.0
    }
    
    /// **Machine Utilization**
    ///
    /// `Utilization(%) = (Actual Run Time / Total Available Time) × 100`
    func machineUtilization(runTime: Double, totalTime: Double) -> Double {
        guard totalTime > 0 else { return 0 }
        return (runTime / totalTime) * 100.0
    }

    // ─────────────────────────────────────────
    // MARK: H · SUPPLY CHAIN & LOGISTICS 📦
    // ─────────────────────────────────────────

    /// **Inventory Turnover Ratio**
    ///
    /// `Turnover = Cost of Goods Sold / Average Inventory`
    func inventoryTurnover(cogs: Double, avgInventory: Double) -> Double {
        guard avgInventory > 0 else { return 0 }
        return cogs / avgInventory
    }

    /// **Days Sales of Inventory (DSI)**
    ///
    /// `DSI = (Average Inventory / COGS) × 365`
    func daysSalesInventory(avgInventory: Double, cogs: Double) -> Double {
        guard cogs > 0 else { return 0 }
        return (avgInventory / cogs) * 365.0
    }

    /// **Safety Stock**
    ///
    /// `Safety Stock = (Max Daily Usage × Max Lead Time) - (Avg Daily Usage × Avg Lead Time)`
    func safetyStock(
        maxDailyUsage: Double,
        maxLeadTime: Double,
        avgDailyUsage: Double,
        avgLeadTime: Double
    ) -> Double {
        return (maxDailyUsage * maxLeadTime) - (avgDailyUsage * avgLeadTime)
    }

    /// **Reorder Point (ROP)**
    ///
    /// `ROP = (Avg Daily Usage × Avg Lead Time) + Safety Stock`
    func reorderPoint(
        avgDailyUsage: Double,
        avgLeadTime: Double,
        safetyStock: Double
    ) -> Double {
        return (avgDailyUsage * avgLeadTime) + safetyStock
    }

    /// **Order Fill Rate**
    ///
    /// `Fill Rate (%) = (Orders Shipped / Orders Placed) × 100`
    func orderFillRate(shipped: Double, placed: Double) -> Double {
        guard placed > 0 else { return 0 }
        return (shipped / placed) * 100.0
    }

    /// **On-Time Delivery (OTD)**
    ///
    /// `OTD (%) = (On-Time Orders / Total Orders) × 100`
    func onTimeDelivery(onTime: Double, total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (onTime / total) * 100.0
    }
    
    /// **Freight Cost Per Unit**
    ///
    /// `Cost/Unit = Total Freight Cost / Total Units Shipped`
    func freightCostPerUnit(totalCost: Double, units: Double) -> Double {
        guard units > 0 else { return 0 }
        return totalCost / units
    }
}
