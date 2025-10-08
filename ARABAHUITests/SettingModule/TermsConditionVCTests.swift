//
//  TermsConditionVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class TermsConditionVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Optional: Use launch arguments to mock API or simulate error
        app.launchArguments += ["-UITestTermsVC"]
        app.launch()
    }
    
    // MARK: - UI Existence
    
    func testAllElementsExist() throws {
        XCTAssertTrue(app.staticTexts["headerLabel"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.textViews["contentTextView"].exists)
        XCTAssertTrue(app.buttons["backButton"].exists)
    }
    
    // MARK: - Header Title Check
    
    func testHeaderTitleMatchesContentType() throws {
        // This assumes app launches with contentType = 0 (Terms & Conditions)
        let expectedTitle = "Terms & Conditions" // Replace with actual localized value if needed
        let header = app.staticTexts["headerLabel"]
        XCTAssertTrue(header.exists)
        XCTAssertEqual(header.label, expectedTitle)
    }
    
    // MARK: - Content Loads
    
    func testContentTextLoadsProperly() throws {
        let textView = app.textViews["contentTextView"]
        XCTAssertTrue(textView.waitForExistence(timeout: 5))
        XCTAssertFalse(textView.value as? String == "", "Content text should not be empty")
    }
    
    // MARK: - Back Button Navigation
    
    func testBackButtonNavigatesBack() throws {
        let back = app.buttons["backButton"]
        XCTAssertTrue(back.exists)
        back.tap()
        
    }
    
    // MARK: - API Failure Handling (if mockable)

    func testAPIFailureShowsAlert() throws {
        app = XCUIApplication()
        app.launchArguments += ["-UITestTermsVC", "-UITestFailTermsAPI"]
        app.launch()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.buttons["Retry"].exists)
        
        alert.buttons["Retry"].tap()
        
    }
}
