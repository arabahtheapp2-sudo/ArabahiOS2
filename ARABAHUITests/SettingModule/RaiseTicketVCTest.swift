//
//  RaiseTicketVCTest.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class RaiseTicketVCTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Test: UI Elements Present

    func testUIElementsArePresent() throws {
        // Verify navigation bar/back button
        XCTAssertTrue(app.buttons["btnBack"].waitForExistence(timeout: 2))

        // Verify Add Ticket Button exists
        XCTAssertTrue(app.buttons["addTicketBtn"].exists)

        // Verify TableView exists
        XCTAssertTrue(app.tables["ticketTblView"].exists)
    }

    // MARK: - Test: Tap Add Ticket Button

    func testTapAddTicketButtonNavigatesToAddTicketVC() throws {
        let addTicketBtn = app.buttons["addTicketBtn"]
        XCTAssertTrue(addTicketBtn.waitForExistence(timeout: 2))
        addTicketBtn.tap()

        // After tapping, assert AddTicketVC is pushed (identify an element from AddTicketVC)
        let addTicketTitle = app.navigationBars["Add Ticket"] // Change if your AddTicketVC has a specific title
        XCTAssertTrue(addTicketTitle.waitForExistence(timeout: 2))
    }

    // MARK: - Test: Table View Cell Population

    func testTicketListHasCellsWhenDataIsPresent() throws {
        let ticketTable = app.tables["ticketTblView"]

        XCTAssertTrue(ticketTable.waitForExistence(timeout: 3))

        // Wait for table to load and assert minimum 1 cell (mocked ticket)
        let firstCell = ticketTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 3))
    }

    // MARK: - Test: No Data State

    func testNoDataStateShowsPlaceholder() throws {
        let table = app.tables["ticketTblView"]
        XCTAssertTrue(table.exists)

        // If using a static text label inside the backgroundView
        let noDataLabel = app.staticTexts["noDataFound"]
        XCTAssertTrue(noDataLabel.waitForExistence(timeout: 3))
    }
}
