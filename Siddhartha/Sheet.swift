//
//  Sheet.swift
//  Siddhartha
//

import Foundation
import SwiftData

@Model
final class Sheet {
    var title: String
    var content: String
    var createdAt: Date
    var lastModified: Date
    
    init(title: String = "Untitled", content: String = "") {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.lastModified = Date()
    }
    
    // --- NEW: Testable Logic ---
    var wordCount: Int {
        if content.isEmpty { return 0 }
        return content.split { $0.isWhitespace || $0.isNewline }.count
    }
}
