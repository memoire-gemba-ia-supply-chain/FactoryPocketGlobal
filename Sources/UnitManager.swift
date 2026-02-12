// ──────────────────────────────────────────────
// UnitManager.swift
// Factory Pocket Pro
//
// Global unit system singleton. Toggle between
// METRIC (mm, bar, °C, kW) and IMPERIAL (inch, psi, °F, HP).
// ──────────────────────────────────────────────

import Foundation
import SwiftUI

// MARK: - Unit System Enum

enum UnitSystem: String, CaseIterable, Codable {
    case metric   = "Metric"
    case imperial = "Imperial"

    var flag: String {
        switch self {
        case .metric:   return "🌍"
        case .imperial: return "🇺🇸"
        }
    }
}

// MARK: - UnitManager

@MainActor
@Observable
final class UnitManager {

    static let shared = UnitManager()

    // ── Persisted Selection ──────────────────────
    var unitSystem: UnitSystem = .metric {
        didSet {
            UserDefaults.standard.set(unitSystem.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "fpg_unitSystem"

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = UnitSystem(rawValue: raw) {
            self.unitSystem = saved
        }
    }

    var isMetric: Bool { unitSystem == .metric }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Conversion Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    // ── Pressure ─────────────────────────────────
    func barToPsi(_ bar: Double)  -> Double { bar * 14.503_773_8 }
    func psiToBar(_ psi: Double)  -> Double { psi / 14.503_773_8 }

    // ── Temperature ──────────────────────────────
    func celsiusToFahrenheit(_ c: Double) -> Double { c * 9.0 / 5.0 + 32.0 }
    func fahrenheitToCelsius(_ f: Double) -> Double { (f - 32.0) * 5.0 / 9.0 }

    // ── Length ────────────────────────────────────
    func mmToInch(_ mm: Double)   -> Double { mm / 25.4 }
    func inchToMm(_ inch: Double) -> Double { inch * 25.4 }

    // ── Power ────────────────────────────────────
    func kwToHp(_ kw: Double)     -> Double { kw * 1.341_022 }
    func hpToKw(_ hp: Double)     -> Double { hp / 1.341_022 }

    // ── Flow ─────────────────────────────────────
    func lpmToGpm(_ lpm: Double)  -> Double { lpm * 0.264_172 }
    func gpmToLpm(_ gpm: Double)  -> Double { gpm / 0.264_172 }

    // ── Area ─────────────────────────────────────
    func mm2ToIn2(_ mm2: Double)  -> Double { mm2 / 645.16 }
    func in2ToMm2(_ in2: Double)  -> Double { in2 * 645.16 }

    // ── Force ────────────────────────────────────
    func newtonsToLbf(_ n: Double) -> Double { n * 0.224_809 }
    func lbfToNewtons(_ lbf: Double) -> Double { lbf / 0.224_809 }

    // ── Mass ─────────────────────────────────────
    func kgToLb(_ kg: Double)     -> Double { kg * 2.204_623 }
    func lbToKg(_ lb: Double)     -> Double { lb / 2.204_623 }

    // ── Volume ───────────────────────────────────
    func litersToGallons(_ l: Double) -> Double { l * 0.264_172 }
    func gallonsToLiters(_ g: Double) -> Double { g / 0.264_172 }

    // ── Wire Size (AWG ↔ mm²) ────────────────────
    /// AWG → cross-section in mm²
    static func awgToMM2(_ awg: Int) -> Double {
        let d = 0.127 * pow(92.0, Double(36 - awg) / 39.0) // diameter in mm
        return Double.pi / 4.0 * d * d
    }

    /// mm² → nearest AWG (approximate)
    static func mm2ToAWG(_ mm2: Double) -> Int {
        let d = sqrt(4.0 * mm2 / Double.pi)
        let awg = 36.0 - 39.0 * log(d / 0.127) / log(92.0)
        return Int(round(awg))
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Display Labels for UI
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    var pressureUnit: String     { isMetric ? "bar"   : "psi" }
    var temperatureUnit: String  { isMetric ? "°C"    : "°F" }
    var lengthUnit: String       { isMetric ? "mm"    : "in" }
    var powerUnit: String        { isMetric ? "kW"    : "HP" }
    var flowUnit: String         { isMetric ? "L/min" : "GPM" }
    var areaUnit: String         { isMetric ? "mm²"   : "in²" }
    var forceUnit: String        { isMetric ? "N"     : "lbf" }
    var wireUnit: String         { isMetric ? "mm²"   : "AWG" }
    var massUnit: String         { isMetric ? "kg"    : "lb" }
    var volumeUnit: String       { isMetric ? "L"     : "gal" }
}
