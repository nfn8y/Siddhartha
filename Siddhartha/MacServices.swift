//
//  MacServices.swift
//  Siddhartha
//

#if os(macOS)
import SwiftUI
import AppKit
import PDFKit
import UniformTypeIdentifiers // <--- THIS WAS MISSING

// --- THEME ---
struct MacTheme: ThemeService {
    var paperBackground: Color { Color(nsColor: .textBackgroundColor) }
    var titleFont: Font { .custom("Georgia-Bold", size: 28) }
    var writingFont: Font { .custom("Georgia", size: 18) }
}

// --- STORAGE ---
struct MacStorage: StorageService {
    func saveImage(_ image: PlatformImage) -> String? {
        // Convert NSImage to Data
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else { return nil }
        
        // Use the shared FileHelper
        return FileHelper.saveToDisk(data: jpegData)
    }
    
    func createPDF(title: String, content: String) -> URL? {
        return PDFCreator.createSimplePDF(title: title, content: content)
    }
}

// --- ACTIONS ---
struct MacActions: ActionService {
    var supportsImagePicker: Bool = true
    var supportsPDFExport: Bool = true
    
    func pickImage(completion: @escaping (PlatformImage?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image] // Now this works!
        panel.begin { response in
            if response == .OK, let url = panel.url {
                completion(NSImage(contentsOf: url))
            } else {
                completion(nil)
            }
        }
    }
    
    func exportPDF(url: URL, title: String) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf] // Now this works!
        savePanel.nameFieldStringValue = title.isEmpty ? "Untitled" : title
        savePanel.begin { response in
            if response == .OK, let targetURL = savePanel.url {
                try? FileManager.default.copyItem(at: url, to: targetURL)
            }
        }
    }
}
#endif
