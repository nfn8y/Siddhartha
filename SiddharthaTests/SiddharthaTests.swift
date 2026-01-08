//
//  SiddharthaTests.swift
//  SiddharthaTests
//

import Testing
import Foundation
import SwiftData
@testable import Siddhartha // Allows us to see your App code

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
        let url = PDFCreator.createSimplePDF(title: "Test PDF", content: "This is the content")
        
        // Check if URL is valid
        #expect(url != nil)
        
        // Check if file actually exists at that path
        let fileExists = FileManager.default.fileExists(atPath: url!.path)
        #expect(fileExists == true)
    }
}
