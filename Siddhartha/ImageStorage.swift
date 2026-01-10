//
//  ImageStorage.swift
//  Siddhartha
//

import SwiftUI

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif

struct ImageStorage {
    
    static var imagesDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imagesDir = documentsDirectory.appendingPathComponent("Images")
        
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        
        return imagesDir
    }
    
    static func saveImage(_ image: PlatformImage) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        // --- MAC LOGIC ---
        #if os(macOS)
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
            return nil
        }
        #else
        // --- IPHONE LOGIC ---
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        #endif
        
        do {
            try jpegData.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}
