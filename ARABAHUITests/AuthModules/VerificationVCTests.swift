//
//  VerificationVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

class VerificationVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchEnvironment["TEST_VERIFICATION_SCREEN"] = "1"
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Test Elements Existence
    
    func testAllUIElementsExist() {
        // Verify all main UI elements are present
        XCTAssertTrue(app.buttons["verification.resendButton"].exists)
        XCTAssertTrue(app.buttons["verification.verifyButton"].exists)
        XCTAssertTrue(app.staticTexts["verification.timerLabel"].exists)
        XCTAssertTrue(app.staticTexts["verification.phoneNumberLabel"].exists)
        
        // Verify all OTP text fields exist
        for index in 1...4 {
            XCTAssertTrue(app.textFields["verification.otpTextField\(index)"].exists)
        }
        
        // Verify the border views exist
        XCTAssertTrue(app.otherElements["viewOne"].exists)
        XCTAssertTrue(app.otherElements["viewTwo"].exists)
        XCTAssertTrue(app.otherElements["viewThree"].exists)
        XCTAssertTrue(app.otherElements["viewFour"].exists)
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        let resendButton = app.buttons["verification.resendButton"]
        let verifyButton = app.buttons["verification.verifyButton"]
        let timerLabel = app.staticTexts["verification.timerLabel"]
        
        // Verify resend button is initially disabled
        XCTAssertFalse(resendButton.isEnabled)
        
        // Verify timer shows initial countdown
        XCTAssertEqual(timerLabel.label, "05:00")
        
        // Verify verify button is enabled
        XCTAssertTrue(verifyButton.isEnabled)
        
        // Verify all OTP fields are empty
        for index in 1...4 {
            let otpField = app.textFields["verification.otpTextField\(index)"]
            XCTAssertEqual(otpField.value as? String, "")
        }
    }
    
    // MARK: - Test OTP Input Flow
    
    func testOTPInputNavigation() {
        let otpField1 = app.textFields["verification.otpTextField1"]
        let otpField2 = app.textFields["verification.otpTextField2"]
        let otpField3 = app.textFields["verification.otpTextField3"]
        let otpField4 = app.textFields["verification.otpTextField4"]
        
        // Tap first field and enter digit
        otpField1.tap()
        otpField1.typeText("1")
        
        // Verify focus moves to second field
        XCTAssertTrue(otpField2.hasFocus())
        otpField2.typeText("2")
        
        // Verify focus moves to third field
        XCTAssertTrue(otpField3.hasFocus())
        otpField3.typeText("3")
        
        // Verify focus moves to fourth field
        XCTAssertTrue(otpField4.hasFocus())
        otpField4.typeText("4")
        
        // Verify focus is resigned after last digit
        XCTAssertFalse(otpField4.hasFocus())
    }
    
    func testOTPBackspaceNavigation() {
        let otpField1 = app.textFields["verification.otpTextField1"]
        let otpField2 = app.textFields["verification.otpTextField2"]
        
        // Enter some digits
        otpField1.tap()
        otpField1.typeText("1")
        otpField2.typeText("2")
        
        // Press backspace on second field
        otpField2.typeText(XCUIKeyboardKey.delete.rawValue)
        
        // Verify focus moves back to first field
        XCTAssertTrue(otpField1.hasFocus())
        XCTAssertEqual(otpField1.value as? String, "1")
        XCTAssertEqual(otpField2.value as? String, "")
    }
    
    // MARK: - Test Timer Functionality
    
    func testResendButtonEnablesAfterTimeout() {
        let resendButton = app.buttons["verification.resendButton"]
        let timerLabel = app.staticTexts["verification.timerLabel"]
        
        // Fast-forward time (in a real test you'd mock the timer)
        // This is just verifying the UI state changes
        // In practice, you'd want to mock the timer in unit tests
        
        // Wait for timer to expire (adjust based on your actual timeout)
        let expectation = XCTestExpectation(description: "Wait for timer to expire")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        // Verify resend button is enabled and timer label is empty
        XCTAssertTrue(resendButton.isEnabled)
        XCTAssertEqual(timerLabel.label, "")
    }
    
    // MARK: - Test Verification Flow
    
    func testSuccessfulVerification() {
        // Mock successful verification response
        app.launchEnvironment["MOCK_VERIFICATION_SUCCESS"] = "1"
        
        // Enter OTP
        enterOTP("1234")
        
        // Tap verify button
        app.buttons["verification.verifyButton"].tap()
        
        // Verify navigation to main screen
        let tabBar = app.tabBars.element
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: tabBar, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(tabBar.exists)
    }
    
    func testFailedVerification() {
        // Mock failed verification response
        app.launchEnvironment["MOCK_VERIFICATION_FAILURE"] = "1"
        
        // Enter OTP
        enterOTP("1234")
        
        // Tap verify button
        app.buttons["verification.verifyButton"].tap()
        
        // Verify error alert is shown
        let alert = app.alerts["ARABAH"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(alert.exists)
        
        // Verify OTP fields are cleared if needed
        // (This would depend on your error.shouldClearOTPFields logic)
    }
    
    // MARK: - Test Resend OTP Flow
    
    func testResendOTP() {
        // First wait for timer to expire or mock it
        let resendButton = app.buttons["verification.resendButton"]
        
        // Mock timer expired state
        app.launchEnvironment["MOCK_TIMER_EXPIRED"] = "1"
        app.activate()
        
        // Verify resend button is enabled
        XCTAssertTrue(resendButton.isEnabled)
        
        // Mock successful resend response
        app.launchEnvironment["MOCK_RESEND_SUCCESS"] = "1"
        
        // Tap resend button
        resendButton.tap()
        
        // Verify timer is reset
        let timerLabel = app.staticTexts["verification.timerLabel"]
        XCTAssertEqual(timerLabel.label, "05:00")
        
        // Verify OTP fields are cleared
        for index in 1...4 {
            let otpField = app.textFields["verification.otpTextField\(index)"]
            XCTAssertEqual(otpField.value as? String, "")
        }
        
        // Verify first field has focus
        XCTAssertTrue(app.textFields["verification.otpTextField1"].hasFocus())
    }
    
    // MARK: - Helper Methods
    
    private func enterOTP(_ otp: String) {
        guard otp.count == 4 else { return }
        
        let digits = Array(otp)
        for (index, digit) in digits.enumerated() {
            let otpField = app.textFields["verification.otpTextField\(index + 1)"]
            otpField.tap()
            otpField.typeText(String(digit))
        }
    }
}

// Extension to check if text field has focus
extension XCUIElement {
    func hasFocus() -> Bool {
        let hasKeyboardFocus = (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
        return hasKeyboardFocus
    }
}
