//
//  SubCatDetailVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class SubCatDetailVCUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-UITest_SubCatDetailVC"]
        app.launch()
    }

    func testUIElementsExist() throws {
        let name = app.staticTexts["lblProName"]
        let price = app.staticTexts["lblAmount"]
        let notifyBtn = app.buttons["btnNotifyMe"]
        let heartBtn = app.buttons["heartBtn"]
        let slider = app.otherElements["rangeSlider"]
        let chart = app.otherElements["chartVW"]

        XCTAssertTrue(name.waitForExistence(timeout: 5))
        XCTAssertTrue(price.exists)
        XCTAssertTrue(notifyBtn.exists)
        XCTAssertTrue(heartBtn.exists)
        XCTAssertTrue(slider.exists)
        XCTAssertTrue(chart.exists)
    }

    func testSliderValueChangesUpdateFloatingLabel() throws {
        let slider = app.sliders["rangeSlider"]
        let floatLabel = app.staticTexts["floatingValueView"]

        XCTAssertTrue(slider.exists)
        slider.adjust(toNormalizedSliderPosition: 0.8)
        XCTAssertTrue(floatLabel.exists)
        XCTAssertTrue(floatLabel.label.contains("⃀"))
    }

    func testTapButtonsAndNavigate() throws {
        let seeComments = app.buttons["btnSeeCommnet"]
        if seeComments.exists {
            seeComments.tap()
            XCTAssertTrue(app.tables["tblViewComment"].waitForExistence(timeout: 5))
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        let seeOffers = app.buttons["offerSeeAll"]
        if seeOffers.exists {
            seeOffers.tap()
            XCTAssertTrue(app.tables["offersTbl"].waitForExistence(timeout: 5))
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        let reviewsBtn = app.buttons["Reviews"]
        if reviewsBtn.exists {
            reviewsBtn.tap()
            XCTAssertTrue(app.tables["reviewTbl"].waitForExistence(timeout: 5))
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    func testNotifyAndLikeToggle() throws {
        let notifyBtn = app.buttons["btnNotifyMe"]
        let heartBtn = app.buttons["heartBtn"]

        XCTAssertTrue(notifyBtn.exists)
        notifyBtn.tap()
        XCTAssertTrue(notifyBtn.isSelected)

        XCTAssertTrue(heartBtn.exists)
        heartBtn.tap()
        XCTAssertTrue(heartBtn.isSelected)
    }

    func testShareButtonOpensActivitySheet() throws {
        let shareBtn = app.buttons["BtnShare"]
        XCTAssertTrue(shareBtn.exists)
        shareBtn.tap()
        XCTAssertTrue(app.sheets.firstMatch.waitForExistence(timeout: 5))
        app.sheets.buttons.firstMatch.tap()
    }

    func testBackButtonDismisses() throws {
        let backBtn = app.buttons["didTapBackBtn"]
        XCTAssertTrue(backBtn.exists)
        backBtn.tap()
        XCTAssertFalse(backBtn.exists)
    }
}
