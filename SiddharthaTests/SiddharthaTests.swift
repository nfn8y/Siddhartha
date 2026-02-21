//
//  SiddharthaTests.swift
//  SiddharthaTests
//

import Testing
import Foundation
import SwiftData
@testable import Siddhartha // Allows us to see your App code

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(AppKit)
import AppKit
#endif

struct SiddharthaTests {

    // --- UNIT TEST: Logic ---
    @Test("Check Word Count Logic")
    func testWordCount() {
        let sheet = Sheet(content: "Hello world this is a test")
        #expect(sheet.wordCount == 6)
        
        sheet.content = "   Spaces   should   not   matter   "
        #expect(sheet.wordCount == 4)
        
        sheet.content = ""
        #expect(sheet.wordCount == 0)
    }

    // --- INTEGRATION TEST: Database ---
    @Test("Verify SwiftData Saving and Loading")
    @MainActor // Database runs on the main thread
    func testDatabaseIntegration() throws {
        // 1. Setup an "In-Memory" Database (so we don't touch your real files)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Sheet.self, configurations: config)
        let context = container.mainContext
        
        // 2. Create and Save a Note
        let newSheet = Sheet(title: "Integration Test", content: "Testing 123")
        context.insert(newSheet)
        
        // 3. Fetch it back
        let descriptor = FetchDescriptor<Sheet>()
        let savedSheets = try context.fetch(descriptor)
        
        // 4. Verify
        #expect(savedSheets.count == 1)
        #expect(savedSheets.first?.title == "Integration Test")
    }
    
    // --- INTEGRATION TEST: PDF Export ---
    @Test("Verify PDF Generation")
    @MainActor
    func testPDFCreation() {
        // We can't visually check the PDF, but we can check if the file is created
        let url = PDFCreator.createSimplePDF(title: "Test PDF", content: "This is the content", fileManager: FileHelper.self)
        
        // Check if URL is valid
        #expect(url != nil)
        
        // Check if file actually exists at that path
        let fileExists = FileManager.default.fileExists(atPath: url!.path)
        #expect(fileExists == true)
    }

    #if os(macOS)
    @Test("Verify Markdown Highlighting Logic")
    @MainActor
    func testMarkdownHighlighting() {
        // 1. Setup
        let coordinator = MacMarkdownEditor.Coordinator(
            MacMarkdownEditor(
                text: .constant(""),
                selectedRange: .constant(NSRange()),
                onTextChange: { _ in }
            )
        )
        let textView = NSTextView()
        let testString = "*bold* _italic_ -strike- <u>underline</u>"
        textView.string = testString
        
        // 2. Action
        coordinator.highlightSyntax(in: textView)
        
        // 3. Verification
        guard let attributedString = textView.textStorage else {
            Issue.record("NSTextStorage was nil")
            return
        }
        
        // Helper to find font traits
        func getTraits(for substring: String) -> NSFontDescriptor.SymbolicTraits? {
            guard let range = testString.range(of: substring) else { return nil }
            let nsRange = NSRange(range, in: testString)
            guard let font = attributedString.attribute(.font, at: nsRange.location, effectiveRange: nil) as? NSFont else { return nil }
            return font.fontDescriptor.symbolicTraits
        }
        
        // Helper to find other attributes
        func getAttributeValue(for substring: String, attr: NSAttributedString.Key) -> Any? {
            guard let range = testString.range(of: substring) else { return nil }
            let nsRange = NSRange(range, in: testString)
            return attributedString.attribute(attr, at: nsRange.location, effectiveRange: nil)
        }
        
        // Assert Bold
        let boldTraits = getTraits(for: "bold")
        #expect(boldTraits?.contains(.bold) == true, "Text 'bold' should have bold trait")
        
        // Assert Italic
        let italicTraits = getTraits(for: "italic")
        #expect(italicTraits?.contains(.italic) == true, "Text 'italic' should have italic trait")

        // Assert Strikethrough
        let strikeValue = getAttributeValue(for: "strike", attr: .strikethroughStyle) as? NSNumber
        #expect(strikeValue == NSUnderlineStyle.single.rawValue as NSNumber, "Text 'strike' should have strikethrough style")

        // Assert Underline
        let underlineValue = getAttributeValue(for: "underline", attr: .underlineStyle) as? NSNumber
        #expect(underlineValue == NSUnderlineStyle.single.rawValue as NSNumber, "Text 'underline' should have underline style")
    }
    #endif
}
