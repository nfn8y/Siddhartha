//
//  PDFCreating.swift
//  Siddhartha
//

import Foundation

protocol PDFCreating {
    static func createSimplePDF(title: String, content: String, fileManager: FileManaging.Type) -> URL?
}
