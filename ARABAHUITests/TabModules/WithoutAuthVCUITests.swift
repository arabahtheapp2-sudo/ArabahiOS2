//
//  WithoutAuthVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class WithoutAuthVCUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITest_WithoutAuth")
        app.launch()
    }

    // MARK: - Test: UI Elements Exist
    
    func testWithoutAuthScreenUIExists() {
        let skipButton = app.buttons["skipSignInButton"]
        let signInButton = app.buttons["signInButton"]

        XCTAssertTrue(skipButton.waitForExistence(timeout: 3), "Skip Sign In button not found.")
        XCTAssertTrue(signInButton.exists, "Sign In button not found.")
    }

    // MARK: - Test: Tap Sign In Dismisses Screen
    
    func testSignInButtonDismisses() {
        let signInButton = app.buttons["signInButton"]
        XCTAssertTrue(signInButton.exists)
        signInButton.tap()

        let isDismissed = app.buttons["signInButton"].waitForExistence(timeout: 2) == false
        XCTAssertTrue(isDismissed, "Sign In screen was not dismissed.")
    }

    // MARK: - Test: Skip Sign In Behavior
    
    func testSkipSignInMovesToTabBarIfFlagTrue() {
        let skipButton = app.buttons["skipSignInButton"]
        XCTAssertTrue(skipButton.exists)
        skipButton.tap()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Did not navigate to TabBarController.")
    }
}
