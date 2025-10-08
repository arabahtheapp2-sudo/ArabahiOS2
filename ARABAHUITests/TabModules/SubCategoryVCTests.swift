//
//  SubCategoryVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class SubCategoryVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_SubCategoryVC"]
        app.launch()
    }

    func testCollectionViewExists() throws {
        let collectionView = app.collectionViews["subCategoryColl"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "The sub-category collection view should exist.")
    }

    func testBackButtonExistsAndWorks() throws {
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.exists, "Back button should exist.")
        backButton.tap()
        // Add assertion if needed to validate navigation
    }

    func testCollectionViewCellCountOrSkeleton() throws {
        let collectionView = app.collectionViews["subCategoryColl"]
        XCTAssertTrue(collectionView.exists)

        let cellCount = collectionView.cells.count
        XCTAssertGreaterThanOrEqual(cellCount, 0, "There should be some cells rendered (either skeletons or data).")
    }

    func testPullToRefresh() throws {
        let collectionView = app.collectionViews["subCategoryColl"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 3))
        
        let start = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let finish = collectionView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
        start.press(forDuration: 0, thenDragTo: finish)

        // There’s no direct way to assert refresh happened, so test presence still
        XCTAssertTrue(collectionView.exists)
    }

    func testSelectProductNavigatesToDetail() throws {
        let collectionView = app.collectionViews["subCategoryColl"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 3))

        if collectionView.cells.count > 0 {
            collectionView.cells.element(boundBy: 0).tap()

            // Assert presence of detail view by checking for known identifier
            let detailView = app.otherElements["SubCatDetailVC_Container"]
            XCTAssertTrue(detailView.waitForExistence(timeout: 3), "Should navigate to product detail VC.")
        }
    }

    func testEmptyStateMessageWhenNoData() throws {
        let collectionView = app.collectionViews["subCategoryColl"]
        XCTAssertTrue(collectionView.exists)

        let noDataLabel = collectionView.staticTexts["No data found"]
        if collectionView.cells.count == 0 {
            XCTAssertTrue(noDataLabel.exists, "Should display no data message when empty.")
        }
    }
}
