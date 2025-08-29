//
//  HomeVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class HomeVCUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_Home"]
        app.launch()
    }

    // MARK: - Basic Load

    func testHomeScreenLoadsCorrectly() {
        let table = app.tables.element(boundBy: 0)
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Home table view did not appear.")
        XCTAssertGreaterThanOrEqual(table.cells.count, 1, "Expected table to have at least one cell.")
    }

    // MARK: - UI Elements Presence

    func testUIButtonsExist() {
        XCTAssertTrue(app.buttons["Search"].exists, "Search button not found")
        XCTAssertTrue(app.buttons["Notification"].exists, "Notification button not found")
        XCTAssertTrue(app.buttons["Location"].exists, "Location button not found")
    }

    // MARK: - Actions

    func testSearchButtonTaps() {
        let button = app.buttons["Search"]
        XCTAssertTrue(button.exists)
        button.tap()

        let searchVC = app.otherElements["SearchCategoryVCView"]
        XCTAssertTrue(searchVC.waitForExistence(timeout: 5), "SearchCategoryVC not presented.")
    }

    func testNotificationButtonTaps() {
        let button = app.buttons["Notification"]
        XCTAssertTrue(button.exists)
        button.tap()

        let notifVC = app.tables["notificationListTable"]
        XCTAssertTrue(notifVC.waitForExistence(timeout: 5), "NotificationListVC not loaded.")
    }

    func testLocationPickerOpens() {
        let button = app.buttons["Location"]
        XCTAssertTrue(button.exists)
        button.tap()

        let gmsView = app.otherElements["GMSAutocompleteViewController"]
        XCTAssertTrue(gmsView.waitForExistence(timeout: 5), "Google Places picker did not show.")
    }

    func testPullToRefreshWorks() {
        let table = app.tables.element(boundBy: 0)
        XCTAssertTrue(table.waitForExistence(timeout: 5))

        let firstCell = table.cells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let finish = start.withOffset(CGVector(dx: 0, dy: 200))
        start.press(forDuration: 0.1, thenDragTo: finish)

        // Validate refresh is triggered
        let loadingExists = app.activityIndicators.firstMatch.waitForExistence(timeout: 3)
        XCTAssertFalse(loadingExists, "Refresh spinner still active or didn't trigger.")
    }

    func testSeeAllCategoryButtonNavigates() {
        let table = app.tables.element(boundBy: 0)
        let categoryCell = table.cells.element(boundBy: 1)
        let seeAllButton = categoryCell.buttons["SeeAll"]

        if seeAllButton.exists {
            seeAllButton.tap()
            let catVC = app.otherElements["CategoryVCView"]
            XCTAssertTrue(catVC.waitForExistence(timeout: 3), "CategoryVC did not appear after See All tapped.")
        } else {
            XCTFail("See All button in categories not found.")
        }
    }

    func testSeeAllProductButtonNavigates() {
        let table = app.tables.element(boundBy: 0)
        let productCell = table.cells.element(boundBy: 2)
        let seeAllButton = productCell.buttons["SeeAll"]

        if seeAllButton.exists {
            seeAllButton.tap()
            let subCatVC = app.otherElements["SubCategoryVCView"]
            XCTAssertTrue(subCatVC.waitForExistence(timeout: 3), "SubCategoryVC did not appear after See All tapped.")
        } else {
            XCTFail("See All button in products not found.")
        }
    }
}

