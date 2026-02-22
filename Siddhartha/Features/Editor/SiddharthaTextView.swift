//
//  SiddharthaTextView.swift
//  Siddhartha
//

#if os(macOS)
import AppKit
import SwiftUI

class SiddharthaTextView: NSTextView {
    
    // We use NSApp.sendAction to trigger standard rich text formatting.
    // This is more robust than calling methods directly as it correctly 
    // interacts with the NSFontManager and the responder chain.
    
    @objc func toggleBold(_ sender: Any?) {
        NSApp.sendAction(#selector(NSFontManager.addFontTrait(_:)), to: nil, from: sender)
    }
    
    @objc func toggleItalic(_ sender: Any?) {
        NSApp.sendAction(#selector(NSFontManager.addFontTrait(_:)), to: nil, from: sender)
    }
    
    @objc func toggleUnderline(_ sender: Any?) {
        NSApp.sendAction(#selector(NSTextView.underline(_:)), to: nil, from: sender)
    }
    
    @objc func toggleStrikethrough(_ sender: Any?) {
        let range = self.selectedRange()
        if range.length > 0 {
            let currentAttributes = self.textStorage?.attributes(at: range.location, effectiveRange: nil)
            let isStruck = (currentAttributes?[.strikethroughStyle] as? NSNumber)?.intValue ?? 0
            let newValue = isStruck == 0 ? NSUnderlineStyle.single.rawValue : 0
            self.textStorage?.addAttribute(.strikethroughStyle, value: newValue, range: range)
            self.didChangeText()
        }
    }
}
#endif
