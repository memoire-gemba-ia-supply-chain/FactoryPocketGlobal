// ──────────────────────────────────────────────
// MaterialDatabase.swift
// Factory Pocket Pro
//
// Static database of 50+ industrial materials
// with physical and processing properties.
// ──────────────────────────────────────────────

import Foundation

struct IndustrialMaterial: Identifiable, Codable {
    let id: String
    let name: String
    let category: MaterialCategory
    
    // Properties
    let density: Double           // g/cm³
    let meltTemp: Double?         // °C (if applicable)
    let shrinkage: DoubleRange?   // % (min...max)
    let thermalDiffusivity: Double? // mm²/s
    let elasticModulus: Double?   // GPa
    
    struct DoubleRange: Codable {
        let min: Double
        let max: Double
        
        var average: Double { (min + max) / 2.0 }
    }
}

enum MaterialCategory: String, CaseIterable, Codable, Identifiable {
    case plastics = "Plastics & Polymers"
    case metals   = "Metals & Alloys"
    case ceramics = "Ceramics"
    case composites = "Composites"
    case others = "Other Materials"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .plastics:   return "pyramid.fill"
        case .metals:     return "hammer.fill"
        case .ceramics:   return "house.lodge.fill"
        case .composites: return "square.stack.3d.up.fill"
        case .others:     return "questionmark.circle.fill"
        }
    }
}

struct MaterialDatabase {
    
