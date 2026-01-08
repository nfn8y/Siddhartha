//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI
import UniformTypeIdentifiers // <--- THIS IS THE FIX

struct EditorView: View {
    @Bindable var sheet: Sheet
    @State private var isExporting = false

    var body: some View {
        VStack(spacing: 0) {
            // Title
            TextField("Chapter Title", text: $sheet.title)
                .font(Theme.titleFont)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            Divider().opacity(0.5)
            
            // Editor
            ZStack(alignment: .bottomTrailing) {
                #if os(macOS)
                MacMarkdownEditor(text: $sheet.content) { _ in
                    sheet.lastModified = Date()
                }
                .padding(.top, 8)
                #else
                TextEditor(text: $sheet.content)
                    .onChange(of: sheet.content) { sheet.lastModified = Date() }
                    .font(Theme.writingFont)
                    .scrollContentBackground(.hidden)
                    .padding()
                #endif
                
                // Word Count
                Text("\(wordCount) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .background(Theme.paperBackground)
        // --- EXPORT BUTTON ---
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    exportPDF()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Export to PDF")
            }
        }
    }
    
    private var wordCount: Int {
        if sheet.content.isEmpty { return 0 }
        return sheet.content.split { $0.isWhitespace || $0.isNewline }.count
    }
    
    // --- EXPORT LOGIC ---
    // --- EXPORT LOGIC ---
    private func exportPDF() {
        // 1. Generate the PDF
        guard let url = PDFCreator.createSimplePDF(title: sheet.title, content: sheet.content) else {
            print("Could not generate PDF")
            return
        }

        // 2. Open Save Panel
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Export Note"
        savePanel.nameFieldStringValue = sheet.title.isEmpty ? "Untitled" : sheet.title

        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                do {
                    // If a file already exists there, delete it first to avoid crash
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }
                    try FileManager.default.copyItem(at: url, to: targetURL)
                } catch {
                    print("Export failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
