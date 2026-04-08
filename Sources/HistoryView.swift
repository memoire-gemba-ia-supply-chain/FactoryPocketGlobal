// ──────────────────────────────────────────────
// HistoryView.swift
// Factory Pocket Pro
//
// Displays calculation history with search,
// category filtering, and swipe-to-delete.
// ──────────────────────────────────────────────

import SwiftUI

struct HistoryView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(HistoryManager.self) private var historyManager
    
    @State private var records: [CalculationRecord] = []
    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil    
    var categories: [String] {
        let cats = Set(records.map { $0.category })
        return cats.sorted()
    }
    
    var filteredRecords: [CalculationRecord] {
        var result = records
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.calculatorName.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search calculations")
            .toolbar {
                if !records.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .destructive) {
                            historyManager.clearHistory()
                            withAnimation { records = [] }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .onAppear {
                records = historyManager.fetchHistory()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No Calculations Yet")                .font(.title3.weight(.semibold))
            Text("Your calculation history will appear here.\nResults are saved automatically.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - History List
    
    private var historyList: some View {
        List {
            if !categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(categories, id: \.self) { cat in
                            FilterChip(title: cat, isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }            
            ForEach(filteredRecords, id: \.id) { record in
                HistoryRow(record: record)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            historyManager.deleteRecord(record)
                            withAnimation { records = historyManager.fetchHistory() }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - History Row

private struct HistoryRow: View {
    let record: CalculationRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                let icon = CalculatorRegistry.iconForName(record.calculatorName)
                let color = CalculatorRegistry.colorForName(record.calculatorName)
                Image(systemName: icon)
                    .foregroundColor(color)                    .font(.headline)
                Text(record.calculatorName)
                    .font(.headline)
                Spacer()
                Text(record.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            
            // Show top 2 results
            let results = record.resultsDictionary
            let topResults = Array(results.prefix(2))
            if !topResults.isEmpty {
                HStack(spacing: 12) {
                    ForEach(topResults, id: \.key) { key, value in
                        HStack(spacing: 4) {
                            Text(key + ":")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(value)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.orange)
                        }
                    }
                }
            }            
            Text(record.createdAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HistoryView()
        .environment(ThemeManager.shared)
        .environment(HistoryManager.shared)
}