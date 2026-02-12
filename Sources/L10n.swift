// ──────────────────────────────────────────────
// L10n.swift
// Factory Pocket Pro
//
// Centralized localization engine.
// Auto-detects device language (French / English).
// ──────────────────────────────────────────────

import Foundation

/// Lightweight localization helper.
/// Uses the device's preferred language to return French or English strings.
enum L10n {
    
    /// `true` when the device's primary language is French.
    static let isFrench: Bool = {
        guard let lang = Locale.preferredLanguages.first else { return false }
        return lang.hasPrefix("fr")
    }()
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Dashboard
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let globalIndices       = isFrench ? "Indices Mondiaux"           : "Global Indices"
    static let energyOil           = isFrench ? "Énergie & Pétrole"         : "Energy & Oil"
    static let metals              = isFrench ? "Métaux"                    : "Metals"
    static let currencies          = isFrench ? "Devises"                   : "Currencies"
    static let agriculture         = isFrench ? "Agriculture"               : "Agriculture"
    static let quickAccess         = isFrench ? "Accès Rapide"              : "Quick Access"
    static let supplyChain         = isFrench ? "Chaîne Logistique"         : "Supply Chain"
    static let engineering         = isFrench ? "Ingénierie"                : "Engineering"
    static let finance             = isFrench ? "Finance"                   : "Finance"
    static let library             = isFrench ? "Bibliothèque"              : "Library"
    
    // Empty state
    static let staleData           = isFrench ? "Données Obsolètes"         : "Stale Data"
    static let marketUnavailable   = isFrench ? "Données Indisponibles"     : "Market Data Unavailable"
    static let staleHint           = isFrench ? "Les données ne sont pas du jour. Appuyez sur ↻." : "Data is not from today. Tap ↻ to refresh."
    static let loadingHint         = isFrench ? "Chargement des données…"   : "Loading market data…"
    static let refreshNow          = isFrench ? "Actualiser"                : "Refresh Now"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Market Manager (Audit Status)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let dataVerified        = isFrench ? "Données vérifiées ✓"       : "Data verified ✓"
    static let staleNotToday       = isFrench ? "Données pas du jour"       : "Stale data (not from today)"
    static let dataTooOld          = isFrench ? "Données trop anciennes (>48h)" : "Data too old (>48h)"
    static let cacheTooOld         = isFrench ? "Cache trop ancien (>48h)"  : "Cache too old (>48h)"
    static let cacheStale          = isFrench ? "Cache pas du jour"         : "Cache stale (not from today)"
    
    static func incompleteData(_ n: Int) -> String {
        isFrench ? "Données incomplètes (\(n) catégories)" : "Incomplete data (\(n) categories)"
    }
    static let invalidRates        = isFrench ? "Taux invalides (USD ≠ 1.0)" : "Invalid rates (USD ≠ 1.0)"
    static func insufficientRates(_ n: Int) -> String {
        isFrench ? "Taux insuffisants (\(n) devises)" : "Insufficient rates (\(n) currencies)"
    }
    
    // Time labels
    static let never               = isFrench ? "Jamais"                    : "Never"
    static let justNow             = isFrench ? "À l'instant"               : "Just now"
    static func minutesAgo(_ m: Int) -> String { isFrench ? "il y a \(m) min" : "\(m) min ago" }
    static func hoursAgo(_ h: Int)   -> String { isFrench ? "il y a \(h)h"    : "\(h)h ago" }
    static func daysAgo(_ d: Int)    -> String { isFrench ? "il y a \(d)j"    : "\(d)d ago" }
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Settings
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let settings            = isFrench ? "Réglages"                  : "Settings"
    static let globalUnits         = isFrench ? "Unités Globales"           : "Global Units"
    static let system              = isFrench ? "Système"                   : "System"
    static let pressure            = isFrench ? "Pression"                  : "Pressure"
    static let temperature         = isFrench ? "Température"               : "Temperature"
    static let power               = isFrench ? "Puissance"                 : "Power"
    static let resetCache          = isFrench ? "Vider le Cache"            : "Reset Cache"
    static let resetCacheFooter    = isFrench ? "Efface les données de marché et les préférences locales." : "Clears downloaded market data and locally saved presets."
    static let version             = isFrench ? "Version"                   : "Version"
    static let done                = isFrench ? "OK"                        : "Done"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Technical View
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let technical           = isFrench ? "Technique"                 : "Technical"
    static let hydraulics          = isFrench ? "Hydraulique"               : "Hydraulics"
    static let injectionMolding    = isFrench ? "Injection Plastique"       : "Injection Molding"
    static let electrical          = isFrench ? "Électricité"               : "Electrical"
    static let pneumatics          = isFrench ? "Pneumatique"               : "Pneumatics"
    