    static let all: [IndustrialMaterial] = [
        // ── PLASTICS ──────────────────────────────────────────
        IndustrialMaterial(id: "pp", name: "PP (Polypropylene)", category: .plastics, density: 0.90, meltTemp: 230, shrinkage: .init(min: 1.0, max: 2.5), thermalDiffusivity: 0.08, elasticModulus: 1.5),
        IndustrialMaterial(id: "pe-hd", name: "HDPE", category: .plastics, density: 0.95, meltTemp: 220, shrinkage: .init(min: 1.5, max: 4.0), thermalDiffusivity: 0.12, elasticModulus: 0.8),
        IndustrialMaterial(id: "abs", name: "ABS", category: .plastics, density: 1.05, meltTemp: 240, shrinkage: .init(min: 0.3, max: 0.8), thermalDiffusivity: 0.07, elasticModulus: 2.4),
        IndustrialMaterial(id: "pa6", name: "PA6 (Nylon 6)", category: .plastics, density: 1.13, meltTemp: 260, shrinkage: .init(min: 0.7, max: 1.5), thermalDiffusivity: 0.09, elasticModulus: 2.8),
        IndustrialMaterial(id: "pc", name: "PC (Polycarbonate)", category: .plastics, density: 1.20, meltTemp: 290, shrinkage: .init(min: 0.5, max: 0.8), thermalDiffusivity: 0.10, elasticModulus: 2.3),
        IndustrialMaterial(id: "pet", name: "PET", category: .plastics, density: 1.37, meltTemp: 270, shrinkage: .init(min: 0.2, max: 0.5), thermalDiffusivity: 0.11, elasticModulus: 3.0),
        IndustrialMaterial(id: "pvc-u", name: "PVC-U", category: .plastics, density: 1.40, meltTemp: 190, shrinkage: .init(min: 0.1, max: 0.5), thermalDiffusivity: 0.08, elasticModulus: 3.3),
        IndustrialMaterial(id: "ps", name: "PS (Polystyrene)", category: .plastics, density: 1.05, meltTemp: 210, shrinkage: .init(min: 0.4, max: 0.7), thermalDiffusivity: 0.07, elasticModulus: 3.2),
        IndustrialMaterial(id: "pom", name: "POM (Acetal)", category: .plastics, density: 1.41, meltTemp: 200, shrinkage: .init(min: 1.8, max: 2.2), thermalDiffusivity: 0.10, elasticModulus: 2.9),
        IndustrialMaterial(id: "pmma", name: "PMMA (Acrylic)", category: .plastics, density: 1.18, meltTemp: 240, shrinkage: .init(min: 0.2, max: 0.8), thermalDiffusivity: 0.07, elasticModulus: 3.1),
        IndustrialMaterial(id: "peek", name: "PEEK", category: .plastics, density: 1.32, meltTemp: 380, shrinkage: .init(min: 1.0, max: 1.5), thermalDiffusivity: 0.13, elasticModulus: 3.6),
        IndustrialMaterial(id: "pps", name: "PPS", category: .plastics, density: 1.35, meltTemp: 310, shrinkage: .init(min: 0.2, max: 0.6), thermalDiffusivity: 0.11, elasticModulus: 3.8),
        
        // ── METALS ────────────────────────────────────────────
        IndustrialMaterial(id: "steel-304", name: "Steel 304 (Stainless)", category: .metals, density: 8.00, meltTemp: 1450, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 193),
        IndustrialMaterial(id: "steel-316", name: "Steel 316 (Stainless)", category: .metals, density: 8.00, meltTemp: 1400, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 193),
        IndustrialMaterial(id: "alum-6061", name: "Aluminum 6061", category: .metals, density: 2.70, meltTemp: 650, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 69),
        IndustrialMaterial(id: "alum-7075", name: "Aluminum 7075", category: .metals, density: 2.81, meltTemp: 635, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 72),
        IndustrialMaterial(id: "iron-cast", name: "Cast Iron", category: .metals, density: 7.20, meltTemp: 1200, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 170),
        IndustrialMaterial(id: "copper-pure", name: "Copper (Pure)", category: .metals, density: 8.96, meltTemp: 1085, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 120),
        IndustrialMaterial(id: "brass", name: "Brass", category: .metals, density: 8.50, meltTemp: 930, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 100),
        IndustrialMaterial(id: "titanium-gr5", name: "Titanium Gr5 (Ti-6Al-4V)", category: .metals, density: 4.43, meltTemp: 1650, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 114),
        IndustrialMaterial(id: "magnesium-az91", name: "Magnesium AZ91D", category: .metals, density: 1.81, meltTemp: 595, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 45),
        IndustrialMaterial(id: "zinc-zamak3", name: "Zinc (Zamak 3)", category: .metals, density: 6.60, meltTemp: 390, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 96),
        
        // ── CERAMICS & OTHERS ─────────────────────────────────
        IndustrialMaterial(id: "alumina", name: "Alumina (Al2O3)", category: .ceramics, density: 3.95, meltTemp: 2050, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 380),
        IndustrialMaterial(id: "zirconia", name: "Zirconia (ZrO2)", category: .ceramics, density: 5.68, meltTemp: 2700, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 210),
        IndustrialMaterial(id: "glass-borosilicate", name: "Borosilicate Glass", category: .ceramics, density: 2.23, meltTemp: 820, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 64),
        IndustrialMaterial(id: "carbon-fiber-epoxy", name: "Carbon Fiber / Epoxy", category: .composites, density: 1.60, meltTemp: nil, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 150),
        IndustrialMaterial(id: "concrete", name: "Concrete (Standard)", category: .others, density: 2.40, meltTemp: nil, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 30)
    ]
}

// Extension to bridge the category enum for more items
extension MaterialCategory {
    static var allCategories: [String] {
        return self.allCases.map { $0.rawValue } + ["Other Materials"]
    }
}

