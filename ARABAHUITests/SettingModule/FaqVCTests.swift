//
//  FaqVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest


class FaqVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        
      
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testFaqTableViewExists() {
        let faqTableView = app.tables["faqTableView"]
        XCTAssertTrue(faqTableView.exists, "FAQ table view should exist")
    }
    
    func testFaqCellsExist() {
        let faqTableView = app.tables["faqTableView"]
        XCTAssertGreaterThan(faqTableView.cells.count, 0, "There should be at least one FAQ cell")
    }
    
    func testFaqCellExpansion() {
        let faqTableView = app.tables["faqTableView"]
        let firstCell = faqTableView.cells.element(boundBy: 0)
        let expandButton = firstCell.buttons["faqExpandButton"]
        let answerLabel = firstCell.staticTexts["faqAnswerLabel"]
        
        // Initially answer should be hidden
        XCTAssertEqual(answerLabel.label, "", "Answer should be initially hidden")
        
        // Tap to expand
        expandButton.tap()
        
        // After tapping, answer should be visible
        XCTAssertNotEqual(answerLabel.label, "", "Answer should be visible after tapping")
        
        // Tap again to collapse
        expandButton.tap()
        
        // After second tap, answer should be hidden again
        XCTAssertEqual(answerLabel.label, "", "Answer should be hidden after second tap")
    }
    
    func testBackButton() {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.exists, "Back button should exist")
        backButton.tap()
        
        // Verify we navigated back
        // This depends on your app's navigation structure
        // XCTAssertFalse(app.tables["faqTableView"].exists, "FAQ screen should be dismissed")
    }
    
    func testNoDataMessage() {
        // To test this, we'd need to mock empty response
        // This would require launching with a specific argument to simulate empty state
        let app = XCUIApplication()
        app.launchArguments.append("--emptyFaq")
        app.launch()
       
        
        let faqTableView = app.tables["faqTableView"]
        XCTAssertEqual(faqTableView.cells.count, 0, "No cells should exist for empty state")
        // Would need to verify the no data message is shown
    }
    
    func testErrorStateAndRetry() {
        // Launch with failure mode
        let app = XCUIApplication()
        app.launchArguments.append("--faqFailure")
        app.launch()
        
        // Verify alert is shown
        let alert = app.alerts["ARABAH"]
        XCTAssertTrue(alert.exists, "Error alert should be shown")
        
        // Test retry button
        let retryButton = alert.buttons["Retry"]
        XCTAssertTrue(retryButton.exists, "Retry button should exist")
        retryButton.tap()
        
        // After retry, we should see the table (assuming retry succeeds)
        // In a real test, you'd want to mock a successful response after retry
        let faqTableView = app.tables["faqTableView"]
        XCTAssertTrue(faqTableView.waitForExistence(timeout: 5), "Table should appear after retry")
    }
    
    func testCellContentFormatting() {
        let faqTableView = app.tables["faqTableView"]
        let firstCell = faqTableView.cells.element(boundBy: 0)
        
        // Verify question exists
        let questionLabel = firstCell.staticTexts.element(boundBy: 0)
        XCTAssertFalse(questionLabel.label.isEmpty, "Question should not be empty")
        
        // Expand to see answer
        firstCell.buttons["faqExpandButton"].tap()
        
        // Verify answer exists
        let answerLabel = firstCell.staticTexts["faqAnswerLabel"]
        XCTAssertFalse(answerLabel.label.isEmpty, "Answer should not be empty when expanded")
        
        // Verify corner radius changes (this would be visual, but we can check the cell's frame)
        // This is more of a visual regression test which would need snapshot testing
    }
}