    // Hydraulics
    static let cylinderForce       = isFrench ? "Force Vérin"               : "Cylinder Force"
    static let cylinderForceSub    = isFrench ? "Poussée & Traction"        : "Push & Pull Capacity"
    static let hydraulicPower      = isFrench ? "Puissance Hydraulique"     : "Hydraulic Power"
    static let hydraulicPowerSub   = isFrench ? "Débit × Pression → kW/HP" : "Flow × Pressure → kW/HP"
    static let flowVelocity        = isFrench ? "Vitesse d'Écoulement"      : "Flow Velocity"
    static let flowVelocitySub     = isFrench ? "Contrôle Vitesse Tube"     : "Pipe Velocity Check"
    static let pipePressureLoss    = isFrench ? "Perte de Charge"           : "Pipe Pressure Loss"
    static let pipePressureLossSub = isFrench ? "Darcy-Weisbach ΔP"         : "Darcy-Weisbach ΔP"
    
    // Injection Molding
    static let clampingForce       = isFrench ? "Force de Fermeture"        : "Clamping Force"
    static let clampingForceSub    = isFrench ? "Tonnage Machine Requis"    : "Required Machine Tonnage"
    static let coolingTime         = isFrench ? "Temps de Refroidissement"  : "Cooling Time"
    static let coolingTimeSub      = isFrench ? "Optimisation Cycle"        : "Cycle Time Optimization"
    
    // Electrical
    static let voltageDrop         = isFrench ? "Chute de Tension"          : "Voltage Drop"
    static let voltageDropSub      = isFrench ? "Conformité Normes"         : "Code Compliance Check"
    static let threePhaseMotor     = isFrench ? "Moteur Triphasé"           : "3-Phase Motor"
    static let threePhaseMotorSub  = isFrench ? "Ampères, Puissance & η"   : "Amps, Power & Efficiency"
    static let cableSizing         = isFrench ? "Section de Câble"          : "Cable Sizing"
    static let cableSizingSub      = isFrench ? "Section Min. pour Chute"   : "Min Cross-Section for Drop"
    static let capacitorBank       = isFrench ? "Batterie de Condensateurs" : "Capacitor Bank"
    static let capacitorBankSub    = isFrench ? "Correction du Facteur"     : "Power Factor Correction"
    static let transformerSizing   = isFrench ? "Dimensionnement Transfo"   : "Transformer Sizing"
    static let transformerSizingSub = isFrench ? "Puissance kVA & Courant" : "kVA Rating & Current"
    
    // Pneumatics
    static let airLeakCost         = isFrench ? "Coût Fuite d'Air"          : "Air Leak Cost"
    static let airLeakCostSub      = isFrench ? "Estimation Perte Énergie"  : "Energy Loss Estimator"
    static let pneumaticCylinder   = isFrench ? "Vérin Pneumatique"         : "Pneumatic Cylinder"
    static let pneumaticCylinderSub = isFrench ? "Force Poussée & Traction" : "Push & Pull Force"
    static let valveCv             = isFrench ? "Cv Vanne / Débit"          : "Valve Cv / Flow"
    static let valveCvSub          = isFrench ? "Coefficient de Débit"      : "Flow Coefficient"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Finance View
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let financeTitle        = isFrench ? "Finance"                   : "Finance"
    static let investmentAnalysis  = isFrench ? "Analyse d'Investissement"  : "Investment Analysis"
    static let capitalPlanning     = isFrench ? "Planification du Capital"  : "Capital Planning"
    static let operations          = isFrench ? "Opérations"                : "Operations"
    static let tools               = isFrench ? "Outils"                    : "Tools"
    
