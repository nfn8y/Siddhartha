//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Bindable var sheet: Sheet
    
    // Track cursor (Only works on Mac for now)
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)

    var body: some View {
        VStack(spacing: 0) {
            // Title
            TextField("Chapter Title", text: $sheet.title)
                .font(Theme.titleFont) // Ensure Theme.swift handles fonts correctly!
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
                // --- iOS Editor ---
                TextEditor(text: $sheet.content)
                    .onChange(of: sheet.content) {
                        sheet.lastModified = Date()
                    }
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
        .background(Color.gray.opacity(0.1)) // Simple background fix
        .toolbar {
            // ONLY SHOW THESE BUTTONS ON MAC
            #if os(macOS)
            ToolbarItem(placement: .primaryAction) {
                Button(action: insertImage) {
                    Image(systemName: "photo")
                }
                .help("Insert Image")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: exportPDF) {
                    Image(systemName: "square.and.arrow.up")
                }
                .help("Export to PDF")
            }
            #endif
        }
    }
    
    // --- MAC ONLY LOGIC ---
    #if os(macOS)
    private func insertImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                if let image = NSImage(contentsOf: url) {
                    if let filename = ImageStorage.saveImage(image) {
                        let markdown = "\n![Image](\(filename))\n"
                        insertTextAtCursor(markdown)
                    }
                }
            }
        }
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
    #endif
}
