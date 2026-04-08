// ──────────────────────────────────────────────
// PDFReportGenerator.swift
// Factory Pocket Pro
//
// Generates professional PDF reports from
// calculation results. Uses UIGraphicsPDFRenderer.
// ──────────────────────────────────────────────

import UIKit
import SwiftUI

struct PDFReportGenerator {
    
    // MARK: - Premium Check
    
    /// Check if PDF generation is allowed.
    /// Always returns true (PDF export is always available).
    static func canGeneratePDF() -> Bool {
        return true
    }
    
    // MARK: - Public API
    
    /// Generate a PDF for a calculation, returns the file URL.
    static func generateReport(
        calculatorName: String,
        category: String,
        inputs: [String: String],
        results: [String: String],
        unitSystem: String,
        note: String = ""
    ) -> URL? {
        let pdfData = renderPDF(
            calculatorName: calculatorName,
            category: category,
            inputs: inputs,
            results: results,
            unitSystem: unitSystem,
            note: note
        )
        
        let filename = "FPP_\(calculatorName.replacingOccurrences(of: " ", with: "_"))_\(dateString()).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("PDF write error: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Rendering
    
    private static func renderPDF(
        calculatorName: String,
        category: String,
        inputs: [String: String],
        results: [String: String],
        unitSystem: String,
        note: String
    ) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Factory Pocket Pro",
            kCGPDFContextTitle: calculatorName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageSize = CGSize(width: 612, height: 792)  // Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let margins = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
            let contentRect = CGRect(
                x: margins.left,
                y: margins.top,
                width: pageSize.width - margins.left - margins.right,
                height: pageSize.height - margins.top - margins.bottom
            )
            
            var yPosition: CGFloat = contentRect.minY
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.alignment = .center
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .paragraphStyle: titleStyle,
                .foregroundColor: UIColor.black
            ]
            let titleRect = CGRect(x: contentRect.minX, y: yPosition, width: contentRect.width, height: 40)
            NSAttributedString(string: calculatorName, attributes: titleAttrs).draw(in: titleRect)
            yPosition += 50
            
            // Category & Date
            let metaFont = UIFont.systemFont(ofSize: 10)
            let metaAttrs: [NSAttributedString.Key: Any] = [
                .font: metaFont,
                .foregroundColor: UIColor.gray
            ]
            let metaText = "\(category) • \(unitSystem) • \(dateString())"
            let metaRect = CGRect(x: contentRect.minX, y: yPosition, width: contentRect.width, height: 20)
            NSAttributedString(string: metaText, attributes: metaAttrs).draw(in: metaRect)
            yPosition += 25
            
            // Inputs
            if !inputs.isEmpty {
                let sectionFont = UIFont.boldSystemFont(ofSize: 12)
                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: sectionFont,
                    .foregroundColor: UIColor.darkGray
                ]
                NSAttributedString(string: "Inputs", attributes: sectionAttrs).draw(at: CGPoint(x: contentRect.minX, y: yPosition))
                yPosition += 20
                
                let labelFont = UIFont.systemFont(ofSize: 10)
                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: labelFont,
                    .foregroundColor: UIColor.black
                ]
                
                for (key, value) in inputs.sorted(by: { $0.key < $1.key }) {
                    let text = "\(key): \(value)"
                    let size = text.boundingRect(with: CGSize(width: contentRect.width, height: .infinity), options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil)
                    NSAttributedString(string: text, attributes: labelAttrs).draw(in: CGRect(x: contentRect.minX + 10, y: yPosition, width: contentRect.width - 10, height: size.height))
                    yPosition += size.height + 5
                }
                
                yPosition += 10
            }
            
            // Results
            if !results.isEmpty {
                let sectionFont = UIFont.boldSystemFont(ofSize: 12)
                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: sectionFont,
                    .foregroundColor: UIColor.darkGray
                ]
                NSAttributedString(string: "Results", attributes: sectionAttrs).draw(at: CGPoint(x: contentRect.minX, y: yPosition))
                yPosition += 20
                
                let labelFont = UIFont.systemFont(ofSize: 10)
                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: labelFont,
                    .foregroundColor: UIColor.black
                ]
                
                for (key, value) in results.sorted(by: { $0.key < $1.key }) {
                    let text = "\(key): \(value)"
                    let size = text.boundingRect(with: CGSize(width: contentRect.width, height: .infinity), options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil)
                    NSAttributedString(string: text, attributes: labelAttrs).draw(in: CGRect(x: contentRect.minX + 10, y: yPosition, width: contentRect.width - 10, height: size.height))
                    yPosition += size.height + 5
                }
                
                yPosition += 10
            }
            
            // Note
            if !note.isEmpty {
                let noteFont = UIFont.italicSystemFont(ofSize: 9)
                let noteAttrs: [NSAttributedString.Key: Any] = [
                    .font: noteFont,
                    .foregroundColor: UIColor.gray
                ]
                let noteRect = CGRect(x: contentRect.minX, y: yPosition, width: contentRect.width, height: 40)
                NSAttributedString(string: note, attributes: noteAttrs).draw(in: noteRect)
            }
            
            // Footer
            let footerFont = UIFont.systemFont(ofSize: 8)
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: footerFont,
                .foregroundColor: UIColor.lightGray
            ]
            let footer = "Generated by Factory Pocket Pro"
            NSAttributedString(string: footer, attributes: footerAttrs).draw(at: CGPoint(x: contentRect.minX, y: pageSize.height - 30))
        }
        
        return data
    }
    
    private static func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
