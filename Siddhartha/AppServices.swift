//
//  AppServices.swift
//  Siddhartha
//

import SwiftUI
import Combine

// 1. Define Universal Types
// We use typealiases to hide NSImage/UIImage differences
#if os(macOS)
import AppKit
public typealias PlatformImage = NSImage
#else
import UIKit
public typealias PlatformImage = UIImage
#endif

// 2. The Interfaces

// Handles Colors and Fonts
protocol ThemeService {
    var paperBackground: Color { get }
    var titleFont: Font { get }
    var writingFont: Font { get }
}

// Handles IO (Saving images, PDFs)
protocol StorageService {
    func saveImage(_ image: PlatformImage) -> String?
    func createPDF(title: String, content: String) -> URL?
}

// Handles Actions (Things that require UI context, like picking files)
protocol ActionService {
    var supportsImagePicker: Bool { get }
    var supportsPDFExport: Bool { get }
    
    // For Mac, we can trigger this directly. For iOS, we might need a distinct flow.
    func pickImage(completion: @escaping (PlatformImage?) -> Void)
    func exportPDF(url: URL, title: String)
}

// 3. The Central Container (The "ApplicationContext")
class Services {
    static let shared = Services() // Singleton access
    
    let theme: ThemeService
    let storage: StorageService
    let actions: ActionService
    
    private init() {
        // This is the ONLY place in the app where the #if check lives.
        // It acts as the Factory.
        #if os(macOS)
        self.theme = MacTheme()
        self.storage = MacStorage()
        self.actions = MacActions()
        #else
        self.theme = iOSTheme()
        self.storage = iOSStorage()
        self.actions = iOSActions()
        #endif
    }
}
