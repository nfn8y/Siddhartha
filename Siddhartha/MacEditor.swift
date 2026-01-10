//
//  MacEditor.swift
//  Siddhartha
//

#if os(macOS)
import SwiftUI
import AppKit

struct MacMarkdownEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var selectedRange: NSRange
    var onTextChange: (String) -> Void
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        let textView = NSTextView()
        textView.isRichText = false
        textView.allowsUndo = true
        
        // Use Georgia to match your Theme (Handles Bold/Italic much better than Mono)
        textView.font = NSFont(name: "Georgia", size: 18) ?? NSFont.systemFont(ofSize: 18)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        
        // Layout Settings
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        
        textView.string = text
        
        scrollView.documentView = textView
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            context.coordinator.highlightSyntax(in: textView) // Force highlight on load
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacMarkdownEditor
        
        init(_ parent: MacMarkdownEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.onTextChange(textView.string)
            highlightSyntax(in: textView)
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.selectedRange = textView.selectedRange
        }
        
        func highlightSyntax(in textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            let fullRange = NSRange(location: 0, length: textStorage.length)
            let text = textView.string
            
            // 1. Reset to Base Style (Georgia 18)
            textStorage.removeAttribute(.foregroundColor, range: fullRange)
            textStorage.removeAttribute(.font, range: fullRange)
            textStorage.removeAttribute(.strikethroughStyle, range: fullRange)
            textStorage.removeAttribute(.underlineStyle, range: fullRange)
            
            let baseFont = NSFont(name: "Georgia", size: 18) ?? NSFont.systemFont(ofSize: 18)
            textStorage.addAttribute(.font, value: baseFont, range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
            
            // 2. Define Patterns with "Negative Lookarounds"
            // This prevents "_" from matching inside "__"
            
            let patterns: [(pattern: String, traits: NSFontDescriptor.SymbolicTraits?, color: NSColor?, underline: Bool, strike: Bool)] = [
                // Headings
                ("^#{1,6}\\s.*$", .bold, .systemBlue, false, false),
                
                // Underline (<u>text</u>) - Simple and robust
                ("<u>(.+?)</u>", nil, nil, true, false),
                
                // Bold (*text*) - Keep the checks to avoid matching inside other things
                ("(?<!\\*)\\*(.+?)\\*(?!\\*)", .bold, nil, false, false),
                
                // Italic (_text_) - Now safe from collision
                ("_(.+?)_", .italic, nil, false, false),
                
                // Strikethrough (-text-)
                ("-(.+?)-", nil, .secondaryLabelColor, false, true),
                
                // Image Tags
                ("!\\[.*?\\]\\(.*?\\)", nil, .systemPurple, false, false)
            ]
            
            // 3. Apply Regex
            for style in patterns {
                let regex = try! NSRegularExpression(pattern: style.pattern, options: [.anchorsMatchLines])
                
                regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        // Apply Font Traits (Bold/Italic)
                        if let traits = style.traits {
                            let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits)
                            // Fallback to system bold if Georgia bold fails (rare)
                            let newFont = NSFont(descriptor: descriptor, size: 18) ?? NSFont.boldSystemFont(ofSize: 18)
                            textStorage.addAttribute(.font, value: newFont, range: range)
                        }
                        
                        // Apply Color
                        if let color = style.color {
                            textStorage.addAttribute(.foregroundColor, value: color, range: range)
                        }
                        
                        // Apply Strikethrough
                        if style.strike {
                            textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                        }
                        
                        // Apply Underline
                        if style.underline {
                            textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                        }
                    }
                }
            }
        }
    }
}
#endif
