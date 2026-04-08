// ──────────────────────────────────────────────
// HistoryManager.swift
// Factory Pocket Pro
//
// Manages calculation history and favorites
// using SwiftData persistence.
// ──────────────────────────────────────────────

import SwiftUI
import SwiftData

@MainActor
@Observable
final class HistoryManager {
    
    static let shared = HistoryManager()
    
    var modelContainer: ModelContainer?
    
    private init() {
        do {
            let schema = Schema([CalculationRecord.self, FavoriteCalculator.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Calculation History
    
    /// Save a calculation to history.
    @discardableResult
    func saveCalculation(
        calculatorName: String,
        category: String,
        inputs: [String: String],
        results: [String: String],
        unitSystem: String,
        note: String = ""
    ) -> CalculationRecord? {
        guard let container = modelContainer else { return nil }
        let record = CalculationRecord(
            calculatorName: calculatorName,
            category: category,
            inputs: inputs,
            results: results,
            unitSystem: unitSystem,
            note: note
        )
        let context = container.mainContext
        context.insert(record)
        
        // Keep only last 100 records
        pruneOldRecords(context: context)
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        return record
    }
    
    /// Fetch all records, most recent first.
    func fetchHistory() -> [CalculationRecord] {
        guard let container = modelContainer else { return [] }
        let descriptor = FetchDescriptor<CalculationRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }
    
    /// Delete a specific record.
    func deleteRecord(_ record: CalculationRecord) {
        guard let container = modelContainer else { return }
        container.mainContext.delete(record)
    }
    
    /// Clear all history.
    func clearHistory() {
        guard let container = modelContainer else { return }
        let context = container.mainContext
        let all = fetchHistory()
        for r in all { context.delete(r) }
    }
    
    private func pruneOldRecords(context: ModelContext) {
        let descriptor = FetchDescriptor<CalculationRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        guard let records = try? context.fetch(descriptor), records.count > 100 else { return }
        for record in records.dropFirst(100) {
            context.delete(record)
        }
    }
    
    // MARK: - Favorites
    
    /// Check if a calculator is favorited.
    func isFavorite(_ calculatorName: String) -> Bool {
        guard let container = modelContainer else { return false }
        let descriptor = FetchDescriptor<FavoriteCalculator>()
        let all = (try? container.mainContext.fetch(descriptor)) ?? []
        return all.contains { $0.calculatorName == calculatorName }
    }
    
    /// Toggle favorite status.
    func toggleFavorite(calculatorName: String, category: String, icon: String, color: String = "orange") {
        guard let container = modelContainer else { return }
        let context = container.mainContext
        let descriptor = FetchDescriptor<FavoriteCalculator>()
        let all = (try? context.fetch(descriptor)) ?? []
        
        if let existing = all.first(where: { $0.calculatorName == calculatorName }) {
            context.delete(existing)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            let fav = FavoriteCalculator(calculatorName: calculatorName, category: category, icon: icon, color: color)
            context.insert(fav)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    /// Fetch all favorites.
    func fetchFavorites() -> [FavoriteCalculator] {
        guard let container = modelContainer else { return [] }
        let descriptor = FetchDescriptor<FavoriteCalculator>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        return (try? container.mainContext.fetch(descriptor)) ?? []
    }
}
