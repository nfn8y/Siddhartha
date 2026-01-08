//
//  MacEditor.swift
//  Siddhartha
//

import SwiftUI
import AppKit

#if os(macOS)
struct MacMarkdownEditor: NSViewRepresentable {
    @Binding var text: String
    var onTextChange: (String) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        // 1. Create the ScrollView (the container)
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        // 2. Create the powerful TextView
        let textView = NSTextView()
        textView.isRichText = false // We handle the styling manually
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator // Connect the Brain
        
        // 3. Layout constraints
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        
        // 4. Set initial text
        textView.string = text
        
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // This updates the view if the SwiftUI state changes externally
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // --- THE BRAIN (Coordinator) ---
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacMarkdownEditor

        init(_ parent: MacMarkdownEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // 1. Update the data model
            parent.text = textView.string
            parent.onTextChange(textView.string)
            
            // 2. Apply Syntax Highlighting
            highlightSyntax(in: textView)
        }
        
        func highlightSyntax(in textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            
            // Reset to base font
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.removeAttribute(.foregroundColor, range: fullRange)
            textStorage.removeAttribute(.font, range: fullRange)
            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15, weight: .regular), range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
            
            let string = textView.string as NSString
            
            // RULE A: Headings (lines starting with #)
            // Regex: Look for # at the start of a line
            let headingPattern = "^#{1,6}\\s.*$"
            let headingRegex = try! NSRegularExpression(pattern: headingPattern, options: .anchorsMatchLines)
            
            headingRegex.enumerateMatches(in: textView.string, options: [], range: fullRange) { match, _, _ in
                if let range = match?.range {
                    // Make it Blue and Bold
                    textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: range)
                    textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 18, weight: .bold), range: range)
                }
            }
            
            // RULE B: Bold (**text**)
            let boldPattern = "\\*\\*.*?\\*\\*"
            let boldRegex = try! NSRegularExpression(pattern: boldPattern, options: [])
            
            boldRegex.enumerateMatches(in: textView.string, options: [], range: fullRange) { match, _, _ in
                if let range = match?.range {
                    // Make it just Bold
                    textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15, weight: .bold), range: range)
                    // Make the asterisks gray (subtle)
                    textStorage.addAttribute(.foregroundColor, value: NSColor.secondaryLabelColor, range: range)
                }
            }
        }
    }
}
#endif
