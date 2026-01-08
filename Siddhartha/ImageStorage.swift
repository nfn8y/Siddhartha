//
//  ImageStorage.swift
//  Siddhartha
//

import SwiftUI

struct ImageStorage {
    
    // Get the permanent folder for images
    static var imagesDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imagesDir = documentsDirectory.appendingPathComponent("Images")
        
        // Create it if it doesn't exist
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        
        return imagesDir
    }
    
    // Save an image and return the filename
    static func saveImage(_ image: NSImage) -> String? {
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let jpegData = bitmap.representation(using: .jpeg, properties: [:]) else {
            return nil
        }
        
        let filename = UUID().uuidString + ".jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        
        do {
            try jpegData.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}
