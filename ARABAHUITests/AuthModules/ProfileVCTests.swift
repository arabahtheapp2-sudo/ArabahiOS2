//
//  ProfileVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

class ProfileVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchEnvironment["TEST_PROFILE_SCREEN"] = "1"
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Test Elements Existence
    
    func testAllUIElementsExist() {
        // Verify main profile elements
        XCTAssertTrue(app.buttons["EditProfileButton"].exists)
        XCTAssertTrue(app.images["ProfileImage"].exists)
        XCTAssertTrue(app.staticTexts["userNameLabel"].exists)
        XCTAssertTrue(app.staticTexts["phoneNumberLabel"].exists)
        XCTAssertTrue(app.tables["profileTableView"].exists)
    }
    
    // MARK: - Test Initial State
    
    func testInitialState() {
        // Verify edit profile button shows correct title
        let editButton = app.buttons["EditProfileButton"]
        XCTAssertTrue(editButton.label == "Complete Your Profile" || editButton.label == "Edit Profile")
        
        // Verify profile image exists
        XCTAssertTrue(app.images["ProfileImage"].exists)
        
        // Verify user data is displayed
        XCTAssertNotEqual(app.staticTexts["userNameLabel"].label, "")
        XCTAssertNotEqual(app.staticTexts["phoneNumberLabel"].label, "")
    }
    
    // MARK: - Test Profile Table View
    
    func testProfileTableViewSections() {
        let table = app.tables["profileTableView"]
        
        // Verify correct number of rows
        XCTAssertEqual(table.cells.count, 12)
        
        // Verify first row is notifications with toggle
        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.staticTexts["Price Notifications"].exists)
        XCTAssertTrue(firstCell.buttons["notificationToggle"].exists)
        
        // Verify last row is delete account with red text
        let lastCell = table.cells.element(boundBy: 11)
        XCTAssertTrue(lastCell.staticTexts["Delete Account"].exists)
        // Can't verify text color in UI tests, but could check accessibility trait if set
    }
    
    // MARK: - Test Navigation Flows
    
    func testEditProfileNavigation() {
        app.buttons["EditProfileButton"].tap()
        
        // Verify navigation to edit profile screen
        XCTAssertTrue(app.navigationBars["Edit Profile"].exists)
    }
    
    func testNotificationToggle() {
        let table = app.tables["profileTableView"]
        let notificationCell = table.cells.element(boundBy: 0)
        let toggle = notificationCell.buttons["notificationToggle"]
        
        // Get initial state
        let initialState = toggle.isSelected
        
        // Tap toggle
        toggle.tap()
        
        // Verify state changed
        XCTAssertNotEqual(toggle.isSelected, initialState)
        
        // Verify success alert appears
        let alert = app.alerts.element
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(alert.exists)
    }
    
    func testNavigateToFavorites() {
        let table = app.tables["profileTableView"]
        table.cells.element(boundBy: 2).tap() // Favorites row
        
        // Verify navigation to favorites screen
        XCTAssertTrue(app.navigationBars["Favorites"].exists)
    }
    
    func testNavigateToChangeLanguage() {
        let table = app.tables["profileTableView"]
        table.cells.element(boundBy: 3).tap() // Change Language row
        
        // Verify navigation to language screen
        XCTAssertTrue(app.navigationBars["Change Language"].exists)
    }
    
    // MARK: - Test Account Actions
    
    func testLogoutFlow() {
        let table = app.tables["profileTableView"]
        table.cells.element(boundBy: 10).tap() // Logout row
        
        // Verify confirmation popup appears
        let popup = app.otherElements["confirmationPopup"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: popup, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(popup.exists)
        
        // Tap confirm
        app.buttons["confirmButton"].tap()
        
        // Verify navigation to login screen
        let loginScreen = app.otherElements["loginScreen"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: loginScreen, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(loginScreen.exists)
    }
    
    func testDeleteAccountFlow() {
        let table = app.tables["profileTableView"]
        table.cells.element(boundBy: 11).tap() // Delete Account row
        
        // Verify confirmation popup appears
        let popup = app.otherElements["confirmationPopup"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: popup, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(popup.exists)
        
        // Tap confirm
        app.buttons["confirmButton"].tap()
        
        // Verify navigation to login screen
        let loginScreen = app.otherElements["loginScreen"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: loginScreen, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(loginScreen.exists)
    }
    
    // MARK: - Test Error Handling
    
    func testLogoutErrorHandling() {
        // Mock logout failure
        app.launchEnvironment["MOCK_LOGOUT_FAILURE"] = "1"
        app.activate()
        
        let table = app.tables["profileTableView"]
        table.cells.element(boundBy: 10).tap() // Logout row
        app.buttons["confirmButton"].tap() // Confirm
        
        // Verify error alert appears
        let alert = app.alerts["Error"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(alert.exists)
    }
    
    // MARK: - Test Loading States
    
    func testLoadingIndicatorDuringActions() {
        // Mock slow network response
        app.launchEnvironment["MOCK_SLOW_RESPONSE"] = "1"
        app.activate()
        
        // Tap logout
        let table = app.tables["profileTableView"]
        table.cells.element(boundBy: 10).tap() // Logout row
        app.buttons["confirmButton"].tap() // Confirm
        
        // Verify loading indicator appears
        let loadingIndicator = app.activityIndicators["In progress"]
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: loadingIndicator, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(loadingIndicator.exists)
    }
}
