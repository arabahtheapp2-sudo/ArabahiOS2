//
//  NotificationListVCUITests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class NotificationListVCUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_NotificationList"]
        app.launch()
    }
    
    // MARK: - Tests
    
    func testNotificationListLoads() throws {
        let table = app.tables["notificationListTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 5), "Notification table did not load.")
        
        // Wait until actual content replaces skeletons
        expectation(for: NSPredicate(format: "count > 0"), evaluatedWith: table.cells, handler: nil)
        waitForExpectations(timeout: 10)
        
        XCTAssertGreaterThan(table.cells.count, 0, "Notifications are not populated.")
    }
    
    func testSkeletonCellsAppearDuringLoading() throws {
        // Simulated by fast launch without network response
        // You can add `-delayNotifications` flag to mock ViewModel in test mode
        let table = app.tables["notificationListTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 5))
        XCTAssertEqual(table.cells.count, 10, "Skeleton cells should appear during loading.")
    }
    
    func testClearAllButtonExistsAndTaps() throws {
        let clearBtn = app.buttons["clearAllButton"]
        XCTAssertTrue(clearBtn.waitForExistence(timeout: 5), "Clear All button not found.")
        
        clearBtn.tap()
        
        // Confirm alert or modal is shown
        let popup = app.otherElements["popUpVCView"]
        XCTAssertTrue(popup.waitForExistence(timeout: 3), "Clear confirmation popup not presented.")
    }
    
    func testTapNotificationNavigatesToDetailScreen() throws {
        let table = app.tables["notificationListTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 5))
        
        let cell = table.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists)
        
        cell.tap()
        
        let detailLabel = app.staticTexts["lblProName"]
        XCTAssertTrue(detailLabel.waitForExistence(timeout: 5), "Did not navigate to SubCatDetailVC.")
    }
    
    
}
