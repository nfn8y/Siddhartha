//
//  EditorViewModel.swift
//  Siddhartha
//

import SwiftUI

@Observable
class EditorViewModel {
    private let storage: StorageService
    private let actions: ActionService
    
    // Dependency Injection via initializer
    init(storageService: StorageService, actionService: ActionService) {
        self.storage = storageService
        self.actions = actionService
    }
    
    func exportAsPDF(sheet: Sheet?) {
        guard let sheet = sheet else { return }
        
        // 1. Ask the StorageService to create a temporary PDF file
        guard let pdfURL = storage.createPDF(title: sheet.title, content: sheet.content) else {
            print("PDF creation failed.")
            return
        }
        
        // 2. Ask the ActionService to present the system's export UI
        actions.exportPDF(url: pdfURL, title: sheet.title)
    }
}
