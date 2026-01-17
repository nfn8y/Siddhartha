//
//  SiddharthaTests.swift
//  SiddharthaTests
//

import Testing
import SwiftData
import SwiftUI
@testable import Siddhartha

struct SiddharthaTests {
    
    // FIX: Added @MainActor here because we are testing UI logic (ViewModels + SwiftData)
    @Test("Add Sheet to Folder")
    @MainActor
    func testAddSheetLogic() async throws {
        // 1. SETUP: Create an in-memory database
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Sheet.self, Folder.self, configurations: config)
        
        // mainContext is an actor-isolated property, so we must be on MainActor to use it
        let context = container.mainContext
        
        // 2. SETUP: Create a folder
        let folder = Folder(name: "Test Project")
        context.insert(folder)
        
        // 3. SETUP: Create the ViewModel
        // (ViewModels often trigger UI updates, so they require MainActor)
        let viewModel = SheetListViewModel()
        
        // 4. ACT
        viewModel.addSheet(context: context, folder: folder)
        
        // 5. ASSERT
        #expect(folder.sheets?.count == 1)
        
        let createdSheet = folder.sheets?.first
        #expect(createdSheet?.folder == folder)
        
        // Since we are on MainActor, accessing selectedSheet is now safe
        #expect(viewModel.selectedSheet == createdSheet)
    }
    
    @Test("Regex Manager Safety")
    func testRegexSafety() {
        // This test doesn't touch UI, so it doesn't need @MainActor
        let manager = RegexManager.shared
        #expect(manager.headingRegex != nil)
        #expect(manager.boldRegex != nil)
    }
}
