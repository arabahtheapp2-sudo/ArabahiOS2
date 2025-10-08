//
//  ContactUsVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class ContactUsVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITestContactUs")
        app.launch()
    }

    // MARK: - UI Visibility

    func testAllFieldsAreVisible() throws {
        XCTAssertTrue(app.textFields["txtName"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.textFields["txtEmail"].exists)
        XCTAssertTrue(app.textViews["txtMessage"].exists)
    }

    // MARK: - Input and Submit Success

    func testFormSubmissionSuccess() throws {
        let name = app.textFields["txtName"]
        let email = app.textFields["txtEmail"]
        let message = app.textViews["txtMessage"]

        name.tap()
        name.typeText("Test User")

        email.tap()
        email.typeText("test@example.com")

        message.tap()
        message.typeText("This is a sample message.")

        // Tap the update button (assume accessibility identifier or static label)
        app.buttons["Submit"].firstMatch.tap() // You can set an identifier if needed
        
        // Assert success alert is shown
        let successAlert = app.alerts.firstMatch
        XCTAssertTrue(successAlert.waitForExistence(timeout: 3))
        XCTAssertTrue(successAlert.staticTexts["Success"].exists) // Adjust based on actual alert content
    }

    // MARK: - Empty Form Validation Error

    func testValidationFailureForEmptyFields() throws {
        app.buttons["Submit"].firstMatch.tap()

        let validationAlert = app.alerts.firstMatch
        XCTAssertTrue(validationAlert.waitForExistence(timeout: 2))
        XCTAssertTrue(validationAlert.staticTexts.element.exists)
    }

    // MARK: - API Failure Retry Flow

    func testAPIFailureShowsRetryAlert() throws {
        app = XCUIApplication()
        app.launchArguments += ["-UITestContactUs", "-UITestContactUsAPIFail"]
        app.launch()

        let name = app.textFields["txtName"]
        let email = app.textFields["txtEmail"]
        let message = app.textViews["txtMessage"]

        name.tap()
        name.typeText("Retry User")

        email.tap()
        email.typeText("retry@example.com")

        message.tap()
        message.typeText("Triggering failure.")

        app.buttons["Submit"].firstMatch.tap()

        let errorAlert = app.alerts.firstMatch
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 3))
        XCTAssertTrue(errorAlert.buttons["Retry"].exists)
        errorAlert.buttons["Retry"].tap()

    }
}
