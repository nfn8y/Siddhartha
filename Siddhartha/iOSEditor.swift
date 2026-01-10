//
//  iOSEditor.swift
//  Siddhartha
//

#if os(iOS)
import SwiftUI
import UIKit

struct iOSMarkdownEditor: UIViewRepresentable {
    @Binding var text: String
    // We don't strictly need selectedRange binding for basic iOS editing,
    // but if you want to track it for buttons, we can keep it simple for now.
    @Binding var selectedRange: NSRange
    var onTextChange: () -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        
        // Match the Theme (Georgia)
        textView.font = UIFont(name: "Georgia", size: 17)
        textView.textColor = UIColor.label
        
        textView.delegate = context.coordinator
        
        // Turn off smart quotes so they don't mess up our Markdown syntax
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // Only update if text actually changed to prevent cursor jumping
        if uiView.text != text {
            uiView.text = text
            context.coordinator.highlightSyntax(in: uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: iOSMarkdownEditor

        init(_ parent: iOSMarkdownEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.selectedRange = textView.selectedRange // Track cursor
            parent.onTextChange()
            highlightSyntax(in: textView)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
             parent.selectedRange = textView.selectedRange
        }
        
        func highlightSyntax(in textView: UITextView) {
            // 1. Setup Base Style
            let text = textView.text ?? ""
            let nsString = text as NSString
            let fullRange = NSRange(location: 0, length: nsString.length)
            
            let attributedString = NSMutableAttributedString(string: text)
            
            // Base Font (Georgia 17)
            let baseFont = UIFont(name: "Georgia", size: 17) ?? UIFont.systemFont(ofSize: 17)
            attributedString.addAttribute(.font, value: baseFont, range: fullRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
            
            // 2. Define Patterns (Exact same logic as Mac)
            let patterns: [(pattern: String, traits: UIFontDescriptor.SymbolicTraits?, color: UIColor?, underline: Bool, strike: Bool)] = [
                // Headings
                ("^#{1,6}\\s.*$", .traitBold, .systemBlue, false, false),
                
                // Underline (<u>text</u>)
                ("<u>(.+?)</u>", nil, nil, true, false),
                
                // Bold (*text*)
                ("(?<!\\*)\\*(.+?)\\*(?!\\*)", .traitBold, nil, false, false),
                
                // Italic (_text_)
                ("_(.+?)_", .traitItalic, nil, false, false),
                
                // Strikethrough (-text-)
                ("-(.+?)-", nil, .secondaryLabel, false, true),
                
                // Image Tags
                ("!\\[.*?\\]\\(.*?\\)", nil, .systemPurple, false, false)
            ]
            
            // 3. Apply Regex
            for style in patterns {
                let regex = try! NSRegularExpression(pattern: style.pattern, options: [.anchorsMatchLines])
                
                regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        // Apply Font Traits
                        if let traits = style.traits {
                            if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) {
                                let newFont = UIFont(descriptor: descriptor, size: 17)
                                attributedString.addAttribute(.font, value: newFont, range: range)
                            }
                        }
                        
                        // Apply Color
                        if let color = style.color {
                            attributedString.addAttribute(.foregroundColor, value: color, range: range)
                        }
                        
                        // Apply Strikethrough
                        if style.strike {
                            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                        }
                        
                        // Apply Underline
                        if style.underline {
                            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                        }
                    }
                }
            }
            
            // 4. Update the View efficiently
            // We need to save the selected range because setting attributedText resets the cursor
            let selectedRange = textView.selectedRange
            textView.attributedText = attributedString
            textView.selectedRange = selectedRange
        }
    }
}
#endif
