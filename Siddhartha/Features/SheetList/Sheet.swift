//
//  Sheet.swift
//  Siddhartha
//

import Foundation
import SwiftData

@Model
final class Sheet {
    var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var lastModified: Date
    
    // --- NEW RELATIONSHIP ---
    var folder: Folder?
    
    // Compute word count for the editor overlay
    var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    init(title: String = "", content: String = "") {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.lastModified = Date()
        self.folder = nil // Defaults to "Inbox" (no folder)
    }
}
