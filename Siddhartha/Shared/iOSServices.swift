//
//  iOSServices.swift
//  Siddhartha
//

import SwiftUI
import Foundation

#if os(iOS)
import UIKit

// --- THEME ---
struct iOSTheme: ThemeService {
    var paperBackground: Color { Color(uiColor: .systemBackground) }
    
    // Now powered by AppConfig
    var titleFont: Font { AppConfig.swiftUITitleFont }
    var writingFont: Font { AppConfig.swiftUIWritingFont }
}

// --- STORAGE ---
struct iOSStorage: StorageService {
    let fileManager: FileManaging.Type

    func saveImage(_ image: PlatformImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        return fileManager.saveToDisk(data: data)
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
        completion(nil)
    }
    
    func exportPDF(url: URL, title: String) {
        // iOS ShareSheet logic
    }
}
#endif
