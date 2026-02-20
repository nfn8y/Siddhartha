//
//  FileManaging.swift
//  Siddhartha
//

import Foundation

protocol FileManaging {
    static var imagesDirectory: URL { get }
    static func saveToDisk(data: Data) -> String?
}
