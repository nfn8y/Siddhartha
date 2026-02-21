//
//  SiddharthaUITests.swift
//  SiddharthaUITests
//

import XCTest

final class SiddharthaUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: "com.nfn8y.Siddhartha")
        app.launchArguments = ["-UITestMode"]
        app.launch()
    }
    
    func find(_ id: String) -> XCUIElement {
        return app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    func testCreateAndEditSheet() throws {
        let addButton = find(AccessibilityIDs.SheetList.addButton)
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add Button not found")
        addButton.click()
        
        let newRowID = AccessibilityIDs.SheetList.row(title: "")
        let newSheetRow = find(newRowID)
        XCTAssertTrue(newSheetRow.waitForExistence(timeout: 3.0), "New sheet row should appear")
        
        // Find the text view directly by its new identifier
        let editor = app.textViews["siddhartha-text-view"]
        XCTAssertTrue(editor.waitForExistence(timeout: 2.0), "Editor should be visible")
        
        editor.click()
        editor.typeText("UI Test Content")
        XCTAssertEqual(editor.value as? String, "UI Test Content")
    }
    
    func testSearchFunctionality() throws {
        // 1. Open Search
        let searchToggle = find(AccessibilityIDs.SheetList.searchToggle)
        XCTAssertTrue(searchToggle.waitForExistence(timeout: 5.0))
        searchToggle.click()
        
        // 2. Verify and Type in Search Field
        // FIX: Now we target the TextField directly using the new ID
        let searchField = find(AccessibilityIDs.SheetList.searchField)
        XCTAssertTrue(searchField.waitForExistence(timeout: 2.0), "Search Field didn't appear")
        
        searchField.click()
        searchField.typeText("Banana")
        
        // 3. Verify Text Value
        XCTAssertEqual(searchField.value as? String, "Banana")
        
        // 4. Close Search
        searchToggle.click()
        
        // Wait for animation
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertFalse(searchField.exists, "Search field should disappear")
    }
    
    func testBoldShortcut() throws {
        // 1. Create a new sheet
        let addButton = find(AccessibilityIDs.SheetList.addButton)
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add Button not found")
        addButton.click()
        
        // 2. Get the editor and type text
        // Find the text view directly by its new identifier
        let editor = app.textViews["siddhartha-text-view"]
        XCTAssertTrue(editor.waitForExistence(timeout: 2.0), "Editor should be visible")
        editor.click()
        editor.typeText("world")
        
        // 3. Select the text by sending Cmd+A
        app.typeKey("a", modifierFlags: .command)

        // 4. Apply bold via shortcut
        app.typeKey("b", modifierFlags: .command)
        
        // 5. Assert the text has changed.
        // We use an expectation to wait for the UI to update asynchronously.
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == '*world*'"),
            object: editor
        )
        wait(for: [expectation], timeout: 2.0)
    }
}
