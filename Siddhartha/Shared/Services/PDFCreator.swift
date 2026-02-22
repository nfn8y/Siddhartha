//
//  PDFCreator.swift
//  Siddhartha
//

import SwiftUI
import PDFKit

#if os(macOS)
@MainActor
struct PDFCreator: PDFCreating {
    
    static func createSimplePDF(title: String, content: String, richContent: Data?, fileManager: FileManaging.Type) -> URL? {
        let attributedString: NSMutableAttributedString
        
        if let richData = richContent,
           let richString = try? NSMutableAttributedString(data: richData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            attributedString = richString
            
            // Force BLACK text for PDF so it prints correctly
            attributedString.addAttribute(.foregroundColor, value: NSColor.black, range: NSRange(location: 0, length: attributedString.length))
        } else {
            // Fallback to plain text
            let baseAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont(name: "Georgia", size: 14) ?? NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.black
            ]
            attributedString = NSMutableAttributedString(string: "# \(title)\n\n\(content)", attributes: baseAttributes)
            
            // Make Title Big & Bold
            let titlePattern = "# \(title)"
            if let titleRange = attributedString.string.range(of: titlePattern) {
                let nsRange = NSRange(titleRange, in: attributedString.string)
                attributedString.addAttribute(.font, value: NSFont(name: "Georgia-Bold", size: 24) ?? NSFont.boldSystemFont(ofSize: 24), range: nsRange)
            }
        }
        
        // Setup the Layout Engine (The Spine)
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)
        
        // 5. Setup the Container (Infinite Height)
        // We remove 100pts from width for margins
        let textContainer = NSTextContainer(size: CGSize(width: 612 - 100, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        // 6. Force Layout Calculation
        layoutManager.ensureLayout(for: textContainer)
        
        // 7. Calculate the Real Height needed
        let usedRect = layoutManager.usedRect(for: textContainer)
        let totalHeight = max(usedRect.height + 100, 792) // At least one page tall
        
        // 8. Create the View with the Calculated Height
        let textView = NSTextView(frame: CGRect(x: 0, y: 0, width: 612, height: totalHeight), textContainer: textContainer)
        
        // 9. Generate PDF Data
        let data = textView.dataWithPDF(inside: textView.bounds)
        
        // 10. Save to Temp
        let fileName = title.isEmpty ? "Untitled" : title
        let safeName = fileName.components(separatedBy: .punctuationCharacters).joined(separator: "")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).pdf")
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Failed to write PDF: \(error)")
            return nil
        }
    }
}
#endif
