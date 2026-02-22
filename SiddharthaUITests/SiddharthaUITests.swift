//
//  SiddharthaUITests.swift
//  SiddharthaUITests
//

import XCTest

final class SiddharthaUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
        app.launch()
    }
    
    func find(_ id: String) -> XCUIElement {
        return app.buttons[id]
    }

    func testCreateAndEditSheet() throws {
        let addButton = app.buttons[AccessibilityIDs.SheetList.addButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add Button not found")
        addButton.click()
        
        let newRowID = AccessibilityIDs.SheetList.row(title: "")
        let newSheetRow = find(newRowID)
        XCTAssertTrue(newSheetRow.waitForExistence(timeout: 3.0), "New sheet row should appear")
        
        // Find the text view directly by its new identifier
        let editor = app.textViews[AccessibilityIDs.Editor.mainText]
        XCTAssertTrue(editor.waitForExistence(timeout: 2.0), "Editor should be visible")
        
        editor.click()
        editor.typeText("UI Test Content")
        XCTAssertEqual(editor.value as? String, "UI Test Content")
    }
    
    func testSearchFunctionality() throws {
        // 1. Open Search
        let searchToggle = app.buttons[AccessibilityIDs.SheetList.searchToggle]
        XCTAssertTrue(searchToggle.waitForExistence(timeout: 5.0))
        searchToggle.click()
        
        // 2. Verify and Type in Search Field
        // Using firstMatch for searchFields as .searchable generates the field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2.0), "Search Field didn't appear")
        XCTAssertTrue(searchField.isHittable, "Search Field should be hittable")
        
        searchField.click()
        searchField.typeText("Banana")
        
        // 3. Verify Text Value
        XCTAssertEqual(searchField.value as? String, "Banana")
        
        // 4. Close Search
        searchToggle.click()
    }
    
    func testBoldShortcut() throws {
        // 1. Create a new sheet
        let addButton = app.buttons[AccessibilityIDs.SheetList.addButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add Button not found")
        addButton.click()
        
        // 2. Get the editor and type text
        // Find the text view directly by its new identifier
        let editor = app.textViews[AccessibilityIDs.Editor.mainText]
        XCTAssertTrue(editor.waitForExistence(timeout: 2.0), "Editor should be visible")
        editor.click()
        editor.typeText("world")
        
        // 3. Select the text by sending Cmd+A
        app.typeKey("a", modifierFlags: .command)

        // 4. Apply bold via shortcut
        app.typeKey("b", modifierFlags: .command)
        
        // 5. Assert the text has changed.
        // Using the built-in expectation helper which is more integrated with XCTestCase
        let predicate = NSPredicate(format: "value == '*world*'")
        expectation(for: predicate, evaluatedWith: editor, handler: nil)
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
