//
//  FavProductVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class FavProductVCUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITest_FavProductVC"]
        app.launch()
    }

    func testCollectionViewLoadsFavoriteItems() throws {
        let collectionView = app.collectionViews["favProdCollection"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(collectionView.cells.count, 0, "No favorite items loaded.")
    }

    func testTappingFavoriteIconDislikesItem() throws {
        let collectionView = app.collectionViews["favProdCollection"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))

        let cell = collectionView.cells.element(boundBy: 0)
        let favButton = cell.buttons.element(boundBy: 0)
        XCTAssertTrue(favButton.exists)

        let wasSelected = favButton.isSelected
        favButton.tap()
        sleep(1) // wait for Combine binding + animation

        XCTAssertNotEqual(favButton.isSelected, wasSelected, "Favorite button state didn't toggle.")
    }

    func testSelectingItemNavigatesToDetailScreen() throws {
        let collectionView = app.collectionViews["favProdCollection"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))

        let cell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists)

        cell.tap()

        let detailScreenLabel = app.staticTexts["lblProName"]
        XCTAssertTrue(detailScreenLabel.waitForExistence(timeout: 5), "Did not navigate to product detail.")
    }

    func testBackButtonDismissesScreen() throws {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.tabBars.firstMatch.exists || app.otherElements["homeView"].exists, "Back did not return to home.")
    }

    func testNoDataMessageWhenEmpty() throws {
        // Optionally launch with no data
        app.terminate()
        app.launchArguments += ["-UITest_FavProductVC_NoData"]
        app.launch()

        let noDataView = app.collectionViews["favProdCollection"].staticTexts["noDataLabel"]
        XCTAssertTrue(noDataView.waitForExistence(timeout: 5), "No Data message not shown when expected.")
    }
}
