//
//  iOSEditor.swift
//  Siddhartha
//

#if os(iOS)
import SwiftUI
import UIKit

struct iOSRichTextEditor: UIViewRepresentable {
    @Binding var attributedData: Data?
    @Binding var selectedRange: NSRange
    var onTextChange: (String) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.accessibilityIdentifier = "siddhartha-text-view"
        textView.isEditable = true
        textView.isScrollEnabled = true
        
        textView.backgroundColor = .clear
        textView.textColor = .label
        
        textView.font = AppConfig.editorFont
        textView.delegate = context.coordinator
        
        // --- NATIVE RICH TEXT ---
        textView.allowsEditingTextAttributes = true
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // Dynamic margins
        let horizontalMargin = uiView.frame.width * 0.05
        uiView.textContainerInset = UIEdgeInsets(top: 20, left: horizontalMargin, bottom: 20, right: horizontalMargin)
        
        // Sync RTF data to text storage
        if let data = attributedData {
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
                if uiView.attributedText != attributedString {
                    uiView.attributedText = attributedString
                    uiView.selectedRange = selectedRange
                }
            }
        } else {
            if !uiView.text.isEmpty {
                uiView.text = ""
            }
        }
        
        if uiView.selectedRange != selectedRange {
            uiView.selectedRange = selectedRange
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: iOSRichTextEditor

        init(_ parent: iOSRichTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // Sync text storage back to RTF data
            if let data = try? textView.attributedText.data(from: NSRange(location: 0, length: textView.attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
                parent.attributedData = data
            }
            parent.onTextChange(textView.text)
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
             parent.selectedRange = textView.selectedRange
        }
    }
}
#endif
