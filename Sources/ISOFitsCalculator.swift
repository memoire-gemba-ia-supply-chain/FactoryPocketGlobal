// ──────────────────────────────────────────────
// ISOFitsCalculator.swift
// Factory Pocket Pro
//
// ISO 286 system of limits and fits.
// Handles Hole-basis (H7 etc.) and Shaft-basis (g6 etc.).
// ──────────────────────────────────────────────

import Foundation

enum FitType: String {
    case clearance = "Clearance Fit"
    case transition = "Transition Fit"
    case interference = "Interference Fit"
}

struct FitDeviation {
    let lower: Double // microns (µm)
    let upper: Double // microns (µm)
}

struct ISOFitsCalculator {
    
    /// IT Grades (Fundamental Tolerances) per ISO 286-1
    /// Dimensions in mm, values in microns (µm).
    static func getITValue(dimension: Double, grade: Int) -> Double? {
        // Simplified lookup for common engineering grades (IT5-IT11)
        // Values roughly follow i = 0.45 * (D^(1/3)) + 0.001 * D
        let i = 0.45 * pow(dimension, 1.0/3.0) + 0.001 * dimension
        
        switch grade {
        case 5:  return 7 * i
        case 6:  return 10 * i
        case 7:  return 16 * i
        case 8:  return 25 * i
        case 9:  return 40 * i
        case 10: return 64 * i
        case 11: return 100 * i
        default: return nil
        }
    }
    
    /// Calculate deviation for common Hole and Shaft identifiers
    /// Note: This is a representative engine; full ISO 286-2 tables are massive.
    /// Focus on: H7, g6, f7, n6, p6 (Classic engineering fits).
    static func getDeviation(symbol: String, dimension: Double) -> FitDeviation? {
        let it7 = getITValue(dimension: dimension, grade: 7) ?? 0
        let it6 = getITValue(dimension: dimension, grade: 6) ?? 0
        
        switch symbol.uppercased() {
        case "H7":
            // H always starts at 0
            return FitDeviation(lower: 0, upper: it7)
            
        case "H8":
            let it8 = getITValue(dimension: dimension, grade: 8) ?? 0
            return FitDeviation(lower: 0, upper: it8)
            
        case "G6":
            // g is slightly below (clearance)
            let fundamental = -5.0
            return FitDeviation(lower: fundamental - it6, upper: fundamental)
        
        case "F7":
            // f is a larger clearance fit
            let fundamental = -10.0
            return FitDeviation(lower: fundamental - it7, upper: fundamental)
            
        case "N6":
            // n is a transition fit (slight interference)
            let fundamental = 8.0
            return FitDeviation(lower: fundamental, upper: fundamental + it6)
            
        case "P6":
            // p is interference
            let fundamental = 15.0
            return FitDeviation(lower: fundamental, upper: fundamental + it6)
            
        default:
            return nil
        }
    }
    
    static func detectFitType(hole: FitDeviation, shaft: FitDeviation) -> FitType {
        let maxClearance = hole.upper - shaft.lower
        let minClearance = hole.lower - shaft.upper
        
        if minClearance >= 0 {
            return .clearance
        } else if maxClearance <= 0 {
            return .interference
        } else {
            return .transition
        }
    }
}
