//
//  ReportVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class ReportVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_Report"]
        app.launch()
    }

    func testReportFormSubmission() throws {
        let textView = app.textViews["txtView"]
        let submitButton = app.buttons["BtnSubmit"]

        XCTAssertTrue(textView.waitForExistence(timeout: 5), "Report textView should exist.")
        XCTAssertTrue(submitButton.exists, "Submit button should exist.")

        // Enter message
        textView.tap()
        textView.typeText("This is a test report from UI test.")

        // Tap Submit
        submitButton.tap()

        // Optional: Wait for success alert or dismissal
        let successAlert = app.staticTexts["Reported scuccessfully"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 5), "Success alert should be visible.")
    }

    func testEmptyReportShowsValidationAlert() throws {
        let submitButton = app.buttons["BtnSubmit"]
        XCTAssertTrue(submitButton.exists, "Submit button should exist.")

        // Tap without entering text
        submitButton.tap()

        // Validation error should appear
        let errorAlert = app.staticTexts["Please enter message"] // or use specific localized message
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 3), "Validation alert should appear.")
    }

    func testCrossButtonDismissesReportScreen() throws {
        let closeButton = app.buttons["btnCross"]
        XCTAssertTrue(closeButton.exists, "Close button should exist.")
        closeButton.tap()

        // Assert dismissal (depends on what's underneath)
        let previousView = app.otherElements["previousScreenIdentifier"]
        XCTAssertTrue(previousView.waitForExistence(timeout: 3), "Previous screen should be shown after dismiss.")
    }
}
