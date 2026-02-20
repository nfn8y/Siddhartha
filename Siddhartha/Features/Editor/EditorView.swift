//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI

struct EditorView: View {
    @Binding var sheet: Sheet?
    @Environment(\.theme) private var theme
    
    // ViewModel for handling business logic
    let viewModel: EditorViewModel
    
    // Local state to handle text binding unwrapping safely
    @State private var text: String = ""
    
    var body: some View {
        Group {
            if let _ = sheet {
                TextEditor(text: $text)
                    .font(theme.uiFont)
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier(AccessibilityIDs.Editor.mainText)
                    .onChange(of: text) { _, newValue in
                        sheet?.content = newValue
                        // Simple logic: first line is title
                        let lines = newValue.components(separatedBy: .newlines)
                        if let firstLine = lines.first {
                            sheet?.title = String(firstLine.prefix(50)) // Limit title length
                        }
                    }
            } else {
                ContentUnavailableView("Select a Sheet", systemImage: "doc.text")
            }
        }
        .onAppear {
            if let sheet = sheet {
                text = sheet.content
            }
        }
        .onChange(of: sheet) { _, newSheet in
            if let newSheet = newSheet {
                text = newSheet.content
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
