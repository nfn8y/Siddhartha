//
//  iOSServices.swift
//  Siddhartha
//

import SwiftUI
// Foundation is needed for Data, UUID, etc.
import Foundation

#if os(iOS)
import UIKit

// --- THEME ---
struct iOSTheme: ThemeService {
    var paperBackground: Color { Color(uiColor: .systemBackground) }
    var titleFont: Font { .custom("Georgia-Bold", size: 28) }
    var writingFont: Font { .custom("Georgia", size: 17) }
}

// --- STORAGE ---
struct iOSStorage: StorageService {
    func saveImage(_ image: PlatformImage) -> String? {
        // Convert UIImage to Data
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        // Use the shared FileHelper (from FileHelper.swift)
        return FileHelper.saveToDisk(data: data)
    }
    
    func createPDF(title: String, content: String) -> URL? {
        print("PDF Generation not implemented on iOS yet")
        return nil
    }
}

// --- ACTIONS ---
struct iOSActions: ActionService {
    var supportsImagePicker: Bool = false
    var supportsPDFExport: Bool = false
    
    func pickImage(completion: @escaping (PlatformImage?) -> Void) {
        print("Image picker invoked on iOS")
        completion(nil)
    }
    
    func exportPDF(url: URL, title: String) {
        // iOS uses ShareSheet, logic to come later
    }
}
#endif
