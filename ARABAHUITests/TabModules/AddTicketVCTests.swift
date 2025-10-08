//
//  AddTicketVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class AddTicketVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_AddTicket"]
        app.launch()
    }

    func testAddTicketFormSubmission() throws {
        let titleField = app.textFields["txtFldTittle"]
        let descriptionView = app.textViews["txtViewDes"]
        let submitButton = app.buttons["SubmitButton"]

        // Wait for UI
        XCTAssertTrue(titleField.waitForExistence(timeout: 5), "Title text field should exist")
        XCTAssertTrue(descriptionView.exists, "Description text view should exist")
        XCTAssertTrue(submitButton.exists, "Submit button should exist")

        // Type title and description
        titleField.tap()
        titleField.typeText("Test Ticket")

        descriptionView.tap()
        descriptionView.typeText("This is a test ticket created by UI Test.")

        // Tap Submit
        submitButton.tap()
        // Wait a bit for loading/response
        sleep(2)


    }

    func testEmptyFieldsValidation() throws {
        let submitButton = app.buttons["SubmitButton"]
        XCTAssertTrue(submitButton.exists, "Submit button should exist")

        // Tap submit without entering data
        submitButton.tap()

        // Wait for validation alert/banner
        let alert = app.alerts.element(boundBy: 0)
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Validation alert should appear for empty fields")
    }
}
