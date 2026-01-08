//
//  PDFCreator.swift
//  Siddhartha
//

import SwiftUI
import PDFKit

@MainActor
struct PDFCreator {
    
    static func createSimplePDF(title: String, content: String) -> URL? {
        // 1. Setup the Page
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        // 2. Create the Content
        let attributedString = NSMutableAttributedString(string: "# \(title)\n\n\(content)")
        
        // 3. Find and Replace Image Tags with Real Images
        // Pattern: ![Alt](Filename)
        let pattern = "!\\[.*?\\]\\((.*?)\\)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        
        // We iterate in reverse so replacing text doesn't mess up the indices
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count)).reversed()
        
        for match in matches {
            let imageFilenameRange = match.range(at: 1) // The part inside (...)
            if let range = Range(imageFilenameRange, in: content) {
                let filename = String(content[range])
                
                // Locate the image on disk
                let fileURL = ImageStorage.imagesDirectory.appendingPathComponent(filename)
                
                if let image = NSImage(contentsOf: fileURL) {
                    // Create an attachment
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    
                    // Resize image to fit page width (roughly)
                    let targetWidth = 500.0
                    let ratio = targetWidth / image.size.width
                    attachment.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: image.size.height * ratio)
                    
                    // Replace the markdown tag with the image
                    let attrString = NSAttributedString(attachment: attachment)
                    attributedString.replaceCharacters(in: match.range, with: attrString)
                }
            }
        }
        
        // 4. Style the Text (Fonts)
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: NSFont(name: "Georgia", size: 14) ?? NSFont.systemFont(ofSize: 14), range: fullRange)
        
        // Make Title Big
        let titlePattern = "# \(title)"
        if let titleRange = attributedString.string.range(of: titlePattern) {
            let nsRange = NSRange(titleRange, in: attributedString.string)
            attributedString.addAttribute(.font, value: NSFont(name: "Georgia-Bold", size: 24) ?? NSFont.boldSystemFont(ofSize: 24), range: nsRange)
        }
        
        // 5. Build the PDF View
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: CGSize(width: 612 - 100, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        let textView = NSTextView(frame: pageRect, textContainer: textContainer)
        
        // 6. Generate Data
        layoutManager.ensureLayout(for: textContainer)
        let data = textView.dataWithPDF(inside: textView.bounds)
        
        // 7. Save
        let fileName = title.isEmpty ? "Untitled" : title
        let safeName = fileName.components(separatedBy: .punctuationCharacters).joined(separator: "")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).pdf")
        
        try? data.write(to: url)
        return url
    }
}
