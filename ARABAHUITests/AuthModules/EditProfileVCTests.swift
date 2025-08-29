//
//  EditProfileVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import ARABAH
class EditProfileVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchEnvironment["TEST_EDIT_PROFILE"] = "1"
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Test Elements Existence
    
    func testAllUIElementsExist() {
        // Verify all main UI elements are present
        XCTAssertTrue(app.textFields["editProfile.nameTextField"].exists)
        XCTAssertTrue(app.textFields["editProfile.emailTextField"].exists)
        XCTAssertTrue(app.buttons["editProfile.submitButton"].exists)
        XCTAssertTrue(app.images["profileImageView"].exists)
        XCTAssertTrue(app.textFields["phoneNumberTextField"].exists)
        XCTAssertTrue(app.images["countryFlag"].exists)
        XCTAssertTrue(app.staticTexts["countryCodeLabel"].exists)
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Verify fields are populated with user data
        let nameField = app.textFields["editProfile.nameTextField"]
        let emailField = app.textFields["editProfile.emailTextField"]
        let phoneField = app.textFields["phoneNumberTextField"]
        
        XCTAssertNotEqual(nameField.value as? String, "")
        XCTAssertNotEqual(emailField.value as? String, "")
        XCTAssertNotEqual(phoneField.value as? String, "")
        
        // Verify phone field is disabled
        XCTAssertFalse(phoneField.isEnabled)
        
        // Verify profile image exists
        XCTAssertTrue(app.images["profileImageView"].exists)
    }
    
    // MARK: - Test Field Validation
    
    func testNameFieldValidation() {
        let nameField = app.textFields["editProfile.nameTextField"]
        let submitButton = app.buttons["editProfile.submitButton"]
        
        // Clear name field
        nameField.tap()
        nameField.clearText()
        
        // Attempt to submit
        submitButton.tap()
        
        // Verify validation error appears
        let alert = app.alerts["ARABAH"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(alert.exists)
    }
    
    func testEmailFieldValidation() {
        let emailField = app.textFields["editProfile.emailTextField"]
        let submitButton = app.buttons["editProfile.submitButton"]
        
        // Enter invalid email
        emailField.tap()
        emailField.clearText()
        emailField.typeText("invalid-email")
        
        // Attempt to submit
        submitButton.tap()
        
        // Verify validation error appears
        let alert = app.alerts["ARABAH"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(alert.exists)
    }
    
    // MARK: - Test Profile Update
    
    func testSuccessfulProfileUpdate() {
        // Mock successful update response
        app.launchEnvironment["MOCK_UPDATE_SUCCESS"] = "1"
        app.activate()
        
        let nameField = app.textFields["editProfile.nameTextField"]
        let submitButton = app.buttons["editProfile.submitButton"]
        
        // Update name
        nameField.tap()
        nameField.clearText()
        nameField.typeText("New Test Name")
        
        // Submit changes
        submitButton.tap()
        
        // Verify success alert and navigation back
        let alert = app.alerts["ARABAH"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(alert.exists)
        
        // Verify navigation back to profile screen
        let profileScreen = app.navigationBars["Profile"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: profileScreen, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(profileScreen.exists)
    }
    
    func testProfileImageUpdate() {
        // Note: Testing actual image picker is challenging in UI tests
        // This would test the image selection button tap
        // In practice, you might want to mock this in unit tests
        
        let imageButton = app.buttons["profileImageButton"]
        imageButton.tap()
        
        // Verify image picker is presented
        // This would depend on your image picker implementation
        // You might check for a system alert requesting photo access
    }
    
    // MARK: - Test Error Handling
    
    func testFailedProfileUpdate() {
        // Mock failed update response
        app.launchEnvironment["MOCK_UPDATE_FAILURE"] = "1"
        app.activate()
        
        let submitButton = app.buttons["editProfile.submitButton"]
        submitButton.tap()
        
        // Verify error alert with retry option appears
        let alert = app.alerts["ARABAH"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.buttons["Retry"].exists)
    }
    
    // MARK: - Test Navigation
    
    func testBackButtonNavigation() {
        app.buttons["backButton"].tap()
        
        // Verify navigation back to profile screen
        let profileScreen = app.navigationBars["Profile"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: profileScreen, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(profileScreen.exists)
    }
    
    // MARK: - Test Loading State
    
    func testLoadingIndicatorDuringUpdate() {
        // Mock slow network response
        app.launchEnvironment["MOCK_SLOW_RESPONSE"] = "1"
        app.activate()
        
        let submitButton = app.buttons["editProfile.submitButton"]
        submitButton.tap()
        
        // Verify loading indicator appears
        let loadingIndicator = app.activityIndicators["In progress"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: loadingIndicator, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(loadingIndicator.exists)
    }
}

// Helper extension to clear text fields
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        // Tap to focus
        tap()
        
        // Select all text and delete it
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
