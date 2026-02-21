//
//  MarkdownStyler.swift
//  Siddhartha
//

import Foundation

enum MarkdownStyle {
    case bold
    case italic
    case strikethrough
    case underline
    
    var syntax: String {
        switch self {
        case .bold: return "*"
        case .italic: return "_"
        case .strikethrough: return "-"
        case .underline: return "<u>" // This is special, not a simple wrap
        }
    }
    
    var closingSyntax: String {
        switch self {
        case .underline: return "</u>"
        default: return syntax
        }
    }
}

struct MarkdownStyler {
    
    typealias StylingResult = (newText: String, newSelectedRange: NSRange)
    
    /// Applies or removes a given Markdown style to the selected range of a string.
    /// - Parameters:
    ///   - style: The Markdown style to apply (e.g., bold, italic).
    ///   - text: The full text from the editor.
    ///   - selectedRange: The range of text currently selected by the user.
    /// - Returns: A tuple containing the modified text and the new selected range.
    static func toggleStyle(_ style: MarkdownStyle, for text: String, in selectedRange: NSRange) -> StylingResult {
        guard let range = Range(selectedRange, in: text) else { return (text, selectedRange) }
        
        let selectedText = String(text[range])
        let prefix = style.syntax
        let suffix = style.closingSyntax
        
        // Case 1: The selection is already wrapped with the style. Unwrap it.
        if selectedText.hasPrefix(prefix) && selectedText.hasSuffix(suffix) {
            let unwrappedText = selectedText.dropFirst(prefix.count).dropLast(suffix.count)
            let newText = text.replacingCharacters(in: range, with: String(unwrappedText))
            let newRange = NSRange(location: selectedRange.location, length: unwrappedText.count)
            return (newText, newRange)
        }
        
        // Case 2: The text surrounding the selection is the style. Unwrap the whole thing.
        let surroundingNSRange = text.getSurroundingRange(for: selectedRange, prefix: prefix, suffix: suffix)
        if let rangeToUnwrap = surroundingNSRange, let swiftRange = Range(rangeToUnwrap, in: text) {
            let innerText = text.substring(with: rangeToUnwrap)
                .dropFirst(prefix.count).dropLast(suffix.count)
            
            let newText = text.replacingCharacters(in: swiftRange, with: String(innerText))
            
            let newLocation = rangeToUnwrap.location
            let newLength = innerText.count
            let newRange = NSRange(location: newLocation, length: newLength)
            
            return (newText, newRange)
        }
        
        // Case 3: No style detected. Apply it.
        let wrappedText = "\(prefix)\(selectedText)\(suffix)"
        let newText = text.replacingCharacters(in: range, with: wrappedText)
        let newRange = NSRange(location: selectedRange.location, length: wrappedText.count)
        
        return (newText, newRange)
    }
}

// MARK: - String helpers for this logic
extension String {
    func getSurroundingRange(for innerRange: NSRange, prefix: String, suffix: String) -> NSRange? {
        guard let innerStringRange = Range(innerRange, in: self) else { return nil }

        let prefixStartIndex = self.range(of: prefix, options: .backwards, range: self.startIndex..<innerStringRange.lowerBound)
        let suffixEndIndex = self.range(of: suffix, options: [], range: innerStringRange.upperBound..<self.endIndex)

        if let start = prefixStartIndex, let end = suffixEndIndex {
            return NSRange(start.lowerBound..<end.upperBound, in: self)
        }
        return nil
    }

    func substring(with nsrange: NSRange) -> String {
        guard let range = Range(nsrange, in: self) else { return "" }
        return String(self[range])
    }
}

