//
//  WalkThroughVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

class WalkThroughVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testWalkThroughFlow() {
        // Launch the app
        app.launch()
        
        // Verify initial state
        let walkThroughCV = app.collectionViews["WalkThroughCV"]
        XCTAssertTrue(walkThroughCV.exists, "Walkthrough collection view should exist")
        
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists, "Next button should exist")
        
        // Test page control visibility based on number of pages
        let pageControl = app.otherElements["pageControl"]
        if walkThroughCV.cells.count > 1 {
            XCTAssertTrue(pageControl.exists, "Page control should be visible when there are multiple pages")
        } else {
            XCTAssertFalse(pageControl.exists, "Page control should be hidden when there's only one page")
        }
        
        // Test navigation through pages
        if walkThroughCV.cells.count > 1 {
            // Swipe left to go to next page
            walkThroughCV.swipeLeft()
            
            // Verify page control updates
            // (Note: We can't directly verify the page control's current page as it's custom)
            
            // Tap next button
            nextButton.tap()
            
            // After last page, should navigate to TabBarController
            if walkThroughCV.cells.count == 2 { // Assuming we have 2 pages for this test
                let tabBar = app.tabBars.element
                expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: tabBar, handler: nil)
                waitForExpectations(timeout: 5, handler: nil)
                XCTAssertTrue(tabBar.exists, "Should navigate to tab bar controller after last walkthrough page")
            }
        } else {
            // Single page - tapping next should go directly to main screen
            nextButton.tap()
            let tabBar = app.tabBars.element
            expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: tabBar, handler: nil)
            waitForExpectations(timeout: 5, handler: nil)
            XCTAssertTrue(tabBar.exists, "Should navigate to tab bar controller after single walkthrough page")
        }
    }
    
    func testAutoLoginStorage() {
        // Launch the app
        app.launch()
        
        // Go through walkthrough
        let nextButton = app.buttons["Next"]
        nextButton.tap()
        
        // Terminate and relaunch to test auto-login
        app.terminate()
        app.launch()
        
        // Should go directly to main screen if autoLogin was stored
        let tabBar = app.tabBars.element
        expectation(for: NSPredicate(format: "exists == 1"), evaluatedWith: tabBar, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(tabBar.exists, "Should auto-login and show tab bar controller on subsequent launches")
    }
    
    func testWalkThroughContent() {
        // Launch the app
        app.launch()
        
        // Verify at least one walkthrough image is displayed
        let walkThroughCV = app.collectionViews["WalkThroughCV"]
        let firstCell = walkThroughCV.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First walkthrough cell should exist")
        
        // Verify the image exists in the first cell
        let image = firstCell.images.element
        XCTAssertTrue(image.exists, "Walkthrough image should exist in the cell")
    }
    
    func testBlurEffectStyling() {
        // Launch the app
        app.launch()
        
        // Verify blur effect view exists and has correct corner radius
        // (Note: We can't directly verify visual properties like corner radius in UI tests,
        // but we can verify the view exists)
        let blurEffect = app.otherElements["blurEffect"]
        XCTAssertTrue(blurEffect.exists, "Blur effect view should exist")
    }
}
