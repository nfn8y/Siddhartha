//
//  Folder.swift
//  Siddhartha
//

import Foundation
import SwiftData

@Model
final class Folder {
    var id: UUID? // Changed to optional for migration
    var name: String? // Changed to optional for migration
    var createdAt: Date? // Changed to optional for migration
    var icon: String? // Changed to optional for migration
    var colorHex: String? // Changed to optional for migration
    
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
