//
//  iOSPDFCreator.swift
//  Siddhartha
//

#if os(iOS)
import UIKit
import PDFKit

@MainActor
struct iOSPDFCreator: PDFCreating {
    
    static func createSimplePDF(title: String, content: String, richContent: Data?, fileManager: FileManaging.Type) -> URL? {
        let attributedString: NSMutableAttributedString
        
        if let richData = richContent,
           let richString = try? NSMutableAttributedString(data: richData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            attributedString = richString
            
            // Force BLACK text for PDF
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedString.length))
        } else {
            // Fallback to plain text
            let baseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Georgia", size: 14) ?? UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let fullString = "# \(title)\n\n\(content)"
            attributedString = NSMutableAttributedString(string: fullString, attributes: baseAttributes)
            
            // Make Title Big & Bold
            let titlePattern = "# \(title)"
            if let titleRange = attributedString.string.range(of: titlePattern) {
                let nsRange = NSRange(titleRange, in: attributedString.string)
                if let boldFont = UIFont(name: "Georgia-Bold", size: 24) {
                     attributedString.addAttribute(.font, value: boldFont, range: nsRange)
                }
            }
        }
        
        // Use a dedicated method to render the attributed string to a PDF
        let pdfData = createPDFData(from: attributedString)
        
        // Save to Temp
        let fileName = title.isEmpty ? "Untitled" : title
        let safeName = fileName.components(separatedBy: .punctuationCharacters).joined(separator: "")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(safeName).pdf")
        
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Failed to write PDF: \(error)")
            return nil
        }
    }
    
    private static func createPDFData(from attributedString: NSAttributedString) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842)) // A4 size
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            attributedString.draw(in: CGRect(x: 40, y: 40, width: 515, height: 762))
        }
        
        return data
    }
}
#endif
