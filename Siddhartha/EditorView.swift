//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Bindable var sheet: Sheet
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    
    // Inject our services (Dependency Injection)
    private let theme = Services.shared.theme
    private let actions = Services.shared.actions
    private let storage = Services.shared.storage

    var body: some View {
        VStack(spacing: 0) {
            // Title
            TextField("Chapter Title", text: $sheet.title)
                .font(theme.titleFont) // Using Service
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            Divider().opacity(0.5)
            
            ZStack(alignment: .bottomTrailing) {
                // PlatformEditor still handles the specific View differences internally
                // (Views are harder to abstract than logic, but this is clean enough)
                PlatformEditor(
                    sheet: sheet,
                    selectedRange: $selectedRange,
                    onTextChange: { sheet.lastModified = Date() }
                )
                .padding(8)
                
                Text("\(sheet.wordCount) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .background(theme.paperBackground) // Using Service
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    if actions.supportsImagePicker {
                        Button(action: handleImagePick) {
                            Image(systemName: "photo")
                        }
                    }
                    
                    if actions.supportsPDFExport {
                        Button(action: handleExport) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
    }
    
    // --- PURE LOGIC HANDLERS ---
    
    private func handleImagePick() {
        actions.pickImage { image in
            guard let image = image,
                  let filename = storage.saveImage(image) else { return }
            
            let markdown = "\n![Image](\(filename))\n"
            insertTextAtCursor(markdown)
        }
    }
    
    private func handleExport() {
        guard let url = storage.createPDF(title: sheet.title, content: sheet.content) else { return }
        actions.exportPDF(url: url, title: sheet.title)
    }
    
    private func insertTextAtCursor(_ text: String) {
        // (Same helper logic as before)
        if selectedRange.location <= sheet.content.count {
            let nsContent = sheet.content as NSString
            let newContent = nsContent.replacingCharacters(in: selectedRange, with: text)
            sheet.content = newContent
            sheet.lastModified = Date()
            selectedRange = NSRange(location: selectedRange.location + text.count, length: 0)
        } else {
            sheet.content += text
        }
    }
}
