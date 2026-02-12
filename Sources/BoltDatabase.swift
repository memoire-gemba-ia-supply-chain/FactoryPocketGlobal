// ──────────────────────────────────────────────
// BoltDatabase.swift
// Factory Pocket Pro
//
// Torque and tension data for Metric (ISO 898)
// and Imperial (SAE J429) bolts.
// ──────────────────────────────────────────────

import Foundation

enum BoltGrade: String, CaseIterable, Identifiable {
    case metric88  = "Metric 8.8"
    case metric109 = "Metric 10.9"
    case metric129 = "Metric 12.9"
    case saeGr5    = "SAE Grade 5"
    case saeGr8    = "SAE Grade 8"
    
    var id: String { rawValue }
}

struct BoltSpecification: Identifiable {
    let id: String
    let size: String
    let pitch: Double?          // mm for metric
    let tpi: Int?               // threads per inch for imperial
    let proofLoad: Double       // MPa (metric) or PSI (imperial)
    let yieldStrength: Double   // MPa or PSI
    let tensileStrength: Double // MPa or PSI
}

struct BoltTorqueResult {
    let torque: Double
    let unit: String         // Nm or lb-ft
    let clampForce: Double   // kN or lbf
}

struct BoltDatabase {
    
    /// Calculate required torque for a given bolt size and k-factor.
    /// `T = k × D × F`
    static func calculateTorque(
        diameterMM: Double,
        clampForceKN: Double,
        nutFactorK: Double = 0.2 // Standard lubed = 0.15, Dry = 0.20
    ) -> Double {
        return nutFactorK * (diameterMM / 1000.0) * (clampForceKN * 1000.0)
    }
    
    // ── METRIC ISO 898-1 ───────────────────────────────────────
    
    struct MetricBolt {
        let size: String
        let diameter: Double // mm
        let stressArea: Double // mm²
    }
    
    static let metricBolts: [MetricBolt] = [
        .init(size: "M4",    diameter: 4.0,  stressArea: 8.78),
        .init(size: "M5",    diameter: 5.0,  stressArea: 14.2),
        .init(size: "M6",    diameter: 6.0,  stressArea: 20.1),
        .init(size: "M8",    diameter: 8.0,  stressArea: 36.6),
        .init(size: "M10",   diameter: 10.0, stressArea: 58.0),
        .init(size: "M12",   diameter: 12.0, stressArea: 84.3),
        .init(size: "M14",   diameter: 14.0, stressArea: 115.0),
        .init(size: "M16",   diameter: 16.0, stressArea: 157.0),
        .init(size: "M18",   diameter: 18.0, stressArea: 192.0),
        .init(size: "M20",   diameter: 20.0, stressArea: 245.0),
        .init(size: "M24",   diameter: 24.0, stressArea: 353.0),
        .init(size: "M30",   diameter: 30.0, stressArea: 561.0)
    ]
    
    // ── IMPERIAL SAE J429 ──────────────────────────────────────
    
    struct ImperialBolt {
        let size: String
        let diameter: Double  // in
        let stressArea: Double // in²
    }
    
    static let imperialBolts: [ImperialBolt] = [
        .init(size: "1/4-20",  diameter: 0.250, stressArea: 0.0318),
        .init(size: "5/16-18", diameter: 0.312, stressArea: 0.0524),
        .init(size: "3/8-16",  diameter: 0.375, stressArea: 0.0775),
        .init(size: "7/16-14", diameter: 0.437, stressArea: 0.1063),
        .init(size: "1/2-13",  diameter: 0.500, stressArea: 0.1419),
        .init(size: "9/16-12", diameter: 0.562, stressArea: 0.1820),
        .init(size: "5/8-11",  diameter: 0.625, stressArea: 0.2260),
        .init(size: "3/4-10",  diameter: 0.750, stressArea: 0.3340),
        .init(size: "7/8-9",   diameter: 0.875, stressArea: 0.4620),
        .init(size: "1-8",     diameter: 1.000, stressArea: 0.6060)
    ]
}