    static let roiCalc             = isFrench ? "ROI & Payback"             : "ROI & Payback"
    static let roiSub              = isFrench ? "Retour sur Investissement" : "Return on Investment"
    static let npv                 = isFrench ? "Valeur Actuelle Nette"     : "Net Present Value"
    static let npvSub              = isFrench ? "Cash Flows Actualisés"     : "Discounted Cash Flow"
    static let irr                 = isFrench ? "TRI (IRR)"                 : "IRR"
    static let irrSub              = isFrench ? "Taux de Rendement Interne" : "Internal Rate of Return"
    static let wacc                = isFrench ? "CMPC (WACC)"               : "WACC"
    static let waccSub             = isFrench ? "Coût Pondéré du Capital"   : "Weighted Cost of Capital"
    static let depreciation        = isFrench ? "Amortissement"             : "Depreciation"
    static let depreciationSub     = isFrench ? "Linéaire & Dégressif"      : "SL & Declining Balance"
    static let loanAmortization    = isFrench ? "Prêt / Amortissement"      : "Loan Amortization"
    static let loanAmortizationSub = isFrench ? "Mensualité & Intérêts"     : "Monthly Payment & Interest"
    static let breakeven           = isFrench ? "Seuil de Rentabilité"      : "Break-Even"
    static let breakevenSub        = isFrench ? "Point Mort"                : "Profitability Threshold"
    static let marginMarkup        = isFrench ? "Marge vs Markup"           : "Margin vs Markup"
    static let marginMarkupSub     = isFrench ? "Analyse de Prix"           : "Pricing Analysis"
    static let currencyExchanger   = isFrench ? "Convertisseur de Devises"  : "Currency Exchanger"
    static let currencyExchangerSub = isFrench ? "Taux en Direct (30+ Devises)" : "Live Rates (30+ Currencies)"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Supply Chain View
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let supplyChainTitle    = isFrench ? "Chaîne Logistique"         : "Supply Chain"
    static let inventoryMgmt       = isFrench ? "Gestion des Stocks"        : "Inventory Management"
    static let logisticsFulfill    = isFrench ? "Logistique & Expédition"    : "Logistics & Fulfillment"
    static let leanOps             = isFrench ? "Lean & Opérations"          : "Lean & Operations"
    static let utility             = isFrench ? "Utilitaires"               : "Utility"
    
    static let turnover            = isFrench ? "Rotation des Stocks"       : "Inventory Turnover"
    static let turnoverSub         = isFrench ? "Ratio d'Efficacité"        : "Efficiency Ratio"
    static let dsi                 = isFrench ? "Jours de Stock"            : "Days Sales of Inventory"
    static let dsiSub              = isFrench ? "Métrique de Liquidité"     : "Liquidity Metric"
    static let safetyStock         = isFrench ? "Stock de Sécurité"         : "Safety Stock"
    static let safetyStockSub      = isFrench ? "Prévention Rupture"        : "Buffer Prevention"
    static let rop                 = isFrench ? "Point de Commande (ROP)"   : "Reorder Point (ROP)"
    static let ropSub              = isFrench ? "Déclencheur Réappro"       : "Replenishment Trigger"
    static let eoq                 = isFrench ? "QEC (Wilson)"              : "EOQ (Wilson)"
    static let eoqSub              = isFrench ? "Quantité Optimale"         : "Optimal Order Size"
    
    static let fillRate            = isFrench ? "Taux de Remplissage"       : "Order Fill Rate"
    static let fillRateSub         = isFrench ? "KPI Niveau de Service"     : "Service Level KPI"
    static let otd                 = isFrench ? "Livraison à Temps"         : "On-Time Delivery"
    static let otdSub              = isFrench ? "Promesse Client"           : "Customer Promise"
    static let freightCost         = isFrench ? "Coût de Fret"              : "Freight Cost"
    static let freightCostSub      = isFrench ? "Coût par Unité"            : "Cost per Unit"
    
