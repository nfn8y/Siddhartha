//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI

struct EditorView: View {
    @Binding var sheet: Sheet?
    
    // State for the underlying editor's selection range
    @State private var selectedRange = NSRange(location: 0, length: 0)
    
    // ViewModel for handling business logic
    let viewModel: EditorViewModel
    
    var body: some View {
        Group {
            if let sheet = sheet {
                // Use our custom, platform-specific editor instead of the basic one
                PlatformEditor(sheet: sheet, selectedRange: $selectedRange) {
                    // This is the onTextChange closure
                    // Simple logic: first line is title
                    let lines = sheet.content.components(separatedBy: .newlines)
                    if let firstLine = lines.first {
                        // Avoid modifying the title if it's the same, to prevent extra churn
                        let newTitle = String(firstLine.prefix(50))
                        if sheet.title != newTitle {
                            sheet.title = newTitle
                        }
                    }
                }
                .accessibilityIdentifier(AccessibilityIDs.Editor.mainText)
            } else {
                ContentUnavailableView("Select a Sheet", systemImage: "doc.text")
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Export as PDF", systemImage: "square.and.arrow.up") {
                    viewModel.exportAsPDF(sheet: sheet)
                }
                .disabled(sheet == nil)
            }
        }
    }
}
