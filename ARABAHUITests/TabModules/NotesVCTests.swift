//
//  NotesVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class NotesVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITest_NotesVC")
        app.launch()
    }
    
    func testTableViewExists() {
        let tableView = app.tables["notesTbl"]
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "Notes table view should exist")
    }
    
    func testEditNoteAndAddNewLine() {
        let tableView = app.tables["notesTbl"]
        XCTAssertTrue(tableView.exists)
        
        let firstCell = tableView.cells.element(boundBy: 0)
        let firstTextView = firstCell.textViews.element
        XCTAssertTrue(firstTextView.waitForExistence(timeout: 2), "First text view should exist")
        
        firstTextView.tap()
        firstTextView.clearText()
        firstTextView.typeText("This is my note")
        
        firstTextView.typeText("\n") // Simulate return key
        
        let secondCell = tableView.cells.element(boundBy: 1)
        let secondTextView = secondCell.textViews.element
        XCTAssertTrue(secondTextView.waitForExistence(timeout: 2), "New text view should be added on return key")
    }
    
    func testBackspaceRemovesEmptyLine() {
        let tableView = app.tables["notesTbl"]
        XCTAssertTrue(tableView.exists)

        // Add a new line
        let firstTextView = tableView.cells.element(boundBy: 0).textViews.element
        firstTextView.tap()
        firstTextView.typeText("\n")
        
        let newTextView = tableView.cells.element(boundBy: 1).textViews.element
        newTextView.tap()
        newTextView.typeText(XCUIKeyboardKey.delete.rawValue) // Press delete on empty line

        // After deletion, only 1 cell should remain
        sleep(1)
        XCTAssertEqual(tableView.cells.count, 1, "Empty note line should be removed")
    }
    
    func testNoDataMessageWhenEmpty() {
        let tableView = app.tables["notesTbl"]
        XCTAssertTrue(tableView.exists)
        
        if tableView.cells.count == 0 {
            let noDataLabel = tableView.staticTexts["No data found"]
            XCTAssertTrue(noDataLabel.exists, "Should show no data message when no notes")
        }
    }
    
    func testBackButtonDismissesScreen() {
        let backButton = app.buttons["btnBack"]
        XCTAssertTrue(backButton.exists)
        backButton.tap()
        // Add assert if root screen has identifier
    }

    func testDoneButtonSavesAndDismisses() {
        let doneButton = app.buttons["btnDone"]
        XCTAssertTrue(doneButton.exists)
        doneButton.tap()
        // Add assert to verify dismissal or mock save
    }
}

