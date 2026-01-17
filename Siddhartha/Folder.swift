//
//  Folder.swift
//  Siddhartha
//

import Foundation
import SwiftData

@Model
final class Folder {
    var id: UUID
    var name: String
    var createdAt: Date
    var icon: String // e.g., "folder"
    var colorHex: String // NEW: Store color as a hex string (e.g. "#FF0000")
    
    @Relationship(deleteRule: .cascade, inverse: \Sheet.folder)
    var sheets: [Sheet]? = []
    
    init(name: String, icon: String = "folder", colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}
