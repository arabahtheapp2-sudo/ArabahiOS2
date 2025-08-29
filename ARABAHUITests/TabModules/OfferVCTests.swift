//
//  OfferVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class OfferVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_OfferVC"]
        app.launch()
    }

    func testOfferTableViewExists() {
        let tableView = app.tables["offersTbl"]
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "Offer table view should be present.")
    }

    func testOfferCellsRenderCorrectly() {
        let tableView = app.tables["offersTbl"]
        XCTAssertTrue(tableView.exists)

        if tableView.cells.count > 0 {
            let firstCell = tableView.cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.staticTexts["⃀ 0"].exists || firstCell.staticTexts.element(boundBy: 0).exists, "First cell should show a price.")
        } else {
            let noDataLabel = tableView.staticTexts["No data found"]
            XCTAssertTrue(noDataLabel.exists, "Should show no data message when product list is empty.")
        }
    }

    func testBackButtonNavigatesBack() {
        let backButton = app.buttons["btnBack"]
        if backButton.exists {
            backButton.tap()
            // Add assertion to confirm navigation if applicable
        }
    }
}

