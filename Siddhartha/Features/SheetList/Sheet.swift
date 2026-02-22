//
//  Sheet.swift
//  Siddhartha
//

import Foundation
import SwiftData

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

@Model
final class Sheet {
    var id: UUID? // Changed to optional for migration
    var title: String? // Changed to optional for migration
    var content: String? // Changed to optional for migration
    var attributedContent: Data? // NEW: Stores rich text (RTF)
    var createdAt: Date? // Changed to optional for migration
    var lastModified: Date? // Changed to optional for migration
    
    // --- NEW RELATIONSHIP ---
    var folder: Folder?
    
    // Compute word count for the editor overlay
    var wordCount: Int {
        if let data = attributedContent,
           let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            return attributedString.string.split { $0.isWhitespace || $0.isNewline }.count
        }
        return (content ?? "").split { $0.isWhitespace || $0.isNewline }.count
    }

    init(title: String = "", content: String = "", attributedContent: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.attributedContent = attributedContent
        self.createdAt = Date()
        self.lastModified = Date()
        self.folder = nil // Defaults to "Inbox" (no folder)
    }
}
