//
//  FormatManager.swift
//  Siddhartha
//

import Foundation

struct FormatManager {
    
    struct ToggleRequest {
        let content: String
        let range: NSRange
        let startSymbol: String
        let endSymbol: String
    }
    
    struct ToggleResult {
        let newContent: String
        let newRange: NSRange
    }
    
    static func toggle(_ req: ToggleRequest) -> ToggleResult? {
        guard req.range.location <= req.content.count else { return nil }
        
        let nsContent = req.content as NSString
        let start = req.range.location
        let length = req.range.length
        
        if length > 0 {
            // Case A: Wrap Selection (e.g. "Text" -> "<u>Text</u>")
            let selectedText = nsContent.substring(with: req.range)
            let newText = "\(req.startSymbol)\(selectedText)\(req.endSymbol)"
            
            let finalContent = nsContent.replacingCharacters(in: req.range, with: newText)
            
            // Expand selection to include the new tags
            let newRange = NSRange(location: start, length: length + req.startSymbol.count + req.endSymbol.count)
            
            return ToggleResult(newContent: finalContent, newRange: newRange)
            
        } else {
            // Case B: No Selection (Insert tags and place cursor inside)
            let newText = "\(req.startSymbol)\(req.endSymbol)"
            let finalContent = nsContent.replacingCharacters(in: req.range, with: newText)
            
            // Move cursor to the middle
            let newRange = NSRange(location: start + req.startSymbol.count, length: 0)
            
            return ToggleResult(newContent: finalContent, newRange: newRange)
        }
    }
}
