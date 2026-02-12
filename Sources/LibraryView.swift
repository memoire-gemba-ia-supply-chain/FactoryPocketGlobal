import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: MaterialCategory?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.1).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    categoryPicker
                    
                    List {
                        materialSection
                        boltSection
                        fitSection
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(L10n.refLibrary)
            .searchable(text: $searchText, prompt: L10n.searchPrompt)
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                categoryButton(nil) // All
                ForEach(MaterialCategory.allCases) { cat in
                    categoryButton(cat)
                }
            }
            .padding()
        }
        .background(Color(white: 0.12))
    }
    
    private func categoryButton(_ cat: MaterialCategory?) -> some View {
        Button(action: { selectedCategory = cat }) {
            Text(cat?.rawValue ?? L10n.allMaterials)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedCategory == cat ? Color.orange : Color(white: 0.2))
                .foregroundColor(selectedCategory == cat ? .black : .white)
                .cornerRadius(20)
        }
    }
    
    private var filteredMaterials: [IndustrialMaterial] {
        MaterialDatabase.extended.filter {
            let matchesCat = selectedCategory == nil || $0.category == selectedCategory
            let matchesSearch = searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
            return matchesCat && matchesSearch
        }
    }
    
    private var materialSection: some View {
        Section(L10n.materialsCount(filteredMaterials.count)) {
            ForEach(filteredMaterials) { material in
                NavigationLink(destination: MaterialDetailView(material: material)) {
                    VStack(alignment: .leading) {
                        Text(material.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(material.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .listRowBackground(Color(white: 0.15))
            }
        }
    }
    
    private var boltSection: some View {
        Section(L10n.fasteners) {
            NavigationLink(L10n.isoMetricBolts) {
                MetricBoltTableView()
            }
            NavigationLink(L10n.saeImperialBolts) {
                ImperialBoltTableView()
            }
        }
        .listRowBackground(Color(white: 0.15))
        .foregroundColor(.orange)
    }
    
    private var fitSection: some View {
        Section(L10n.mechanicalFits) {
            NavigationLink(L10n.isoFitCalc) {
                ISOFitCalculatorView()
            }
        }
        .listRowBackground(Color(white: 0.15))
        .foregroundColor(.orange)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Bolt Data Models
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MetricBoltData: Identifiable {
    let id: String
    let size: String        // M4, M5, etc.
    let pitch: Double       // mm
    let tensileArea: Double // mm²
    let headSize: Double    // mm (hex across flats)
    let proofLoad88: Int    // N (Class 8.8)
    let proofLoad109: Int   // N (Class 10.9)
}

struct ImperialBoltData: Identifiable {
    let id: String
    let size: String        // 1/4", 5/16", etc.
    let tpiUNC: Int         // threads per inch
    let tensileArea: Double // in²
    let headHex: String     // across flats
    let proofGrade5: Int    // lbs
    let proofGrade8: Int    // lbs
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Metric Bolt Table
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct MetricBoltTableView: View {
    let bolts: [MetricBoltData] = [
        MetricBoltData(id: "M4",  size: "M4",  pitch: 0.7,  tensileArea: 8.78,   headSize: 7,   proofLoad88: 5_190,   proofLoad109: 7_380),
        MetricBoltData(id: "M5",  size: "M5",  pitch: 0.8,  tensileArea: 14.2,   headSize: 8,   proofLoad88: 8_400,   proofLoad109: 11_900),
        MetricBoltData(id: "M6",  size: "M6",  pitch: 1.0,  tensileArea: 20.1,   headSize: 10,  proofLoad88: 11_900,  proofLoad109: 16_900),
        MetricBoltData(id: "M8",  size: "M8",  pitch: 1.25, tensileArea: 36.6,   headSize: 13,  proofLoad88: 21_600,  proofLoad109: 30_700),
        MetricBoltData(id: "M10", size: "M10", pitch: 1.5,  tensileArea: 58.0,   headSize: 16,  proofLoad88: 34_300,  proofLoad109: 48_700),
        MetricBoltData(id: "M12", size: "M12", pitch: 1.75, tensileArea: 84.3,   headSize: 18,  proofLoad88: 49_800,  proofLoad109: 70_800),
        MetricBoltData(id: "M14", size: "M14", pitch: 2.0,  tensileArea: 115.0,  headSize: 21,  proofLoad88: 68_000,  proofLoad109: 96_600),
        MetricBoltData(id: "M16", size: "M16", pitch: 2.0,  tensileArea: 157.0,  headSize: 24,  proofLoad88: 92_800,  proofLoad109: 131_900),
        MetricBoltData(id: "M18", size: "M18", pitch: 2.5,  tensileArea: 192.0,  headSize: 27,  proofLoad88: 113_500, proofLoad109: 161_300),
        MetricBoltData(id: "M20", size: "M20", pitch: 2.5,  tensileArea: 245.0,  headSize: 30,  proofLoad88: 144_800, proofLoad109: 205_800),
        MetricBoltData(id: "M22", size: "M22", pitch: 2.5,  tensileArea: 303.0,  headSize: 32,  proofLoad88: 179_100, proofLoad109: 254_500),
        MetricBoltData(id: "M24", size: "M24", pitch: 3.0,  tensileArea: 353.0,  headSize: 36,  proofLoad88: 208_600, proofLoad109: 296_500),
        MetricBoltData(id: "M27", size: "M27", pitch: 3.0,  tensileArea: 459.0,  headSize: 41,  proofLoad88: 271_300, proofLoad109: 385_600),
        MetricBoltData(id: "M30", size: "M30", pitch: 3.5,  tensileArea: 561.0,  headSize: 46,  proofLoad88: 331_600, proofLoad109: 471_200),
    ]
    
    var body: some View {
        List {
            ForEach(bolts) { bolt in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(bolt.size)
                            .font(.headline).foregroundColor(.orange)
                        Spacer()
                        Text("Pitch: \(String(format: "%.2f", bolt.pitch)) mm")
                            .font(.caption).foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 16) {
                        boltDetail(label: "Tensile Area", value: "\(String(format: "%.1f", bolt.tensileArea)) mm²")
                        boltDetail(label: "Head (AF)", value: "\(Int(bolt.headSize)) mm")
                    }
                    
                    HStack(spacing: 16) {
                        boltDetail(label: "Proof 8.8", value: "\(bolt.proofLoad88.formatted()) N")
                        boltDetail(label: "Proof 10.9", value: "\(bolt.proofLoad109.formatted()) N")
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Color(white: 0.15))
            }
        }
        .navigationTitle("ISO Metric Bolts")
        .preferredColorScheme(.dark)
    }
    
    private func boltDetail(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundColor(.gray)
            Text(value).font(.caption).fontWeight(.bold).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Imperial Bolt Table
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ImperialBoltTableView: View {
    let bolts: [ImperialBoltData] = [
        ImperialBoltData(id: "1/4",  size: "1/4\"",  tpiUNC: 20, tensileArea: 0.0318, headHex: "7/16\"",  proofGrade5: 2_700,  proofGrade8: 3_810),
        ImperialBoltData(id: "5/16", size: "5/16\"", tpiUNC: 18, tensileArea: 0.0524, headHex: "1/2\"",   proofGrade5: 4_450,  proofGrade8: 6_280),
        ImperialBoltData(id: "3/8",  size: "3/8\"",  tpiUNC: 16, tensileArea: 0.0775, headHex: "9/16\"",  proofGrade5: 6_580,  proofGrade8: 9_300),
        ImperialBoltData(id: "7/16", size: "7/16\"", tpiUNC: 14, tensileArea: 0.1063, headHex: "5/8\"",   proofGrade5: 9_030,  proofGrade8: 12_750),
        ImperialBoltData(id: "1/2",  size: "1/2\"",  tpiUNC: 13, tensileArea: 0.1419, headHex: "3/4\"",   proofGrade5: 12_060, proofGrade8: 17_020),
        ImperialBoltData(id: "9/16", size: "9/16\"", tpiUNC: 12, tensileArea: 0.182,  headHex: "13/16\"", proofGrade5: 15_470, proofGrade8: 21_840),
        ImperialBoltData(id: "5/8",  size: "5/8\"",  tpiUNC: 11, tensileArea: 0.226,  headHex: "15/16\"", proofGrade5: 19_200, proofGrade8: 27_100),
        ImperialBoltData(id: "3/4",  size: "3/4\"",  tpiUNC: 10, tensileArea: 0.334,  headHex: "1-1/8\"", proofGrade5: 28_400, proofGrade8: 40_100),
        ImperialBoltData(id: "7/8",  size: "7/8\"",  tpiUNC: 9,  tensileArea: 0.462,  headHex: "1-5/16\"",proofGrade5: 39_250, proofGrade8: 55_400),
        ImperialBoltData(id: "1",    size: "1\"",    tpiUNC: 8,  tensileArea: 0.606,  headHex: "1-1/2\"", proofGrade5: 51_500, proofGrade8: 72_700),
    ]
    
    var body: some View {
        List {
            ForEach(bolts) { bolt in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(bolt.size)
                            .font(.headline).foregroundColor(.orange)
                        Spacer()
                        Text("UNC \(bolt.tpiUNC) TPI")
                            .font(.caption).foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 16) {
                        boltDetail(label: "Tensile Area", value: "\(String(format: "%.4f", bolt.tensileArea)) in²")
                        boltDetail(label: "Head (AF)", value: bolt.headHex)
                    }
                    
                    HStack(spacing: 16) {
                        boltDetail(label: "Proof Gr.5", value: "\(bolt.proofGrade5.formatted()) lbs")
                        boltDetail(label: "Proof Gr.8", value: "\(bolt.proofGrade8.formatted()) lbs")
                    }
                }
                .padding(.vertical, 4)
                .listRowBackground(Color(white: 0.15))
            }
        }
        .navigationTitle("SAE Imperial Bolts")
        .preferredColorScheme(.dark)
    }
    
    private func boltDetail(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundColor(.gray)
            Text(value).font(.caption).fontWeight(.bold).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - ISO 286 Fit Calculator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ISOFitCalculatorView: View {
    @State private var diameter: String = "50"
    @State private var holeSymbol: String = "H7"
    @State private var shaftSymbol: String = "g6"
    
    let holeOptions  = ["H7", "H8"]
    let shaftOptions = ["g6", "f7", "n6", "p6"]
    
    var holeDeviation: FitDeviation? {
        ISOFitsCalculator.getDeviation(symbol: holeSymbol, dimension: Double(diameter) ?? 50)
    }
    var shaftDeviation: FitDeviation? {
        ISOFitsCalculator.getDeviation(symbol: shaftSymbol, dimension: Double(diameter) ?? 50)
    }
    var fitType: FitType? {
        guard let h = holeDeviation, let s = shaftDeviation else { return nil }
        return ISOFitsCalculator.detectFitType(hole: h, shaft: s)
    }
    
    var body: some View {
        Form {
            Section("Nominal Dimension") {
                HStack {
                    Text("Diameter").foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        TextField("50", text: $diameter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90)
                        Text("mm").font(.caption).foregroundColor(.gray)
                    }
                }
            }
            
            Section("Tolerance Selection") {
                Picker("Hole Tolerance", selection: $holeSymbol) {
                    ForEach(holeOptions, id: \.self) { Text($0) }
                }
                Picker("Shaft Tolerance", selection: $shaftSymbol) {
                    ForEach(shaftOptions, id: \.self) { Text($0) }
                }
            }
            
            if let hole = holeDeviation, let shaft = shaftDeviation, let fit = fitType {
                Section("Deviations (µm)") {
                    HStack {
                        Text("Hole (\(holeSymbol))").foregroundColor(.gray)
                        Spacer()
                        Text("+\(String(format: "%.1f", hole.lower)) / +\(String(format: "%.1f", hole.upper))")
                            .fontWeight(.bold).foregroundColor(.cyan)
                    }
                    HStack {
                        Text("Shaft (\(shaftSymbol))").foregroundColor(.gray)
                        Spacer()
                        Text("\(String(format: "%.1f", shaft.lower)) / \(String(format: "%.1f", shaft.upper))")
                            .fontWeight(.bold).foregroundColor(.orange)
                    }
                }
                
                Section("Fit Analysis") {
                    let maxClearance = hole.upper - shaft.lower
                    let minClearance = hole.lower - shaft.upper
                    
                    HStack {
                        Text("Max Clearance").foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.1f µm", maxClearance)).fontWeight(.bold)
                    }
                    HStack {
                        Text("Min Clearance").foregroundColor(.gray)
                        Spacer()
                        Text(String(format: "%.1f µm", minClearance)).fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Fit Type")
                        Spacer()
                        Text(fit.rawValue)
                            .fontWeight(.black)
                            .foregroundColor(fitColor(fit))
                    }
                }
            }
        }
        .navigationTitle("ISO 286 Fits")
        .preferredColorScheme(.dark)
    }
    
    private func fitColor(_ fit: FitType) -> Color {
        switch fit {
        case .clearance: return .green
        case .transition: return .yellow
        case .interference: return .red
        }
    }
}

struct MaterialDetailView: View {
    let material: IndustrialMaterial
    
    var body: some View {
        List {
            Section(L10n.physicalProperties) {
                propertyRow(label: L10n.density, value: "\(material.density) g/cm³")
                if let melt = material.meltTemp {
                    propertyRow(label: L10n.meltPoint, value: "\(melt) °C")
                }
                if let e = material.elasticModulus {
                    propertyRow(label: L10n.elasticModulus, value: "\(e) GPa")
                }
            }
            
            if let shrinkage = material.shrinkage {
                Section(L10n.processing) {
                    propertyRow(label: L10n.shrinkage, value: "\(shrinkage.min) - \(shrinkage.max) %")
                    if let diff = material.thermalDiffusivity {
                        propertyRow(label: L10n.thermalDiffusivity, value: "\(diff) mm²/s")
                    }
                }
            }
        }
        .navigationTitle(material.name)
        .preferredColorScheme(.dark)
    }
    
    private func propertyRow(label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).fontWeight(.bold).foregroundColor(.orange)
        }
    }
}

#Preview {
    LibraryView()
}
