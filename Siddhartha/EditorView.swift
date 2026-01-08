//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Bindable var sheet: Sheet
    
    // Track cursor position so we know where to drop the image
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)

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
            
            ZStack(alignment: .bottomTrailing) {
                #if os(macOS)
                MacMarkdownEditor(text: $sheet.content, selectedRange: $selectedRange) { _ in
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
                Text("\(sheet.wordCount) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(.thinMaterial)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .background(Theme.paperBackground)
        .toolbar {
            // --- IMAGE BUTTON ---
            ToolbarItem(placement: .primaryAction) {
                Button(action: insertImage) {
                    Image(systemName: "photo")
                }
                .help("Insert Image")
            }
            
            // --- EXPORT BUTTON ---
            ToolbarItem(placement: .primaryAction) {
                Button(action: exportPDF) {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Export to PDF")
            }
        }
    }
    
    // --- IMAGE LOGIC ---
    private func insertImage() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                // 1. Load the image
                if let image = NSImage(contentsOf: url) {
                    // 2. Save it to our app's permanent storage
                    if let filename = ImageStorage.saveImage(image) {
                        // 3. Create the Markdown tag
                        let markdown = "\n![Image](\(filename))\n"
                        
                        // 4. Insert at cursor position
                        insertTextAtCursor(markdown)
                    }
                }
            }
        }
        #endif
    }
    
    private func insertTextAtCursor(_ text: String) {
        // Safety check: Ensure range is valid
        if selectedRange.location <= sheet.content.count {
            // Convert String to NSString for safe range replacement
            let nsContent = sheet.content as NSString
            let newContent = nsContent.replacingCharacters(in: selectedRange, with: text)
            
            // Update the sheet
            sheet.content = newContent
            sheet.lastModified = Date()
            
            // Move cursor after the insertion (Optional polish)
            selectedRange = NSRange(location: selectedRange.location + text.count, length: 0)
        } else {
            // Fallback: Append to end if cursor is lost
            sheet.content += text
        }
    }
    
    // --- EXPORT LOGIC ---
    private func exportPDF() {
        guard let url = PDFCreator.createSimplePDF(title: sheet.title, content: sheet.content) else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = sheet.title.isEmpty ? "Untitled" : sheet.title
        
        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                try? FileManager.default.copyItem(at: url, to: targetURL)
            }
        }
    }
}
