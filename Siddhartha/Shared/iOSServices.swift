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
    let pdfCreator: PDFCreating.Type

    func saveImage(_ image: PlatformImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        return fileManager.saveToDisk(data: data)
    }
    
    func createPDF(title: String, content: String, richContent: Data?) -> URL? {
        return pdfCreator.createSimplePDF(title: title, content: content, richContent: richContent, fileManager: fileManager)
    }
}

// --- ACTIONS ---
struct iOSActions: ActionService {
    var supportsImagePicker: Bool = false
    var supportsPDFExport: Bool = true
    
    func pickImage(completion: @escaping (PlatformImage?) -> Void) {
        completion(nil)
    }
    
    func exportPDF(url: URL, title: String) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // Find the key window and the root view controller
        let allScenes = UIApplication.shared.connectedScenes
        let windowScene = allScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene

        if let window = windowScene?.windows.first {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
#endif
