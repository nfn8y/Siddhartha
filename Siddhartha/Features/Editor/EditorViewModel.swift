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
        
        // Use a background task to avoid blocking the UI
        Task {
            // 1. Create the PDF on a background thread. This is the heavy work.
            let pdfURL = storage.createPDF(title: sheet.title, content: sheet.content)
            
            // 2. Switch back to the main thread to present the UI.
            await MainActor.run {
                guard let url = pdfURL else {
                    print("PDF creation failed.")
                    return
                }
                actions.exportPDF(url: url, title: sheet.title)
            }
        }
    }
}