    static let taktTime            = isFrench ? "Temps Takt"                : "Takt Time"
    static let taktTimeSub         = isFrench ? "Rythme de la Demande"      : "Pace of Demand"
    static let oee                 = isFrench ? "TRS (OEE)"                 : "OEE (TRS)"
    static let oeeSub              = isFrench ? "Efficacité Équipement"     : "Equipment Efficiency"
    static let machineUtil         = isFrench ? "Utilisation Machine"       : "Machine Utilization"
    static let machineUtilSub      = isFrench ? "Usage des Actifs"          : "Asset Usage"
    static let sixSigma            = isFrench ? "Six Sigma"                 : "Six Sigma"
    static let sixSigmaSub         = isFrench ? "Capabilité Qualité"        : "Quality Capability"
    
    static let partWeight          = isFrench ? "Poids Pièce"               : "Part Weight"
    static let partWeightSub       = isFrench ? "Volume vers Masse"         : "Volume to Mass"
    static let scrapRate           = isFrench ? "Taux de Rebut"             : "Scrap Rate"
    static let scrapRateSub        = isFrench ? "Pourcentage Défauts"       : "Defect Percentage"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Library View
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let refLibrary          = isFrench ? "Bibliothèque"              : "Ref. Library"
    static let searchPrompt        = isFrench ? "Rechercher matériaux, boulons…" : "Search materials, bolts…"
    static let allMaterials        = isFrench ? "Tous les Matériaux"        : "All Materials"
    static let fasteners           = isFrench ? "Boulonnerie"               : "Fasteners"
    static let mechanicalFits      = isFrench ? "Ajustements Mécaniques"    : "Mechanical Fits"
    static let isoMetricBolts      = isFrench ? "Boulons ISO Métriques (M4 - M30)" : "ISO Metric Bolts (M4 - M30)"
    static let saeImperialBolts    = isFrench ? "Boulons SAE Impériaux (1/4 - 1\")" : "SAE Imperial Bolts (1/4 - 1\")"
    static let isoFitCalc          = isFrench ? "Calculateur ISO 286"       : "ISO 286 Fit Calculator"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Currency Exchanger
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let currencyTitle       = isFrench ? "Convertisseur"             : "Currency Exchanger"
    static let amount              = isFrench ? "Montant"                   : "Amount"
    static let from                = isFrench ? "De"                        : "From"
    static let to                  = isFrench ? "Vers"                      : "To"
    static let result              = isFrench ? "Résultat"                  : "Result"
    static let rate                = isFrench ? "Taux"                      : "Rate"
    static let swap                = isFrench ? "Inverser Devises"          : "Swap Currencies"
    static let loadingRates        = isFrench ? "Chargement des Taux..."    : "Loading Rates..."
    static func lastUpdated(_ t: String) -> String {
        isFrench ? "Mise à jour: \(t)" : "Last Updated: \(t)"
    }
    static let noRatesAvailable    = isFrench ? "Aucun taux disponible"     : "No rates available"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Tab Bar
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let tabDashboard        = isFrench ? "Tableau de Bord"           : "Dashboard"
    static let tabTechnical        = isFrench ? "Technique"                 : "Technical"
    static let tabFinance          = isFrench ? "Finance"                   : "Finance"
    static let tabSupplyChain      = isFrench ? "Logistique"                : "Supply Chain"
    static let tabLibrary          = isFrench ? "Bibliothèque"              : "Library"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Materials
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static func materialsCount(_ n: Int) -> String {
        isFrench ? "Matériaux (\(n))" : "Materials (\(n))"
    }
    static let physicalProperties  = isFrench ? "Propriétés Physiques"      : "Physical Properties"
    static let processing          = isFrench ? "Mise en Œuvre"             : "Processing"
    static let density             = isFrench ? "Densité"                   : "Density"
    static let meltPoint           = isFrench ? "Point de Fusion"           : "Melt Point"
    static let elasticModulus      = isFrench ? "Module d'Élasticité"       : "Elastic Modulus"
    static let shrinkage           = isFrench ? "Retrait"                   : "Shrinkage"
    static let thermalDiffusivity  = isFrench ? "Diffusivité Thermique"     : "Thermal Diffusivity"
    
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Common Engineering Terms
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    static let inputs              = isFrench ? "Données"                   : "Input Data"
    static let results             = isFrench ? "Résultats"                 : "Results"
    static let calculate           = isFrench ? "Calculer"                  : "Calculate"
    
