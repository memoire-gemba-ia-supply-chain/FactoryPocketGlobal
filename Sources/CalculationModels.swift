// ──────────────────────────────────────────────
// CalculationModels.swift
// Factory Pocket Pro
//
// SwiftData models for calculation history,
// favorites and PDF export records.
// ──────────────────────────────────────────────

import SwiftUI
import SwiftData

// MARK: - Calculation Record

/// Persisted calculation result, stored via SwiftData.
@Model
final class CalculationRecord {
    var id: String = UUID().uuidString
    var calculatorName: String = ""
    var category: String = ""          // "hydraulics", "electrical", "finance", etc.
    var inputs: String = ""            // JSON-encoded dictionary
    var results: String = ""           // JSON-encoded dictionary
    var unitSystem: String = "Metric"
    var note: String = ""
    var createdAt: Date = Date()
    
    init(calculatorName: String, category: String, inputs: [String: String], results: [String: String], unitSystem: String, note: String = "") {
        self.calculatorName = calculatorName
        self.category = category
        self.inputs = Self.encode(inputs)
        self.results = Self.encode(results)
        self.unitSystem = unitSystem
        self.note = note
        self.createdAt = Date()
    }
    
    // MARK: - JSON Helpers
    
    var inputsDictionary: [String: String] {
        Self.decode(inputs)
    }
    
    var resultsDictionary: [String: String] {
        Self.decode(results)
    }
    
    private static func encode(_ dict: [String: String]) -> String {
        guard let data = try? JSONEncoder().encode(dict),
              let str = String(data: data, encoding: .utf8) else { return "{}" }
        return str
    }
    
    private static func decode(_ str: String) -> [String: String] {
        guard let data = str.data(using: .utf8),
              let dict = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
        return dict
    }
}

// MARK: - Favorite Calculator

/// Bookmark a calculator for quick access on dashboard.
@Model
final class FavoriteCalculator {
    var id: String = UUID().uuidString
    var calculatorName: String = ""
    var category: String = ""
    var icon: String = ""
    var color: String = "orange"       // SwiftUI color name
    var addedAt: Date = Date()
    
    init(calculatorName: String, category: String, icon: String, color: String = "orange") {
        self.calculatorName = calculatorName
        self.category = category
        self.icon = icon
        self.color = color
        self.addedAt = Date()
    }
}

// MARK: - Calculator Registry

/// Central registry mapping calculator names to their metadata.
/// Used for navigation, favorites, and history display.
struct CalculatorInfo: Identifiable {
    let id: String
    let name: String
    let nameFR: String
    let category: String
    let categoryFR: String
    let icon: String
    let color: Color
    
    var localizedName: String { L10n.isFrench ? nameFR : name }
    var localizedCategory: String { L10n.isFrench ? categoryFR : category }
}

