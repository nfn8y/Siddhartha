//
//  PlatformEditor.swift
//  Siddhartha
//

import SwiftUI

struct PlatformEditor: View {
    @Bindable var sheet: Sheet
    @Binding var selectedRange: NSRange
    var onTextChange: (String) -> Void
    
    var body: some View {
        #if os(macOS)
        MacRichTextEditor(
            sheet: sheet,
            attributedData: $sheet.attributedContent,
            selectedRange: $selectedRange,
            onTextChange: onTextChange
        )
        #else
        iOSRichTextEditor(
            attributedData: $sheet.attributedContent,
            selectedRange: $selectedRange,
            onTextChange: onTextChange
        )
        // Add a little padding for the iOS touch targets
        .padding(.horizontal, 4)
        #endif
    }
}
