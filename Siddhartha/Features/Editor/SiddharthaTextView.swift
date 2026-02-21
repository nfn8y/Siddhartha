//
//  SiddharthaTextView.swift
//  Siddhartha
//

#if os(macOS)
import AppKit
import SwiftUI

class SiddharthaTextView: NSTextView {
    
    // We need a way to communicate the changes back to SwiftUI.
    var onStyleToggle: ((MarkdownStyler.StylingResult) -> Void)?
    
    // These methods are part of the NSResponder action chain.
    // They don't need 'override'.
    @objc func toggleBold(_ sender: Any?) {
        let result = MarkdownStyler.toggleStyle(.bold, for: self.string, in: self.selectedRange())
        onStyleToggle?(result)
    }
    
    @objc func toggleItalic(_ sender: Any?) {
        let result = MarkdownStyler.toggleStyle(.italic, for: self.string, in: self.selectedRange())
        onStyleToggle?(result)
    }
    
    @objc func toggleUnderline(_ sender: Any?) {
        let result = MarkdownStyler.toggleStyle(.underline, for: self.string, in: self.selectedRange())
        onStyleToggle?(result)
    }
    
    @objc func toggleStrikethrough(_ sender: Any?) {
        let result = MarkdownStyler.toggleStyle(.strikethrough, for: self.string, in: self.selectedRange())
        onStyleToggle?(result)
    }
}
#endif
