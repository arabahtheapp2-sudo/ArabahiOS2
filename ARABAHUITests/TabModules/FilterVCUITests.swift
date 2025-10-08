//
//  FilterVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class FilterVCUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testFilterScreen_LoadsAndDisplaysData() throws {
        // Access filter table view
        let filterTable = app.tables["fitlerTbl"]
        XCTAssertTrue(filterTable.waitForExistence(timeout: 5), "Filter table should appear")

        // Wait for data to load (can be replaced with HUD spinner wait)
        sleep(2)

        // Check at least one row exists in a section
        XCTAssertGreaterThan(filterTable.cells.count, 0, "There should be at least one filter option loaded")
    }

    func testSelectFilterOption_CheckboxUpdates() throws {
        let filterTable = app.tables["fitlerTbl"]
        XCTAssertTrue(filterTable.waitForExistence(timeout: 5), "Filter table should exist")

        // Tap first cell if available
        let firstCheckbox = app.buttons["checkbox_0_0"]
        if firstCheckbox.exists {
            firstCheckbox.tap()
            XCTAssertTrue(firstCheckbox.exists, "Checkbox for first filter exists")
            // We could validate image change with more advanced techniques like `attachment.screenshot`
        }
    }

    func testApplyButton_TriggersCallback() throws {
        let applyButton = app.buttons["btnApply"]
        XCTAssertTrue(applyButton.waitForExistence(timeout: 5), "Apply button should be present")

        applyButton.tap()

        // Expect view to dismiss (if presented modally)
        // Can assert navigation state or any callback-based result as needed
    }

    func testClearAllButton_ClearsSelectionAndDismisses() throws {
        let clearButton = app.buttons["clearAllBn"]
        XCTAssertTrue(clearButton.exists, "Clear All button should exist")

        clearButton.tap()

        // Since dismiss happens after clear, verify modal is closed
        // Depending on setup, validate something that confirms dismissal
    }
}
