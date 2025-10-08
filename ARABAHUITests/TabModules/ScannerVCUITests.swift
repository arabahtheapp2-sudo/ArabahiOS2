//
//  ScannerVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class ScannerVCUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Test: UI Loads with Required Buttons

    func testScannerVC_UIElementsExist() throws {
        let backButton = app.otherElements["BackButtonAccessibilityID"]
        let simulateScanButton = app.otherElements["SimulateScanButtonAccessibilityID"]
        
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button should exist")
        XCTAssertTrue(simulateScanButton.exists, "Simulate Scan button should exist")
    }

    // MARK: - Test: Tap Back Button Dismisses VC

    func testBackButton_TapPopsVC() throws {
        let backButton = app.otherElements["BackButtonAccessibilityID"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Back button must exist")
        backButton.tap()
        
        // Check that ScannerVC is dismissed
        XCTAssertFalse(backButton.waitForExistence(timeout: 3), "ScannerVC should be popped after tapping back")
    }

    // MARK: - Test: Tap Simulate Button Restarts Scanning

    func testSimulateScanButton_TapRestartsScanner() throws {
        let simulateScanButton = app.otherElements["SimulateScanButtonAccessibilityID"]
        XCTAssertTrue(simulateScanButton.exists, "Simulate Scan button must exist")
        simulateScanButton.tap()
        
        // There is no UI state change, but we ensure the tap works
        // If scan result is simulated, test below can assert navigation
    }

    // MARK: - Test: Simulate Barcode Scanning → Push to SubCatDetailVC

    func testSimulatedBarcode_NavigatesToSubCatDetailVC() {
        // You must provide a way in the app to simulate scan
        // For example, tap simulate button or use test hook via environment variable
        let simulateScanButton = app.otherElements["SimulateScanButtonAccessibilityID"]
        XCTAssertTrue(simulateScanButton.waitForExistence(timeout: 3))
        simulateScanButton.tap()
        
        // After scanning, SubCatDetailVC should appear
        let subCatLabel = app.staticTexts["SubCatDetailTitle"] // Add this identifier to SubCatDetailVC
        XCTAssertTrue(subCatLabel.waitForExistence(timeout: 5), "Should navigate to SubCatDetailVC after scanning")
    }

    // MARK: - Test: Camera Permission Denied Alert

    func testCameraPermissionDenied_ShowsAlert() {
        // Use launch argument or mock to simulate denied permission
        // app.launchArguments += ["-UITestMockCameraPermission", "denied"]

        let permissionAlert = app.alerts.firstMatch
        XCTAssertTrue(permissionAlert.waitForExistence(timeout: 5), "Permission alert should appear when denied")

        let openSettingsButton = permissionAlert.buttons["Open Settings"]
        let cancelButton = permissionAlert.buttons["Cancel"]
        XCTAssertTrue(openSettingsButton.exists, "Open Settings should appear in alert")
        XCTAssertTrue(cancelButton.exists, "Cancel button should appear in alert")

        cancelButton.tap()
        // Assert ScannerVC is dismissed after cancel
        XCTAssertFalse(app.otherElements["SimulateScanButtonAccessibilityID"].exists)
    }
}
