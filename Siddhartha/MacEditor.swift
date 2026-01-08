//
//  MacEditor.swift
//  Siddhartha
//

import SwiftUI
import AppKit

#if os(macOS)
struct MacMarkdownEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var selectedRange: NSRange // <--- NEW: Tracks your cursor
    
    var onTextChange: (String) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        let textView = NSTextView()
        textView.isRichText = false
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        
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
        
        // Only update text if it's actually different (prevents cursor jumping)
        if textView.string != text {
            textView.string = text
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
            
            // Update Text
            parent.text = textView.string
            parent.onTextChange(textView.string)
            
            // Highlight
            highlightSyntax(in: textView)
        }
        
        // Track the cursor moving
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.selectedRange = textView.selectedRange
        }
        
        func highlightSyntax(in textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.removeAttribute(.foregroundColor, range: fullRange)
            textStorage.removeAttribute(.font, range: fullRange)
            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 15, weight: .regular), range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
            
            // Highlight Headings (#)
            let headingPattern = "^#{1,6}\\s.*$"
            let headingRegex = try! NSRegularExpression(pattern: headingPattern, options: .anchorsMatchLines)
            headingRegex.enumerateMatches(in: textView.string, options: [], range: fullRange) { match, _, _ in
                if let range = match?.range {
                    textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: range)
                    textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 18, weight: .bold), range: range)
                }
            }
            
            // Highlight Images (![...](...))
            let imagePattern = "!\\[.*?\\]\\(.*?\\)"
            let imageRegex = try! NSRegularExpression(pattern: imagePattern, options: [])
            imageRegex.enumerateMatches(in: textView.string, options: [], range: fullRange) { match, _, _ in
                if let range = match?.range {
                    // Make image tags purple
                    textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: range)
                }
            }
        }
    }
}
#endif
