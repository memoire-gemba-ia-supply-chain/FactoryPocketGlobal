// ──────────────────────────────────────────────
// CalculatorToolbar.swift
// Factory Pocket Pro
//
// Premium reusable toolbar for all calculators.
// Adds Save, Favorite, and PDF Export actions
// with polished glassmorphism toast.
// ──────────────────────────────────────────────

import SwiftUI

/// Reusable toolbar that adds History Save, Favorite Toggle and PDF Export to any calculator view.
struct CalculatorToolbar: ViewModifier {
    let calculatorId: String
    let calculatorName: String
    let category: String
    let icon: String
    let colorName: String
    let unitSystem: String
    
    /// Closures to get current inputs/results from the calculator.
    let getInputs: () -> [String: String]
    let getResults: () -> [String: String]
    
    @State private var historyManager = HistoryManager.shared
    @State private var isFavorite = false
    @State private var showSavedToast = false
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @State private var showNoteAlert = false
    @State private var noteText = ""
    @State private var starScale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Save to history
                    Button {
                        saveCalculation()
                    } label: {
                        Image(systemName: "square.and.arrow.down.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
                    }
                    
                    // Export PDF
                    Button {
                        exportPDF()
                    } label: {
                        Image(systemName: "doc.richtext.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                    }
                    
                    // Toggle Favorite
                    Button {
                        toggleFav()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(
                                isFavorite
                                ? AnyShapeStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                : AnyShapeStyle(Color.gray.opacity(0.6))
                            )
                            .scaleEffect(starScale)
                    }
                }
            }
            .overlay(alignment: .top) {
                if showSavedToast {
                    savedToast
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        .zIndex(100)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                }
            }
            .onAppear {
                isFavorite = historyManager.isFavorite(calculatorName)
            }
    }
    
    // MARK: - Actions
    
    private func saveCalculation() {
        let inputs = getInputs()
        let results = getResults()
        
        historyManager.saveCalculation(
            calculatorName: calculatorName,
            category: category,
            inputs: inputs,
            results: results,
            unitSystem: unitSystem,
            note: noteText
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showSavedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) { showSavedToast = false }
        }
    }
    
    private func exportPDF() {
        let inputs = getInputs()
        let results = getResults()
        
        if let url = PDFReportGenerator.generateReport(
            calculatorName: calculatorName,
            category: category,
            inputs: inputs,
            results: results,
            unitSystem: unitSystem
        ) {
            shareURL = url
            showShareSheet = true
        }
    }
    
    private func toggleFav() {
        historyManager.toggleFavorite(
            calculatorName: calculatorName,
            category: category,
            icon: icon,
            color: colorName
        )
        
        // Bounce animation
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
            starScale = 1.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                starScale = 1.0
                isFavorite.toggle()
            }
        }
    }
    
    // MARK: - Saved Toast (Glassmorphism)
    
    private var savedToast: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(.caption).fontWeight(.black)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(L10n.isFrench ? "Sauvegardé !" : "Saved!")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(.white)
                Text(calculatorName)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .green.opacity(0.15), radius: 20, y: 10)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        .padding(.top, 10)
    }
}

// MARK: - View Extension

extension View {
    /// Attach the standard calculator toolbar (save, export, favorite).
    func calculatorToolbar(
        id: String,
        name: String,
        category: String,
        icon: String,
        colorName: String = "orange",
        unitSystem: String,
        inputs: @escaping () -> [String: String],
        results: @escaping () -> [String: String]
    ) -> some View {
        modifier(CalculatorToolbar(
            calculatorId: id,
            calculatorName: name,
            category: category,
            icon: icon,
            colorName: colorName,
            unitSystem: unitSystem,
            getInputs: inputs,
            getResults: results
        ))
    }
}
