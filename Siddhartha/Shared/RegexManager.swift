//
//  RegexManager.swift
//  Siddhartha
//

import Foundation

// Singleton to safely cache Regex patterns (Fixes Gap #2)
struct RegexManager {
    static let shared = RegexManager()
    
    // We try to initialize these once. If they fail, we return nil safely.
    let headingRegex: NSRegularExpression?
    let boldRegex: NSRegularExpression?
    let italicRegex: NSRegularExpression?
    let underlineRegex: NSRegularExpression?
    let strikeRegex: NSRegularExpression?
    let imageRegex: NSRegularExpression?
    
    private init() {
        // We use try? here so if a pattern is invalid, it simply returns nil instead of Crashing the app.
        self.headingRegex = try? NSRegularExpression(pattern: "^#{1,6}\\s.*$", options: [.anchorsMatchLines])
        self.boldRegex = try? NSRegularExpression(pattern: "(?<!\\*)\\*(.+?)\\*(?!\\*)", options: [])
        self.italicRegex = try? NSRegularExpression(pattern: "_(.+?)_", options: [])
        self.underlineRegex = try? NSRegularExpression(pattern: "<u>(.+?)</u>", options: [])
        self.strikeRegex = try? NSRegularExpression(pattern: "-(.+?)-", options: [])
        self.imageRegex = try? NSRegularExpression(pattern: "!\\[.*?\\]\\(.*?\\)", options: [])
    }
}
