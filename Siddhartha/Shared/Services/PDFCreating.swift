//
//  PDFCreating.swift
//  Siddhartha
//

import Foundation

protocol PDFCreating {
    static func createSimplePDF(title: String, content: String, richContent: Data?, fileManager: FileManaging.Type) -> URL?
}
