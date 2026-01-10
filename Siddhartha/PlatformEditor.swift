//
//  PlatformEditor.swift
//  Siddhartha
//

import SwiftUI

struct PlatformEditor: View {
    @Bindable var sheet: Sheet
    @Binding var selectedRange: NSRange
    var onTextChange: () -> Void
    
    var body: some View {
        #if os(macOS)
        // Load the Mac-Specific powerful editor
        MacMarkdownEditor(text: $sheet.content, selectedRange: $selectedRange) { _ in
            onTextChange()
        }
        #else
        // Load the iOS standard editor
        TextEditor(text: $sheet.content)
            .onChange(of: sheet.content) {
                onTextChange()
            }
            .scrollContentBackground(.hidden)
        #endif
    }
}
