//
//  SiddharthaTextView.swift
//  Siddhartha
//

#if os(macOS)
import AppKit
import SwiftUI

class SiddharthaTextView: NSTextView {
    
    // We need a way to communicate the changes back to SwiftUI.
    // A closure is a clean way to do this.
    var onStyleToggle: ((MarkdownStyler.StylingResult) -> Void)?
    
    func toggleBold(_ sender: Any?) {
        let result = MarkdownStyler.toggleStyle(.bold, for: self.string, in: self.selectedRange)
        onStyleToggle?(result)
    }
    
    func toggleItalic(_ sender: Any?) {
        let result = MarkdownStyler.toggleStyle(.italic, for: self.string, in: self.selectedRange)
        onStyleToggle?(result)
    }
    
    // Note: There's no default `toggleStrikethrough`. We can add it to the responder chain manually if needed,
    // but for now we'll just expose a function. We'll wire it up with a custom menu item.
    @objc func toggleStrikethrough() {
        let result = MarkdownStyler.toggleStyle(.strikethrough, for: self.string, in: self.selectedRange)
        onStyleToggle?(result)
    }
    
    // `toggleUnderline` is a standard responder action, like bold and italic.
    func toggleUnderline(_ sender: Any?) {
        let result = MarkdownStyler.toggleStyle(.underline, for: self.string, in: self.selectedRange)
        onStyleToggle?(result)
    }
}
#endif