enum CalculatorRegistry {
    static let all: [CalculatorInfo] = [
        // Hydraulics
        CalculatorInfo(id: "cylinder_force", name: "Cylinder Force", nameFR: "Force Vérin", category: "Hydraulics", categoryFR: "Hydraulique", icon: "drop.fill", color: .cyan),
        CalculatorInfo(id: "hydraulic_power", name: "Hydraulic Power", nameFR: "Puissance Hydraulique", category: "Hydraulics", categoryFR: "Hydraulique", icon: "bolt.horizontal.fill", color: .cyan),
        CalculatorInfo(id: "flow_velocity", name: "Flow Velocity", nameFR: "Vitesse d'Écoulement", category: "Hydraulics", categoryFR: "Hydraulique", icon: "arrow.right.circle.fill", color: .cyan),
        CalculatorInfo(id: "pipe_pressure_loss", name: "Pipe Pressure Loss", nameFR: "Perte de Charge", category: "Hydraulics", categoryFR: "Hydraulique", icon: "drop.fill", color: .cyan),
        
        // Injection Molding
        CalculatorInfo(id: "clamping_force", name: "Clamping Force", nameFR: "Force de Fermeture", category: "Injection Molding", categoryFR: "Injection Plastique", icon: "cube.transparent.fill", color: .blue),
        CalculatorInfo(id: "cooling_time", name: "Cooling Time", nameFR: "Temps de Refroidissement", category: "Injection Molding", categoryFR: "Injection Plastique", icon: "thermometer.snowflake", color: .blue),
        
        // Electrical
        CalculatorInfo(id: "voltage_drop", name: "Voltage Drop", nameFR: "Chute de Tension", category: "Electrical", categoryFR: "Électricité", icon: "bolt.fill", color: .yellow),
        CalculatorInfo(id: "motor_calculator", name: "3-Phase Motor", nameFR: "Moteur Triphasé", category: "Electrical", categoryFR: "Électricité", icon: "battery.100percent.bolt", color: .yellow),
        CalculatorInfo(id: "cable_sizing", name: "Cable Sizing", nameFR: "Section Câble", category: "Electrical", categoryFR: "Électricité", icon: "bolt.circle.fill", color: .yellow),
        CalculatorInfo(id: "capacitor_bank", name: "Capacitor Bank", nameFR: "Batterie Condensateurs", category: "Electrical", categoryFR: "Électricité", icon: "bolt.horizontal.fill", color: .yellow),
        CalculatorInfo(id: "transformer_sizing", name: "Transformer Sizing", nameFR: "Dimensionnement Transfo", category: "Electrical", categoryFR: "Électricité", icon: "square.grid.3x3.fill", color: .yellow),
        
        // Pneumatics
        CalculatorInfo(id: "air_leak_cost", name: "Air Leak Cost", nameFR: "Coût Fuite d'Air", category: "Pneumatics", categoryFR: "Pneumatique", icon: "wind", color: .gray),
        CalculatorInfo(id: "pneumatic_cylinder", name: "Pneumatic Cylinder", nameFR: "Vérin Pneumatique", category: "Pneumatics", categoryFR: "Pneumatique", icon: "arrow.up.and.down.circle.fill", color: .gray),
        CalculatorInfo(id: "valve_cv", name: "Valve Cv/Kv", nameFR: "Valve Cv/Kv", category: "Pneumatics", categoryFR: "Pneumatique", icon: "gauge.with.needle.fill", color: .gray),
        
        // Finance
        CalculatorInfo(id: "roi_payback", name: "ROI & Payback", nameFR: "ROI & Payback", category: "Finance", categoryFR: "Finance", icon: "chart.line.uptrend.xyaxis", color: .green),
        CalculatorInfo(id: "npv", name: "Net Present Value", nameFR: "Valeur Actuelle Nette", category: "Finance", categoryFR: "Finance", icon: "dollarsign.circle.fill", color: .green),
        CalculatorInfo(id: "wacc", name: "WACC", nameFR: "WACC", category: "Finance", categoryFR: "Finance", icon: "percent", color: .mint),
        CalculatorInfo(id: "break_even", name: "Break-Even", nameFR: "Seuil de Rentabilité", category: "Finance", categoryFR: "Finance", icon: "chart.xyaxis.line", color: .mint),
        CalculatorInfo(id: "cost_unit", name: "Cost per Unit", nameFR: "Coût Unitaire", category: "Finance", categoryFR: "Finance", icon: "dollarsign.square", color: .orange),
        CalculatorInfo(id: "margin_markup", name: "Margin vs Markup", nameFR: "Marge vs Markup", category: "Finance", categoryFR: "Finance", icon: "arrow.up.arrow.down", color: .orange),
        CalculatorInfo(id: "currency_exchanger", name: "Currency Exchanger", nameFR: "Convertisseur Devises", category: "Finance", categoryFR: "Finance", icon: "dollarsign.arrow.circlepath", color: .blue),
        
        // Supply Chain
        CalculatorInfo(id: "turnover", name: "Inventory Turnover", nameFR: "Rotation des Stocks", category: "Supply Chain", categoryFR: "Supply Chain", icon: "arrow.triangle.2.circlepath", color: .blue),
        CalculatorInfo(id: "dsi", name: "Days Sales of Inventory", nameFR: "Jours de Stock", category: "Supply Chain", categoryFR: "Supply Chain", icon: "calendar", color: .blue),
        CalculatorInfo(id: "safety_stock", name: "Safety Stock", nameFR: "Stock de Sécurité", category: "Supply Chain", categoryFR: "Supply Chain", icon: "shield.fill", color: .blue),
        CalculatorInfo(id: "rop", name: "Reorder Point", nameFR: "Point de Commande", category: "Supply Chain", categoryFR: "Supply Chain", icon: "bell.fill", color: .blue),
        CalculatorInfo(id: "fill_rate", name: "Fill Rate", nameFR: "Taux de Service", category: "Logistics", categoryFR: "Logistique", icon: "checklist", color: .green),
        CalculatorInfo(id: "lead_time", name: "Lead Time", nameFR: "Délai d'Approvisionnement", category: "Logistics", categoryFR: "Logistique", icon: "clock.fill", color: .green),
        CalculatorInfo(id: "takt_time", name: "Takt Time", nameFR: "Temps Takt", category: "Lean", categoryFR: "Lean", icon: "clock.fill", color: .orange),
        CalculatorInfo(id: "oee", name: "OEE (TRS)", nameFR: "TRS (OEE)", category: "Lean", categoryFR: "Lean", icon: "gauge.with.needle.fill", color: .orange),
        CalculatorInfo(id: "six_sigma", name: "Six Sigma", nameFR: "Six Sigma", category: "Lean", categoryFR: "Lean", icon: "chart.bar.fill", color: .orange),
        CalculatorInfo(id: "eoq", name: "EOQ", nameFR: "QEC", category: "Lean", categoryFR: "Lean", icon: "bag.fill", color: .orange),
    ]
    
    static func find(_ id: String) -> CalculatorInfo? {
        all.first { $0.id == id }
    }
    
    static func colorForName(_ name: String) -> Color {
        all.first { $0.name == name || $0.nameFR == name }?.color ?? .orange
    }
    
    static func iconForName(_ name: String) -> String {
        all.first { $0.name == name || $0.nameFR == name }?.icon ?? "function"
    }
}
