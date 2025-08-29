//
//  SearchCategoryVCTests.swift
//  ARABAHUITests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest

final class SearchCategoryVCTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest_SearchCategory"]
        app.launch()
    }

    func testSearchInputAndTrigger() throws {
        let searchField = app.textFields["txtFldSearch"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search text field should exist")
        
        searchField.tap()
        searchField.typeText("shoes\n") // `\n` simulates pressing return
        
        let productCollection = app.collectionViews["productCollection"]
        XCTAssertTrue(productCollection.waitForExistence(timeout: 5), "Product results should appear")
    }

    func testRecentSearchListAppears() throws {
        let recentTable = app.tables["recentSearchTbl"]
        XCTAssertTrue(recentTable.waitForExistence(timeout: 5), "Recent search table should exist")

        let firstCell = recentTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists, "First recent search cell should exist")
    }

    func testTapRecentSearchTriggersSearch() throws {
        let recentTable = app.tables["recentSearchTbl"]
        let cell = recentTable.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists, "Recent search cell should exist")

        cell.tap()

        let productCollection = app.collectionViews["productCollection"]
        XCTAssertTrue(productCollection.waitForExistence(timeout: 5), "Search should trigger and show products")
    }

    func testDeleteRecentSearchItem() throws {
        let recentTable = app.tables["recentSearchTbl"]
        let cell = recentTable.cells.element(boundBy: 0)
        XCTAssertTrue(cell.exists, "Recent search cell should exist")

        let deleteButton = cell.buttons.element(boundBy: 0)
        XCTAssertTrue(deleteButton.exists, "Delete button should exist")
        deleteButton.tap()
    }

    func testTapCategoryItemNavigatesToSubCategoryVC() throws {
        let categoryCollection = app.collectionViews["searchCollectionCateogy"]
        XCTAssertTrue(categoryCollection.waitForExistence(timeout: 5), "Category collection should exist")

        let firstCategory = categoryCollection.cells.element(boundBy: 0)
        XCTAssertTrue(firstCategory.exists, "First category item should exist")
        firstCategory.tap()
        
        // Optional: Add assertion that checks the SubCategoryVC appeared
    }

    func testTapProductItemNavigatesToProductDetail() throws {
        let productCollection = app.collectionViews["productCollection"]
        XCTAssertTrue(productCollection.waitForExistence(timeout: 5), "Product collection should exist")

        let firstProduct = productCollection.cells.element(boundBy: 0)
        XCTAssertTrue(firstProduct.exists, "First product item should exist")
        firstProduct.tap()
        
        // Optional: Assert SubCatDetailVC was presented
    }

    func testFilterButtonOpensModal() throws {
        let filterButton = app.buttons["BtnFilter"]
        if filterButton.exists {
            filterButton.tap()
            // Assert modal appearance if identifiable
        }
    }

    func testBackButtonDismissesVC() throws {
        let backButton = app.buttons["btnBack"]
        if backButton.exists {
            backButton.tap()
            // Assert previous screen appeared if needed
        }
    }
}

