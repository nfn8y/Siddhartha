//
//  PDFCreator.swift
//  Siddhartha
//

import SwiftUI
import PDFKit

@MainActor
struct PDFCreator {
    
    static func createSimplePDF(title: String, content: String) -> URL? {
        // 1. Define the Page Size (US Letter)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        
        // 2. Create the Text Stack (The Spine)
        // Storage holds the text
        let textStorage = NSTextStorage(string: "# \(title)\n\n\(content)")
        
        // LayoutManager handles the math of where words go
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        // Container defines the drawing area
        let textContainer = NSTextContainer(size: CGSize(width: 612, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        // 3. Create the View (Attached to the spine)
        let textView = NSTextView(frame: pageRect, textContainer: textContainer)
        
        // 4. Style the Text
        textView.font = NSFont(name: "Georgia", size: 14) // Body font
        
        // Make the Title Big & Bold
        let titleRange = (textStorage.string as NSString).range(of: "# \(title)")
        if titleRange.location != NSNotFound {
            textStorage.addAttribute(.font, value: NSFont(name: "Georgia-Bold", size: 24) ?? NSFont.boldSystemFont(ofSize: 24), range: titleRange)
        }
        
        // 5. Generate PDF
        // We force the layout manager to calculate the layout before printing
        layoutManager.ensureLayout(for: textContainer)
        
        let data = textView.dataWithPDF(inside: textView.bounds)
        
        // 6. Save to Temp
        let fileName = title.isEmpty ? "Untitled" : title
        // Clean the filename to remove illegal characters (like / or :)
        let safeName = fileName.components(separatedBy: .punctuationCharacters).joined(separator: "")
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).pdf")
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("Failed to save PDF: \(error)")
            return nil
        }
    }
}
