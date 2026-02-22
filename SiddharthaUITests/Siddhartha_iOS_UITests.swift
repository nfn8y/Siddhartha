//
//  Siddhartha_iOS_UITests.swift
//  SiddharthaUITests
//

import XCTest

#if os(iOS)
final class Siddhartha_iOS_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // It's crucial to initialize a new XCUIApplication instance for each test
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
        app.launch()
        
        // On iPhone, we start at the Library/Folder list. 
        // We need to navigate into a folder (Inbox) to see the sheets.
        let inbox = app.staticTexts["Inbox"]
        if inbox.waitForExistence(timeout: 5) {
            inbox.tap()
        }
    }

    func testCreateAndEditTextOnIOS() throws {
        // 1. Find and tap the "Add Sheet" button
        let addButton = app.buttons[AccessibilityIDs.SheetList.addButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add button not found")
        addButton.tap()

        // 2. Find the editor and type text
        let editor = app.textViews["siddhartha-text-view"]
        XCTAssertTrue(editor.waitForExistence(timeout: 2), "Editor text view not found")
        editor.tap()
        editor.typeText("Hello iOS")

        // 3. Verify the text was entered correctly
        XCTAssertEqual(editor.value as? String, "Hello iOS")
    }

    func testSearchOnIOS() throws {
        // Pre-condition: Create a sheet to search for
        let addButton = app.buttons[AccessibilityIDs.SheetList.addButton]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        let editor = app.textViews["siddhartha-text-view"]
        XCTAssertTrue(editor.waitForExistence(timeout: 2))
        editor.tap()
        editor.typeText("Magic search keyword")
        
        // Go back to the list view
        app.buttons["Inbox"].tap()

        // 1. Tap the search button to show the search bar
        let searchButton = app.buttons[AccessibilityIDs.SheetList.searchToggle]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 2))
        searchButton.tap()

        // 2. Type in the search field
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("Magic")

        // 3. Verify that the sheet is still visible
        let sheetRow = app.buttons[AccessibilityIDs.SheetList.row(title: "Magic search keyword")]
        XCTAssertTrue(sheetRow.exists)

        // 4. Search for something that doesn't exist
        // Clear the text field first
        searchField.buttons.firstMatch.tap() // Usually there's a clear button
        searchField.typeText("Zebra")

        // 5. Verify the original sheet is no longer visible
        XCTAssertFalse(sheetRow.exists)
    }
    
    func testPDFExportOnIOS() throws {
        // 1. Create a sheet
        app.buttons[AccessibilityIDs.SheetList.addButton].tap()

        // 2. Tap the export button (sharesheet)
        let exportButton = app.buttons["Export as PDF"]
        XCTAssertTrue(exportButton.waitForExistence(timeout: 2))
        exportButton.tap()
        
        // 3. Verify the Activity/Share Sheet appears
        // The share sheet is identified as "ActivityListView" by the accessibility system
        let shareSheet = app.otherElements["ActivityListView"]
        XCTAssertTrue(shareSheet.waitForExistence(timeout: 5), "Share sheet did not appear")
    }
}
#endif
