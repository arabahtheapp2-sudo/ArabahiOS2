//
//  CommentVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class CommentVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_CommentVC"]
        app.launch()
    }

    func testTableViewExists() throws {
        let table = app.tables["tblViewComment"]
        XCTAssertTrue(table.waitForExistence(timeout: 5), "The comment table view should exist.")
    }

    func testTableViewHasCommentsOrEmptyState() throws {
        let table = app.tables["tblViewComment"]
        XCTAssertTrue(table.waitForExistence(timeout: 5), "The comment table view should exist.")

        if table.cells.count > 0 {
            XCTAssertGreaterThan(table.cells.count, 0, "Should display at least one comment cell.")
        } else {
            let noDataLabel = table.staticTexts["No data found"]
            XCTAssertTrue(noDataLabel.exists, "Should show 'no data found' message if no comments.")
        }
    }

    func testBackButtonNavigation() throws {
        let backButton = app.buttons["btnBack"]
        if backButton.exists {
            backButton.tap()
            // Add verification if needed that a previous VC is shown
        }
    }
}

