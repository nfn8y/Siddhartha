//
//  MarkdownStylerTests.swift
//  SiddharthaTests
//

import Foundation
import Testing
@testable import Siddhartha

struct MarkdownStylerTests {

    @Test("Toggling Bold Style")
    func testBold() {
        let originalText = "Hello world"
        let selection = (originalText as NSString).range(of: "world")
        
        // 1. Apply bold
        let (boldedText, boldedRange) = MarkdownStyler.toggleStyle(.bold, for: originalText, in: selection)
        #expect(boldedText == "Hello *world*")
        #expect(boldedRange == NSRange(location: 6, length: 7)) // *world*

        // 2. Remove bold by selecting the wrapped text
        let (unboldedText, unboldedRange) = MarkdownStyler.toggleStyle(.bold, for: boldedText, in: boldedRange)
        #expect(unboldedText == "Hello world")
        #expect(unboldedRange == NSRange(location: 6, length: 5)) // world
    }
    
    @Test("Toggling Italic Style")
    func testItalic() {
        let originalText = "Hello world"
        let selection = (originalText as NSString).range(of: "world")
        
        // Apply italic
        let (italicText, italicRange) = MarkdownStyler.toggleStyle(.italic, for: originalText, in: selection)
        #expect(italicText == "Hello _world_")
        #expect(italicRange == NSRange(location: 6, length: 7)) // _world_

        // Remove italic
        let (unitalicText, unitalicRange) = MarkdownStyler.toggleStyle(.italic, for: italicText, in: italicRange)
        #expect(unitalicText == "Hello world")
        #expect(unitalicRange == NSRange(location: 6, length: 5))
    }
    
    @Test("Toggling Strikethrough Style")
    func testStrikethrough() {
        let originalText = "Hello world"
        let selection = (originalText as NSString).range(of: "world")
        
        // Apply strikethrough
        let (strikeText, strikeRange) = MarkdownStyler.toggleStyle(.strikethrough, for: originalText, in: selection)
        #expect(strikeText == "Hello -world-")
        #expect(strikeRange == NSRange(location: 6, length: 7)) // -world-

        // Remove strikethrough
        let (unstrikeText, unstrikeRange) = MarkdownStyler.toggleStyle(.strikethrough, for: strikeText, in: strikeRange)
        #expect(unstrikeText == "Hello world")
        #expect(unstrikeRange == NSRange(location: 6, length: 5))
    }
    
    @Test("Toggling Underline Style")
    func testUnderline() {
        let originalText = "Hello world"
        let selection = (originalText as NSString).range(of: "world")
        
        // Apply underline
        let (underlineText, underlineRange) = MarkdownStyler.toggleStyle(.underline, for: originalText, in: selection)
        #expect(underlineText == "Hello <u>world</u>")
        #expect(underlineRange == NSRange(location: 6, length: 12)) // <u>world</u>

        // Remove underline
        let (ununderlineText, ununderlineRange) = MarkdownStyler.toggleStyle(.underline, for: underlineText, in: underlineRange)
        #expect(ununderlineText == "Hello world")
        #expect(ununderlineRange == NSRange(location: 6, length: 5))
    }
    
    @Test("Toggling Style on Inner Selection")
    func testUnwrapFromInner() {
        let originalText = "Hello *important world*"
        let selection = (originalText as NSString).range(of: "important world")

        // Remove bold by selecting text inside the asterisks
        let (unboldedText, unboldedRange) = MarkdownStyler.toggleStyle(.bold, for: originalText, in: selection)
        #expect(unboldedText == "Hello important world")
        #expect(unboldedRange == NSRange(location: 6, length: 15)) // important world
    }
}

