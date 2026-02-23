#if os(macOS)
import SwiftUI
import AppKit

// The Command menu now targets the methods on our NSTextView subclass
struct EditorCommands: Commands {
    var body: some Commands {
        CommandMenu("Format") {
            Button("Bold") {
                NSApp.sendAction(#selector(NSFontManager.addFontTrait(_:)), to: nil, from: NSFontManager.shared)
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Button("Italic") {
                NSApp.sendAction(#selector(NSFontManager.addFontTrait(_:)), to: nil, from: NSFontManager.shared)
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

struct MacRichTextEditor: NSViewRepresentable {
    @Bindable var sheet: Sheet
    @Binding var attributedData: Data?
    @Binding var selectedRange: NSRange
    var onTextChange: (String) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        
        let textView = SiddharthaTextView()
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isContinuousSpellCheckingEnabled = true
        
        textView.font = AppConfig.editorFont
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.delegate = context.coordinator
        

        
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        
        scrollView.documentView = textView
        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Prevent programmatic updates while the user is actively typing
        guard textView.window?.firstResponder != textView else { return }
        
        // Dynamic margins
        let horizontalMargin = nsView.frame.width * 0.2
        textView.textContainerInset = NSSize(width: horizontalMargin, height: 20)
        
        // Sync RTF data to text storage
        if let data = attributedData {
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
                if textView.attributedString() != attributedString {
                    textView.textStorage?.setAttributedString(attributedString)
                    textView.setSelectedRange(selectedRange)
                }
            }
        } else {
            // If attributedData is nil, try to populate it from plain text content if available
            if let plainTextContent = sheet.content, !plainTextContent.isEmpty {
                let attributedString = NSAttributedString(string: plainTextContent, attributes: [.font: AppConfig.editorFont])
                textView.textStorage?.setAttributedString(attributedString)
                
                if let rtfData = try? attributedString.data(from: NSRange(location: 0, length: attributedString.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
                    attributedData = rtfData
                }
            } else {
                textView.string = ""
            }
        }
        
        if textView.selectedRange() != selectedRange {
            textView.setSelectedRange(selectedRange)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacRichTextEditor

        init(_ parent: MacRichTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Sync text storage back to RTF data
            DispatchQueue.main.async {
                if let data = try? textView.attributedString().data(from: NSRange(location: 0, length: textView.textStorage?.length ?? 0), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
                    self.parent.attributedData = data
                }
                
                self.parent.onTextChange(textView.string)
            }
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.selectedRange = textView.selectedRange()
        }
    }
}
#endif
