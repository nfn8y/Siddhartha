//
//  PDFCreator.swift
//  Siddhartha
//

import SwiftUI
import PDFKit

#if os(macOS)
@MainActor
struct PDFCreator {
    
    static func createSimplePDF(title: String, content: String) -> URL? {
        // 1. Setup the formatting first (Force BLACK text for PDF so it prints correctly)
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Georgia", size: 14) ?? NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.black
        ]
        
        let attributedString = NSMutableAttributedString(string: "# \(title)\n\n\(content)", attributes: baseAttributes)
        
        // 2. Make Title Big & Bold
        let titlePattern = "# \(title)"
        if let titleRange = attributedString.string.range(of: titlePattern) {
            let nsRange = NSRange(titleRange, in: attributedString.string)
            attributedString.addAttribute(.font, value: NSFont(name: "Georgia-Bold", size: 24) ?? NSFont.boldSystemFont(ofSize: 24), range: nsRange)
        }
        
        // 3. Swap Markdown Tags for Real Images
        // Pattern: ![Alt](Filename)
        let pattern = "!\\[.*?\\]\\((.*?)\\)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        // We iterate in reverse so replacing text doesn't mess up the indices for earlier matches
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count)).reversed()
        
        for match in matches {
            let imageFilenameRange = match.range(at: 1) // The part inside (...)
            if let range = Range(imageFilenameRange, in: content) {
                let filename = String(content[range])
                
                // --- UPDATE: Use FileHelper here ---
                let fileURL = FileHelper.imagesDirectory.appendingPathComponent(filename)
                
                if let image = NSImage(contentsOf: fileURL) {
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    
                    // Resize logic: Fit to page width (approx 500pts)
                    let targetWidth = 500.0
                    let ratio = targetWidth / image.size.width
                    let newHeight = image.size.height * ratio
                    attachment.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: newHeight)
                    
                    let attrString = NSAttributedString(attachment: attachment)
                    attributedString.replaceCharacters(in: match.range, with: attrString)
                }
            }
        }
        
        // 4. Setup the Layout Engine (The Spine)
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
