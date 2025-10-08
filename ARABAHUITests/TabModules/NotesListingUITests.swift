//
//  NotesListingUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class NotesListingUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testNotesList_DisplayAndInteraction() throws {
        // Ensure Notes screen is visible
        let notesTable = app.tables["NotesTblVieww"]
        XCTAssertTrue(notesTable.waitForExistence(timeout: 5), "Notes table should appear")

        // Wait for loading to complete
        sleep(2)  // Ideally use expectation with spinner accessibility identifier

        // Assert some rows are visible
        let cellCount = notesTable.cells.count
        XCTAssertGreaterThan(cellCount, 0, "Notes list should not be empty")

        // Tap on first note to go to detail view
        let firstCell = notesTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First note should be visible")
        firstCell.tap()

        // Assert NotesVC is visible (if it has a known UI element, like notes table)
        let notesTextTable = app.tables["notesTbl"]
        XCTAssertTrue(notesTextTable.waitForExistence(timeout: 5), "Notes detail should appear")

        // Go back
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(notesTable.waitForExistence(timeout: 2), "Should return to notes list")
    }

    func testSearchNotesFiltering() throws {
        let searchField = app.textFields["txtFldSearch"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should exist")

        searchField.tap()
        searchField.typeText("test")

        sleep(1) // Allow time for filtering

        let filteredCells = app.tables["NotesTblVieww"].cells
        XCTAssertGreaterThan(filteredCells.count, 0, "Filtered results should appear")

        // Clear search
        let deleteKey = app.keys["delete"]
        for _ in 0..<4 { deleteKey.tap() }

        XCTAssertTrue(app.tables["NotesTblVieww"].cells.count > 0, "Should return to full list")
    }

    func testAddNoteFlow() throws {
        let addButton = app.buttons["btnAdd"]
        XCTAssertTrue(addButton.exists, "Add button should exist")

        addButton.tap()

        // Confirm NotesVC appeared
        let notesTextTable = app.tables["notesTbl"]
        XCTAssertTrue(notesTextTable.waitForExistence(timeout: 3), "Should navigate to NotesVC")

        // Tap back to cancel
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    func testDeleteNoteViaSwipe() throws {
        let notesTable = app.tables["NotesTblVieww"]
        XCTAssertTrue(notesTable.waitForExistence(timeout: 5), "Notes table should appear")

        let cell = notesTable.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists, "Cell exists to delete")

        // Swipe to reveal delete
        cell.swipeLeft()

        // Tap delete
        let deleteButton = cell.buttons["deleteBtn"]
        XCTAssertTrue(deleteButton.exists, "Delete button should appear")
        deleteButton.tap()

        // Confirm popup appears
        let confirmButton = app.buttons["Confirm"] // Adjust if you named it differently
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 2), "Confirmation popup should appear")

        confirmButton.tap()
    }
}
