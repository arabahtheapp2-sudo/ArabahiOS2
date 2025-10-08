//
//  ChangeLangVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class ChangeLangVCTests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Enable UI test mock (optional, if implemented in app)
        app.launchArguments.append("-UITestMockLanguageAPI")

        app.launch()
    }

    // MARK: - UI Elements Presence

    func testAllElementsExist() throws {
        XCTAssertTrue(app.otherElements["viewArabic"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["viewEng"].exists)
        XCTAssertTrue(app.staticTexts["Arabic"].exists)
        XCTAssertTrue(app.staticTexts["English"].exists)
        XCTAssertTrue(app.buttons["BtnArabic"].exists)
        XCTAssertTrue(app.buttons["BtnEng"].exists)
        XCTAssertTrue(app.buttons["BtnUpdate"].exists)
    }

    // MARK: - Language Toggle Test

    func testSelectArabicLanguage() throws {
        let arabicBtn = app.buttons["BtnArabic"]
        XCTAssertTrue(arabicBtn.exists)
        arabicBtn.tap()
        
        // Assert Arabic view is selected (e.g., check its background color via trait or selection indicator if testable)
        // Add custom logic if your app supports selection markers or text color indicators
    }

    func testSelectEnglishLanguage() throws {
        let englishBtn = app.buttons["BtnEng"]
        XCTAssertTrue(englishBtn.exists)
        englishBtn.tap()
    }

    // MARK: - Update Language Flow

    func testUpdateLanguageTriggersAPICall() throws {
        let arabicBtn = app.buttons["BtnArabic"]
        arabicBtn.tap()

        let updateBtn = app.buttons["BtnUpdate"]
        XCTAssertTrue(updateBtn.exists)
        updateBtn.tap()
        
        // Optional: Check for activity indicator or transition to root VC
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Expected to land on TabBarController after update")
    }
    
    // MARK: - API Error Handling (If Mocks Set Up)

    func testAPIFailureShowsAlert() throws {
        // Launch with a mock failure state if handled
        app.launchArguments.append("-UITestLangAPIFailure")
        app.launch()

        app.buttons["BtnArabic"].tap()
        app.buttons["BtnUpdate"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        XCTAssertTrue(alert.staticTexts["Retry"].exists)

        alert.buttons["Retry"].tap()
    }
}
