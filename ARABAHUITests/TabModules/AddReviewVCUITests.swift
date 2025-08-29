//
//  AddReviewVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class AddReviewVCUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

    }

    // MARK: - Test 1: UI Elements Exist

    func testAddReviewScreen_UIElementsExist() {
        XCTAssertTrue(app.otherElements["ratingView"].waitForExistence(timeout: 5), "Rating view should exist")
        XCTAssertTrue(app.textViews["reviewTextView"].exists, "Review text view should exist")
    }

    // MARK: - Test 2: Enter Review and Submit

    func testSubmitReview_WithValidInput_ShowsLoaderAndSucceeds() {
        let rating = app.otherElements["ratingView"]
        let reviewTextView = app.textViews["reviewTextView"]

        XCTAssertTrue(rating.exists)
        XCTAssertTrue(reviewTextView.exists)

        // ⭐️ Simulate rating by tapping (approx position for 4-star)
        let fourStarPoint = rating.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
        fourStarPoint.tap()

        // ⌨️ Enter review text
        reviewTextView.tap()
        reviewTextView.typeText("This product is amazing! Highly recommend.")

        // 🚀 Tap Submit
        app.buttons["Submit"].tap()

        // ⏳ Check for loader (MBProgressHUD)
        XCTAssertTrue(app.otherElements["ProgressHUD"].waitForExistence(timeout: 2), "Loader should appear after submit")

        // ✅ Simulate success – expect navigation back or success message (you can inject a mock or use delay)
        // If pop navigation is animated, check previous screen exists or use mock validation
    }

    // MARK: - Test 3: Submit With Empty Review

    func testSubmitReview_WithEmptyText_ShowsValidationAlert() {
        let rating = app.otherElements["ratingView"]
        XCTAssertTrue(rating.exists)

        // Tap 3 stars
        let threeStar = rating.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.5))
        threeStar.tap()

        // Ensure text view is empty
        let reviewTextView = app.textViews["reviewTextView"]
        reviewTextView.tap()
        reviewTextView.typeText("") // Leave it empty

        // Tap Submit
        app.buttons["Submit"].tap()

        // 🚨 Validation alert expected
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2), "Validation alert should appear")
        XCTAssertTrue(alert.staticTexts.element(boundBy: 0).exists)
    }

    // MARK: - Test 4: Submit Without Rating

    func testSubmitReview_WithNoRating_ShowsValidationAlert() {
        let reviewTextView = app.textViews["reviewTextView"]
        reviewTextView.tap()
        reviewTextView.typeText("Good but not great.")


        app.buttons["Submit"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 2), "Validation alert should appear")
        XCTAssertTrue(alert.staticTexts.element(boundBy: 0).exists)
    }
}

