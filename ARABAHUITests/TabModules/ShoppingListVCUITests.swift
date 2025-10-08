//
//  ShoppingListVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class ShoppingListVCUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Test 1: List Load & Display

    func testShoppingList_LoadsSuccessfully() throws {
        let table = app.tables["shoppingListTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Shopping list table should exist")

        // Wait for data load
        sleep(2)

        // At least one cell (excluding header/footer)
        XCTAssertGreaterThanOrEqual(table.cells.count, 3, "There should be at least one product in the list")
    }

    // MARK: - Test 2: Swipe to Delete Product

    func testSwipeToDeleteProduct_ShowsPopup() throws {
        let table = app.tables["shoppingListTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Shopping list table should exist")

        // Swipe the 2nd cell (1st actual product if 0 is header)
        let productCell = table.cells["shoppingListCell_1"]
        XCTAssertTrue(productCell.exists, "Product cell exists")
        productCell.swipeLeft()

        // Check delete button appears
        let deleteBtn = app.buttons["Delete"]
        XCTAssertTrue(deleteBtn.exists, "Delete button should appear")
        deleteBtn.tap()

        // Check that confirmation popup appears
        let popup = app.otherElements["popUpVC"]
        XCTAssertTrue(popup.waitForExistence(timeout: 2), "Confirmation popup should appear")
    }

    // MARK: - Test 3: Clear All Button

    func testClearAllButton_ClearsList() throws {
        let clearBtn = app.buttons["clearAllButton"]
        XCTAssertTrue(clearBtn.exists, "Clear All button should exist")
        clearBtn.tap()

        // Expect popup confirmation
        let popup = app.otherElements["popUpVC"]
        XCTAssertTrue(popup.waitForExistence(timeout: 2), "Clear All confirmation popup should appear")
    }

    // MARK: - Test 4: Empty State

    func testEmptyState_ShowsNoDataMessage() throws {
        let noDataLabel = app.staticTexts["noDataLabel"]
        
        // Simulate empty list if needed by clearing auth or mocking
        // Here assuming it’s already empty
        sleep(2)

        if noDataLabel.exists {
            XCTAssertEqual(noDataLabel.label, "No Data Found", "Empty state message should match")
        } else {
            XCTFail("No data label should be visible when list is empty")
        }
    }
}
