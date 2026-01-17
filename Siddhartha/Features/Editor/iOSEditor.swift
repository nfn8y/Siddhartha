//
//  iOSEditor.swift
//  Siddhartha
//

#if os(iOS)
import SwiftUI
import UIKit

struct iOSMarkdownEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var selectedRange: NSRange
    var onTextChange: () -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        
        textView.font = AppConfig.editorFont
        textView.textColor = UIColor.label
        
        textView.delegate = context.coordinator
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
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
            parent.selectedRange = textView.selectedRange
            parent.onTextChange()
            highlightSyntax(in: textView)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
             parent.selectedRange = textView.selectedRange
        }
        
        func highlightSyntax(in textView: UITextView) {
            let text = textView.text ?? ""
            let fullRange = NSRange(location: 0, length: text.utf16.count)
            let attributedString = NSMutableAttributedString(string: text)
            
            // 1. Base Style
            let baseFont = AppConfig.editorFont
            attributedString.addAttribute(.font, value: baseFont, range: fullRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
            
            // 2. Define Patterns (Using Singleton)
            let patterns: [(regex: NSRegularExpression?, traits: UIFontDescriptor.SymbolicTraits?, color: UIColor?, underline: Bool, strike: Bool)] = [
                (RegexManager.shared.headingRegex, .traitBold, .systemBlue, false, false),
                (RegexManager.shared.underlineRegex, nil, nil, true, false),
                (RegexManager.shared.boldRegex, .traitBold, nil, false, false),
                (RegexManager.shared.italicRegex, .traitItalic, nil, false, false),
                (RegexManager.shared.strikeRegex, nil, .secondaryLabel, false, true),
                (RegexManager.shared.imageRegex, nil, .systemPurple, false, false)
            ]
            
            // 3. Apply Regex
            for style in patterns {
                // Safely unwrap
                guard let regex = style.regex else { continue }
                
                regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        
                        if let traits = style.traits {
                            if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) {
                                let size = AppConfig.fontSizeiOS
                                let newFont = UIFont(descriptor: descriptor, size: size)
                                attributedString.addAttribute(.font, value: newFont, range: range)
                            }
                        }
                        
                        if let color = style.color {
                            attributedString.addAttribute(.foregroundColor, value: color, range: range)
                        }
                        
                        if style.strike {
                            attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                        }
                        
                        if style.underline {
                            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                        }
                    }
                }
            }
            
            // 4. Update View (Preserve Cursor)
            let selectedRange = textView.selectedRange
            textView.attributedText = attributedString
            textView.selectedRange = selectedRange
        }
    }
}
#endif
