// ──────────────────────────────────────────────
// ShareSheet.swift
// Factory Pocket Pro
//
// SwiftUI wrapper for UIActivityViewController
// Enables sharing of files and content.
// ──────────────────────────────────────────────

import SwiftUI

/// A SwiftUI wrapper for UIActivityViewController that enables sharing
/// of URLs, files, and other shareable content.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
