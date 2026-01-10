//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Bindable var sheet: Sheet
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    
    // Inject Services (Dependency Injection)
    private let theme = Services.shared.theme
    private let actions = Services.shared.actions
    private let storage = Services.shared.storage
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Field
            TextField("Chapter Title", text: $sheet.title)
                .font(theme.titleFont)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            Divider().opacity(0.5)
            
            ZStack(alignment: .bottomTrailing) {
                // Platform-Specific Editor (Mac vs iOS logic hidden here)
                PlatformEditor(
                    sheet: sheet,
                    selectedRange: $selectedRange,
                    onTextChange: { sheet.lastModified = Date() }
                )
                .padding(8)
                
                // Word Count Overlay
                Text("\(sheet.wordCount) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .background(theme.paperBackground)
        .toolbar {
            // --- FORMATTING GROUP ---
            ToolbarItemGroup(placement: .primaryAction) {
                // Bold (*)
                Button { applyFormat(start: "*") } label: {
                    Image(systemName: "bold")
                }
                .help("Bold (*)")
                .keyboardShortcut("b", modifiers: .command)
                
                // Italic (_)
                Button { applyFormat(start: "_") } label: {
                    Image(systemName: "italic")
                }
                .help("Italic (_)")
                .keyboardShortcut("i", modifiers: .command)
                
                // Underline (<u>) - ASYMMETRIC WRAPPING
                Button { applyFormat(start: "<u>", end: "</u>") } label: {
                    Image(systemName: "underline")
                }
                .help("Underline (<u>)")
                .keyboardShortcut("u", modifiers: .command)
                
                // Strikethrough (-)
                Button { applyFormat(start: "-") } label: {
                    Image(systemName: "strikethrough")
                }
                .help("Strikethrough (-)")
                .keyboardShortcut("-", modifiers: .command)
            }
            
            // --- ACTIONS GROUP (Image / Export) ---
            ToolbarItemGroup(placement: .primaryAction) {
                if actions.supportsImagePicker {
                    Button(action: handleImagePick) {
                        Image(systemName: "photo")
                    }
                    .help("Insert Image")
                }
                
                if actions.supportsPDFExport {
                    Button(action: handleExport) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .help("Export PDF")
                }
            }
        }
    }
    
    // --- FORMATTING LOGIC ---
    private func applyFormat(start: String, end: String? = nil) {
        // If no specific end symbol is provided, use the start symbol (symmetric)
        let endSymbol = end ?? start
        
        let request = FormatManager.ToggleRequest(
            content: sheet.content,
            range: selectedRange,
            startSymbol: start,
            endSymbol: endSymbol
        )
        
        if let result = FormatManager.toggle(request) {
            sheet.content = result.newContent
            selectedRange = result.newRange
            sheet.lastModified = Date()
        }
    }
    
    // --- ACTION LOGIC ---
    private func handleImagePick() {
        actions.pickImage { image in
            guard let image = image,
                  let filename = storage.saveImage(image) else { return }
            
            // Insert Markdown Tag
            let markdown = "\n![Image](\(filename))\n"
            insertTextAtCursor(markdown)
        }
    }
    
    private func handleExport() {
        guard let url = storage.createPDF(title: sheet.title, content: sheet.content) else { return }
        actions.exportPDF(url: url, title: sheet.title)
    }
    
    private func insertTextAtCursor(_ text: String) {
        // Safety check
        if selectedRange.location <= sheet.content.count {
            let nsContent = sheet.content as NSString
            let newContent = nsContent.replacingCharacters(in: selectedRange, with: text)
            
            sheet.content = newContent
            sheet.lastModified = Date()
            
            // Move cursor to end of inserted text
            selectedRange = NSRange(location: selectedRange.location + text.count, length: 0)
        } else {
            // Fallback: Append to end
            sheet.content += text
        }
    }
}
