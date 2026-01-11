//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Bindable var sheet: Sheet
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    
    // Inject Services
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
                // Platform-Agnostic Editor (Handles iOS/Mac logic internally)
                PlatformEditor(
                    sheet: sheet,
                    selectedRange: $selectedRange,
                    onTextChange: { sheet.lastModified = Date() }
                )
                // Add padding for iOS touch targets vs Mac precision
                .padding(Platform.current.isMac ? 8 : 4)
                
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
            // On iOS, we put these above the keyboard. On Mac, in the main toolbar.
#if os(iOS)
            ToolbarItemGroup(placement: .keyboard) {
                formattingButtons
            }
#else
            ToolbarItemGroup(placement: .primaryAction) {
                formattingButtons
            }
#endif
            
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
    
    // --- UI COMPONENTS ---
    
    // Extracted buttons so we can reuse them in different toolbar placements
    private var formattingButtons: some View {
        Group {
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
            
            // Underline (<u>...</u>)
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
            
#if os(iOS)
            Spacer() // Push "Done" to the right on iOS keyboard toolbar
            Button("Done") {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
#endif
        }
    }
    
    // --- LOGIC HANDLERS ---
    
    private func applyFormat(start: String, end: String? = nil) {
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

// Helper for cleaner code
extension PlatformProvider {
    var isMac: Bool {
#if os(macOS)
        return true
#else
        return false
#endif
    }
}
