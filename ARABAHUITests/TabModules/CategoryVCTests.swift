//
//  CategoryVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class CategoryVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_Category"]
        app.launch()
    }

    func testCategoryCollectionIsVisibleAndLoaded() throws {
        let collection = app.collectionViews["categoryCollection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 5), "Category collection view should exist")

        // Wait for at least one cell (after data loads)
        let cell = collection.cells.element(boundBy: 0)
        let exists = cell.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "At least one category cell should be loaded")
    }

    func testPullToRefreshReloadsData() throws {
        let collection = app.collectionViews["categoryCollection"]
        XCTAssertTrue(collection.exists, "Collection should exist")

        // Pull down to refresh
        let start = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let finish = collection.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
        start.press(forDuration: 0.1, thenDragTo: finish)

        // Optional: Assert UI updates, e.g. refreshControl animation or reload
        let cell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Data should reload after refresh")
    }

    func testCategoryCellTapNavigatesToSubCategory() throws {
        let collection = app.collectionViews["categoryCollection"]
        XCTAssertTrue(collection.waitForExistence(timeout: 5), "Collection should be present")

        let cell = collection.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "First category cell should exist")

        cell.tap()

        // Optional: Verify SubCategoryVC loaded (based on a known UI element)
        let subCategoryLabel = app.staticTexts["subCategoryHeaderLabel"]
        XCTAssertTrue(subCategoryLabel.waitForExistence(timeout: 5), "SubCategoryVC should be presented after tapping a category")
    }
}

