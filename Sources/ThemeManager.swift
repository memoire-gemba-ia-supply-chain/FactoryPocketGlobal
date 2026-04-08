import SwiftUI

@MainActor
@Observable
final class ThemeManager {
    static let shared = ThemeManager()
    
    enum ThemeMode: String, CaseIterable {
        case system
        case dark
        case light
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .dark: return "Dark"
            case .light: return "Light"
            }
        }
    }
    
    var selectedTheme: String {
        didSet { UserDefaults.standard.set(selectedTheme, forKey: "themeMode") }
    }
    
    private init() {
        self.selectedTheme = UserDefaults.standard.string(forKey: "themeMode") ?? "system"
    }
    
    var colorScheme: ColorScheme? {
        let mode = ThemeMode(rawValue: selectedTheme) ?? .system
        switch mode {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    var backgroundColor: Color {
        Color(.systemBackground)
    }
    
    var cardBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    var textPrimary: Color {
        Color(.label)
    }
    
    var textSecondary: Color {
        Color(.secondaryLabel)
    }
    
    var accent: Color {
        .orange
    }
}
