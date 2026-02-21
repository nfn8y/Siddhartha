//
//  MacEditor.swift
//  Siddhartha
//

#if os(macOS)
import SwiftUI
import AppKit

// A new command set for our custom Strikethrough action
struct StrikethroughCommands: Commands {
    var body: some Commands {
        CommandMenu("Format") {
            Button("Strikethrough") {
                // Find the first responder and ask it to perform our custom action
                NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(SiddharthaTextView.toggleStrikethrough), with: nil)
            }
            // We can assign a shortcut here if we want, e.g., .keyboardShortcut("-", modifiers: .command)
        }
    }
}

struct MacMarkdownEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var selectedRange: NSRange
    var onTextChange: (String) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        // Use our custom TextView subclass instead of the standard one
        let textView = SiddharthaTextView()
        
        // Wire up the callback
        textView.onStyleToggle = { result in
            self.text = result.newText
            self.selectedRange = result.newSelectedRange
            
            // After styling, we need to re-highlight
            context.coordinator.highlightSyntax(in: textView)
        }
        
        textView.isRichText = false
        textView.allowsUndo = true
        
        // Use Global Config
        textView.font = AppConfig.editorFont
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        
        // Layout Settings
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Only update the text if it's different, to avoid cursor jumping
        if textView.string != text {
            textView.string = text
            // Also update the selection when text changes externally
            textView.setSelectedRange(selectedRange)
            context.coordinator.highlightSyntax(in: textView)
        } else {
            // If text is the same, maybe just the selection changed
            if textView.selectedRange != selectedRange {
                textView.setSelectedRange(selectedRange)
            }
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
            
            // 1. Reset Base Style
            textStorage.removeAttribute(.foregroundColor, range: fullRange)
            textStorage.removeAttribute(.font, range: fullRange)
            textStorage.removeAttribute(.strikethroughStyle, range: fullRange)
            textStorage.removeAttribute(.underlineStyle, range: fullRange)
            
            let baseFont = AppConfig.editorFont
            textStorage.addAttribute(.font, value: baseFont, range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
            
            // 2. Define Patterns
            let patterns: [(pattern: String, traits: NSFontDescriptor.SymbolicTraits?, color: NSColor?, underline: Bool, strike: Bool)] = [
                ("^#{1,6}\\s.*$", .bold, .systemBlue, false, false),
                ("<u>(.+?)</u>", nil, nil, true, false),
                ("(?<!\\*)\\*(.+?)\\*(?!\\*)", .bold, nil, false, false),
                ("_(.+?)_", .italic, nil, false, false),
                ("-(.+?)-", nil, .secondaryLabelColor, false, true),
                ("!\\[.*?\\]\\(.*?\\)", nil, .systemPurple, false, false)
            ]
            
            // 3. Apply Regex
            for style in patterns {
                let regex = try! NSRegularExpression(pattern: style.pattern, options: [.anchorsMatchLines])
                
                regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        
                        // Apply Font Traits (Non-Optional on Mac)
                        if let traits = style.traits {
                            let newDescriptor = baseFont.fontDescriptor.withSymbolicTraits(traits)
                            let size = AppConfig.fontSizeMac
                            let newFont = NSFont(descriptor: newDescriptor, size: size) ?? NSFont.boldSystemFont(ofSize: size)
                            textStorage.addAttribute(.font, value: newFont, range: range)
                        }
                        
                        if let color = style.color {
                            textStorage.addAttribute(.foregroundColor, value: color, range: range)
                        }
                        if style.strike {
                            textStorage.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                        }
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