// Add more items to reach 50+
extension MaterialDatabase {
    static var extended: [IndustrialMaterial] {
        var base = all
        // Adding variants and technical grades
        let extras: [IndustrialMaterial] = [
            .init(id: "pe-ld", name: "LDPE", category: .plastics, density: 0.92, meltTemp: 190, shrinkage: .init(min: 1.5, max: 3.0), thermalDiffusivity: 0.10, elasticModulus: 0.2),
            .init(id: "pa66", name: "PA66 (Nylon 66)", category: .plastics, density: 1.14, meltTemp: 280, shrinkage: .init(min: 0.8, max: 2.0), thermalDiffusivity: 0.10, elasticModulus: 3.1),
            .init(id: "pet-g", name: "PET-G", category: .plastics, density: 1.27, meltTemp: 240, shrinkage: .init(min: 0.2, max: 0.6), thermalDiffusivity: 0.10, elasticModulus: 2.1),
            .init(id: "san", name: "SAN", category: .plastics, density: 1.08, meltTemp: 230, shrinkage: .init(min: 0.2, max: 0.6), thermalDiffusivity: 0.08, elasticModulus: 3.5),
            .init(id: "asa", name: "ASA", category: .plastics, density: 1.07, meltTemp: 250, shrinkage: .init(min: 0.4, max: 0.7), thermalDiffusivity: 0.08, elasticModulus: 2.4),
            .init(id: "tpe", name: "TPE (Thermoplastic Elastomer)", category: .plastics, density: 1.10, meltTemp: 210, shrinkage: .init(min: 1.0, max: 2.0), thermalDiffusivity: 0.06, elasticModulus: 0.1),
            .init(id: "tpu", name: "TPU (Polyurethane)", category: .plastics, density: 1.20, meltTemp: 220, shrinkage: .init(min: 0.8, max: 1.5), thermalDiffusivity: 0.06, elasticModulus: 0.1),
            .init(id: "pps-gf40", name: "PPS 40% GF", category: .plastics, density: 1.65, meltTemp: 310, shrinkage: .init(min: 0.1, max: 0.4), thermalDiffusivity: 0.15, elasticModulus: 14.5),
            .init(id: "steel-4140", name: "Steel 4140 (Chromoly)", category: .metals, density: 7.85, meltTemp: 1420, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 205),
            .init(id: "steel-d2", name: "Steel D2 (Tool Steel)", category: .metals, density: 7.70, meltTemp: 1400, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 210),
            .init(id: "alum-2024", name: "Aluminum 2024", category: .metals, density: 2.78, meltTemp: 640, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 73),
            .init(id: "bronze-phosphor", name: "Phosphor Bronze", category: .metals, density: 8.80, meltTemp: 950, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 110),
            .init(id: "inconel-625", name: "Inconel 625", category: .metals, density: 8.44, meltTemp: 1350, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 207),
            .init(id: "silicon-nitride", name: "Silicon Nitride (Si3N4)", category: .ceramics, density: 3.20, meltTemp: 1900, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 310),
            .init(id: "tungsten-carbide", name: "Tungsten Carbide", category: .ceramics, density: 15.6, meltTemp: 2800, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 600),
            .init(id: "molybdenum", name: "Molybdenum", category: .metals, density: 10.2, meltTemp: 2623, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 329),
            .init(id: "silver-pure", name: "Silver (Pure)", category: .metals, density: 10.5, meltTemp: 961, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 83),
            .init(id: "gold-24k", name: "Gold (24k)", category: .metals, density: 19.3, meltTemp: 1064, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 78),
            .init(id: "graphite", name: "Graphite", category: .composites, density: 2.20, meltTemp: 3600, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 10),
            .init(id: "teflon-ptfe", name: "PTFE (Teflon)", category: .plastics, density: 2.20, meltTemp: 327, shrinkage: .init(min: 2.0, max: 5.0), thermalDiffusivity: 0.07, elasticModulus: 0.5),
            .init(id: "epoxy-resin", name: "Epoxy Resin", category: .plastics, density: 1.25, meltTemp: nil, shrinkage: .init(min: 0.1, max: 0.3), thermalDiffusivity: 0.05, elasticModulus: 3.5),
            .init(id: "silicone-rubber", name: "Silicone Rubber", category: .plastics, density: 1.15, meltTemp: nil, shrinkage: .init(min: 2.0, max: 4.0), thermalDiffusivity: 0.04, elasticModulus: 0.01),
            .init(id: "kevlar-49", name: "Kevlar 49", category: .composites, density: 1.44, meltTemp: nil, shrinkage: nil, thermalDiffusivity: nil, elasticModulus: 112)
        ]
        base.append(contentsOf: extras)
        return base
    }
}

// Add one more catch-all category for UI
extension MaterialCategory {
    static var allWithOthers: [MaterialCategory] {
        return allCases
    }
}
