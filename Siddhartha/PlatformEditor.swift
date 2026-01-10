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
        MacMarkdownEditor(
            text: $sheet.content,
            selectedRange: $selectedRange,
            onTextChange: { _ in onTextChange() }
        )
        #else
        // NOW USING THE SMART EDITOR ON iOS TOO
        iOSMarkdownEditor(
            text: $sheet.content,
            selectedRange: $selectedRange,
            onTextChange: { onTextChange() }
        )
        // Add a little padding for the iOS touch targets
        .padding(.horizontal, 4)
        #endif
    }
}
