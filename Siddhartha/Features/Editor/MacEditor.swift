#if os(macOS)
import SwiftUI
import AppKit

// The Command menu now targets the methods on our NSTextView subclass
struct EditorCommands: Commands {
    var body: some Commands {
        CommandMenu("Format") {
            Button("Bold") {
                NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(SiddharthaTextView.toggleBold), with: nil)
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Button("Italic") {
                NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(SiddharthaTextView.toggleItalic), with: nil)
            }
            .keyboardShortcut("i", modifiers: .command)

            Button("Underline") {
                NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(SiddharthaTextView.toggleUnderline), with: nil)
            }
            .keyboardShortcut("u", modifiers: .command)
            
            Divider()

            Button("Strikethrough") {
                NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(SiddharthaTextView.toggleStrikethrough), with: nil)
            }
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
        
        // Use our custom NSTextView subclass
        let textView = SiddharthaTextView()
        
        // Wire up the callback from the subclass to the Coordinator
        textView.onStyleToggle = { result in
            context.coordinator.handleStyleToggle(result: result)
        }
        
        textView.isRichText = true
        textView.allowsUndo = true
        
        textView.font = AppConfig.editorFont
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        
        // Set the accessibility identifier for UI Tests
        textView.setAccessibilityIdentifier("siddhartha-text-view")
        
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
        
        if textView.string != text {
            textView.string = text
            textView.setSelectedRange(selectedRange)
            context.coordinator.highlightSyntax(in: textView)
        } else {
            if textView.selectedRange() != selectedRange {
                textView.setSelectedRange(selectedRange)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // The Coordinator is now just a delegate again, not a responder.
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
            parent.selectedRange = textView.selectedRange()
        }
        
        // This function is called by the SiddharthaTextView subclass via the closure
        func handleStyleToggle(result: MarkdownStyler.StylingResult) {
            parent.text = result.newText
            parent.selectedRange = result.newSelectedRange
        }
        
        // MARK: - Syntax Highlighting
        
        func highlightSyntax(in textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            let fullRange = NSRange(location: 0, length: textStorage.length)
            
            textStorage.beginEditing()
            
            let baseFont = AppConfig.editorFont
            textStorage.setAttributes([
                .font: baseFont,
                .foregroundColor: NSColor.labelColor
            ], range: fullRange)
            
            let patterns: [(pattern: String, traits: NSFontDescriptor.SymbolicTraits?, color: NSColor?, underline: Bool, strike: Bool)] = [
                ("^#{1,6}\\s.*$", .bold, .systemBlue, false, false),
                ("<u>(.+?)</u>", nil, nil, true, false),
                ("(?<!\\*)\\*(.+?)\\*(?!\\*)", .bold, nil, false, false),
                ("_(.+?)_", .italic, nil, false, false),
                ("-(.+?)-", nil, .secondaryLabelColor, false, true),
                ("!\\[.*?\\]\\(.*?\\)", nil, .systemPurple, false, false)
            ]
            
            for style in patterns {
                let regex = try! NSRegularExpression(pattern: style.pattern, options: [.anchorsMatchLines])
                
                regex.enumerateMatches(in: textStorage.string, options: [], range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        
                        var attributes: [NSAttributedString.Key: Any] = [:]
                        
                        if let traits = style.traits {
                            let newDescriptor = baseFont.fontDescriptor.withSymbolicTraits(traits)
                            let newFont = NSFont(descriptor: newDescriptor, size: AppConfig.fontSizeMac)
                            attributes[.font] = newFont ?? baseFont
                        }
                        
                        if let color = style.color {
                            attributes[.foregroundColor] = color
                        }
                        if style.strike {
                            attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                        }
                        if style.underline {
                            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                        }
                        textStorage.addAttributes(attributes, range: range)
                    }
                }
            }
            textStorage.endEditing()
        }
    }
}
#endif
