//
//  LoginVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 04/06/25.
//

import Foundation
import XCTest

final class LoginVCTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Tests

    func testPhoneNumberFieldExists() {
        let phoneField = app.textFields["login.phoneNumberTextField"]
        XCTAssertTrue(phoneField.exists)
    }

    func testCountryCodeLabelExists() {
        let codeLabel = app.staticTexts["login.countryCodeLabel"]
        XCTAssertTrue(codeLabel.exists)
    }

    func testSignInWithEmptyPhoneShowsValidation() {
        app.buttons["login.signInButton"].tap()

        // Wait for alert
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Assert message
        let message = alert.staticTexts.element(boundBy: 1).label
        XCTAssertTrue(message.contains("Phone number is required") || message.contains("Phone number"))
    }

    func testValidPhoneTriggersNavigationToOTP() {
        let phoneField = app.textFields["login.phoneNumberTextField"]
        phoneField.tap()
        phoneField.typeText("12345678")

        app.buttons["login.signInButton"].tap()

        let otpScreen = app.staticTexts["OTP"]
        XCTAssertTrue(otpScreen.waitForExistence(timeout: 5))
    }
}
