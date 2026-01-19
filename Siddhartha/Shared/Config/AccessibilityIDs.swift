//
//  AccessibilityIDs.swift
//  Siddhartha
//

import Foundation

struct AccessibilityIDs {
    struct SheetList {
        static let searchToggle = "SheetList.SearchToggle"
        static let addButton = "SheetList.AddButton"
        
        // The container
        static let searchBar = "SheetList.SearchBar"
        // NEW: The actual text input field
        static let searchField = "SheetList.SearchField"
        
        static func row(title: String) -> String {
            "SheetRow_\(title.isEmpty ? "NewSheet" : title)"
        }
    }
    
    struct Editor {
        static let mainText = "Editor.MainText"
    }
}
