//
//  FileHelper.swift
//  Siddhartha
//

import Foundation

struct FileHelper: FileManaging {
    
    // The central place where we store images
    static var imagesDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imagesDir = documentsDirectory.appendingPathComponent("Images")
        
        // Create folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        
        return imagesDir
    }
    
    // Save Data to disk and return filename
    static func saveToDisk(data: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = imagesDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
}
