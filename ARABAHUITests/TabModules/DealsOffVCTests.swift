//
//  DealsOffVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class DealsOffVCTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testHeaderExists() throws {
        let headerLabel = app.staticTexts["dealsHeaderLabel"]
        XCTAssertTrue(headerLabel.exists, "Header label should exist.")
    }

    func testDealsTableLoads() throws {
        let dealsTable = app.tables["dealsTableView"]
        XCTAssertTrue(dealsTable.exists, "Deals table should exist.")

        // Wait for data to load (or simulate via mock if needed)
        let firstCell = dealsTable.cells.element(boundBy: 0)
        let exists = firstCell.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "First deal cell should be loaded.")
    }

    func testSkeletonLoadingState() throws {
        let skeletonCell = app.tables["dealsTableView"].cells.element(boundBy: 0)
        XCTAssertTrue(skeletonCell.exists, "Skeleton cell should exist while loading.")
    }

    func testTapDealCellOpensNextScreen() throws {
        let dealsTable = app.tables["dealsTableView"]
        let firstCell = dealsTable.cells.element(boundBy: 0)
        let exists = firstCell.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "Deal cell should be tappable.")
        
        firstCell.tap()

        // Optional: Check if SafariViewController or ZoomImageVC opens
        // This will need testable identifiers on destination VC
        // Example check for Safari:
        let safariNavBar = app.navigationBars["Safari"]
        let didNavigate = safariNavBar.waitForExistence(timeout: 5)
        XCTAssertTrue(didNavigate || app.otherElements["zoomImageView"].exists, "Should navigate to deal detail screen.")
    }
}

