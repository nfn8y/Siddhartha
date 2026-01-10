//
//  EditorView.swift
//  Siddhartha
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Bindable var sheet: Sheet
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
                // --- THE CLEAN SWAP ---
                PlatformEditor(
                    sheet: sheet,
                    selectedRange: $selectedRange,
                    onTextChange: { sheet.lastModified = Date() }
                )
                .padding(8)
                
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
            ToolbarItem(placement: .primaryAction) {
                // We use our Platform flag to decide if buttons should exist
                if Platform.current.supportsWindowedExport {
                    HStack {
                        Button(action: insertImageMac) {
                            Image(systemName: "photo")
                        }
                        Button(action: exportPDFMac) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
    }
    
    // We still have to keep these functions here for now because they trigger UI panels,
    // but at least they are isolated.
    private func insertImageMac() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            if response == .OK, let url = panel.url {
                 // ... logic ...
            }
        }
        #endif
    }

    private func exportPDFMac() {
        #if os(macOS)
        // ... logic ...
        #endif
    }
}
