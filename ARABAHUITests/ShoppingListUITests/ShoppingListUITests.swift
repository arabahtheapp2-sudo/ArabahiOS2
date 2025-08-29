//
//  ShoppingListUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 12/08/25.
//

import XCTest

final class ShoppingListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testShoppingList_EmptyOrWithData() throws {
        // Go directly to Shopping List tab
        app.tabBars.buttons["ShoppingListTab"].tap()

        let noDataLabel = app.staticTexts["noDataLabel"]
        let shoppingListTable = app.tables["shoppingListTable"]
        let clearAllButton = app.buttons["clearAllButton"]

        // Wait for API results
        XCTAssertTrue(noDataLabel.waitForExistence(timeout: 10) || shoppingListTable.waitForExistence(timeout: 10),
                      "Shopping List should show either empty state or populated table")

        if noDataLabel.exists {
            //  Empty state checks
            XCTAssertTrue(noDataLabel.isHittable, "No data label should be visible")
            XCTAssertFalse(shoppingListTable.exists, "Table should not be visible in empty state")
            XCTAssertFalse(clearAllButton.exists, "Clear All button should not be visible in empty state")
        } else {
            // Data state checks
            XCTAssertTrue(shoppingListTable.exists, "Table should be visible when list has data")
            XCTAssertTrue(clearAllButton.exists, "Clear All button should be visible when list has data")

            // Verify first row
            let firstCell = shoppingListTable.cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "First shopping list cell should appear")

            // Check label and image presence
            XCTAssertTrue(firstCell.staticTexts.element(boundBy: 0).exists, "Cell should have a product label")
            XCTAssertTrue(firstCell.images.element(boundBy: 0).exists, "Cell should have a product image")
        }
    }
}
