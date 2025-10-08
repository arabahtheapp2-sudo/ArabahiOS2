//
//  ZoomImageVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class ZoomImageVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_ZoomImageVC"]
        app.launch()
    }
    
    func testZoomImageViewExistsAndZooms() throws {
        // Wait for the image view to appear
        let zoomImage = app.images["zoomImageView"]
        XCTAssertTrue(zoomImage.waitForExistence(timeout: 5), "Zoomable image should be visible.")
        
        // Try zoom gesture (pinch)
        zoomImage.pinch(withScale: 2.0, velocity: 1.0)
        
        // Optional: Assert image still exists after zoom
        XCTAssertTrue(zoomImage.exists, "Zoomed image should still exist.")
    }
    
    func testBackButtonPopsViewController() throws {
        let backButton = app.buttons["backButton"]
        XCTAssertTrue(backButton.exists, "Back button should exist.")
        
        backButton.tap()
        
        // Verify the VC was popped (e.g., by checking DealsOffVC is visible again)
        let dealsHeader = app.staticTexts["dealsHeaderLabel"]
        XCTAssertTrue(dealsHeader.waitForExistence(timeout: 3), "Should navigate back to Deals screen.")
    }
}
