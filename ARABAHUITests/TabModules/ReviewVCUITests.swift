//
//  ReviewVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class ReviewVCUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Test 1: UI Elements Exist

    func testReviewScreen_UIElementsExist() {
        XCTAssertTrue(app.staticTexts["lblAvgRating"].waitForExistence(timeout: 5), "Average rating label should exist")
        XCTAssertTrue(app.staticTexts["lblTotalCountReview"].exists, "Total count label should exist")
        XCTAssertTrue(app.tables["reviewTbl"].exists, "Review table should exist")
    }

    // MARK: - Test 2: Review List Loads and Shows Reviews

    func testReviewList_DisplaysCells() {
        let table = app.tables["reviewTbl"]
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Review table must exist")

        // Wait for data load
        sleep(2)

        let cells = table.cells
        XCTAssertGreaterThanOrEqual(cells.count, 1, "There should be at least one review cell displayed")
    }

    // MARK: - Test 3: Add Review Button Navigates

    func testAddReviewButton_NavigatesToAddReviewVC() {
        let addReviewBtn = app.buttons["Add Review"]
        XCTAssertTrue(addReviewBtn.exists, "Add Review button should exist")
        addReviewBtn.tap()

        // Wait for AddReviewVC to appear
        let ratingView = app.otherElements["ratingView"]
        XCTAssertTrue(ratingView.waitForExistence(timeout: 5), "Should navigate to AddReviewVC")
    }

    // MARK: - Test 4: No Data Label Appears When Empty

    func testReviewScreen_EmptyState_ShowsNoData() {
        // Simulate empty state using launch arguments or mock
        // e.g., app.launchArguments.append("--ui-test-empty-reviews")

        let table = app.tables["reviewTbl"]
        XCTAssertTrue(table.exists)

        sleep(2)

        let noDataLabel = table.staticTexts["No Data Found"]
        XCTAssertTrue(noDataLabel.exists, "No Data Found label should appear when reviews are empty")
    }

    // MARK: - Test 5: Retry Alert Appears On Error

    func testReviewScreen_Error_ShowsRetryAlert() {
        // Simulate error using launch arguments or network failure injection
        // e.g., app.launchArguments.append("--ui-test-review-api-fail")

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Error alert with retry should appear")

        XCTAssertTrue(alert.staticTexts.element(boundBy: 0).exists, "Alert message should appear")
        XCTAssertTrue(alert.buttons["Retry"].exists, "Retry button should appear")
    }
}