    // Physics / Dimensions
    static let pressureParam       = isFrench ? "Pression"                  : "Pressure"
    static let flowRate            = isFrench ? "Débit"                     : "Flow Rate"
    static let diameter            = isFrench ? "Diamètre"                  : "Diameter"
    static let length              = isFrench ? "Longueur"                  : "Length"
    static let width               = isFrench ? "Largeur"                   : "Width"
    static let thickness           = isFrench ? "Épaisseur"                 : "Thickness"
    static let area                = isFrench ? "Surface"                   : "Area"
    static let volume              = isFrench ? "Volume"                    : "Volume"
    static let temperatureParam    = isFrench ? "Température"               : "Temperature"
    static let velocity            = isFrench ? "Vitesse"                   : "Velocity"
    static let force               = isFrench ? "Force"                     : "Force"
    static let powerParam          = isFrench ? "Puissance"                 : "Power"
    static let energy              = isFrench ? "Énergie"                   : "Energy"
    static let time                = isFrench ? "Temps"                     : "Time"
    static let efficiency          = isFrench ? "Efficacité"                : "Efficiency"
    static let frequency           = isFrench ? "Fréquence"                 : "Frequency"
    static let cost                = isFrench ? "Coût"                      : "Cost"
    
    // Electrical
    static let voltageParam        = isFrench ? "Tension"                   : "Voltage"
    static let currentParam        = isFrench ? "Courant"                   : "Current"
    static let resistance          = isFrench ? "Résistance"                : "Resistance"
    static let powerFactor         = isFrench ? "Facteur de Puissance"      : "Power Factor"
    
    // Specific Labels
    static let pushForce           = isFrench ? "Force Poussée"             : "Push Force"
    static let pullForce           = isFrench ? "Force Traction"            : "Pull Force"
    static let pistonDiameter      = isFrench ? "Diamètre Piston"           : "Piston Diameter"
    static let rodDiameter         = isFrench ? "Diamètre Tige"             : "Rod Diameter"
    static let boreDiameter        = isFrench ? "Alésage"                   : "Bore Diameter"
    static let pressureDropLabel   = isFrench ? "Chute de Pression"         : "Pressure Drop"
    static let coolingTimeLabel    = isFrench ? "Temps de Refroidissement"  : "Cooling Time"
    static let clampingForceLabel  = isFrench ? "Force de Fermeture"        : "Clamping Force"
    static let moldTemp            = isFrench ? "Temp. Moule"               : "Mold Temp"
    static let meltTemp            = isFrench ? "Temp. Matière"             : "Melt Temp"
    static let ejectTemp           = isFrench ? "Temp. Éjection"            : "Ejection Temp"

    
    // Onboarding & Premium
    static let premiumWelcome      = isFrench ? "Bienvenue sur Factory Pocket Pro 👑" : "Welcome to Factory Pocket Pro 👑"
    static let limitedOffer        = isFrench ? "Offre à Durée Limitée"     : "Limited Time Offer"
    static let lifeTimeAccess      = isFrench ? "Accès à Vie : 0$ (au lieu de 19.99$/an)" : "Lifetime Access: $0 (was $19.99/yr)"
    static let claimOffer          = isFrench ? "Profiter de l'Offre"       : "Claim Offer"
    static let startUsing          = isFrench ? "Commencer"                 : "Start Using App"
    static let premiumBadge        = isFrench ? "Premium"                   : "Premium"
}
