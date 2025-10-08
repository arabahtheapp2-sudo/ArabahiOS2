//
//  FilterViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class FilterViewModelTests: XCTestCase {
    
    private var viewModel: FilterViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = FilterViewModel(networkService: mockService)
        cancellables = []
        Store.filterdata = nil
        Store.filterStore = nil
        Store.fitlerBrand = nil
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        Store.filterdata = nil
        Store.filterStore = nil
        Store.fitlerBrand = nil
        super.tearDown()
    }
    
    // MARK: - API Success

    func testStateTransitionFromIdleToLoadingToSuccess() {
        // Given
        
        let response = FilterGetDataModal(success: true, code: 200, message: "OK", body: nil)

        mockService.fetchFilterDataAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var receivedStates: [AppState<FilterGetDataModal>] = []
        let expectation = expectation(description: "States should be emitted")
        expectation.expectedFulfillmentCount = 2

        viewModel.$state
            .dropFirst()
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchFilterDataAPI(with: .init(longitude: "77.0", latitude: "28.0"))

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedStates[0], .loading)
        XCTAssertEqual(receivedStates[1], .success(response))
    }


    // MARK: - API Failure
    func testFilterDataNilBodyShouldSetFailure() {
        // Given
        let response = FilterGetDataModal(success: true, code: 200, message: "OK", body: nil)

        mockService.fetchFilterDataAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit invalid response failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == .invalidResponse {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchFilterDataAPI(with: .init(longitude: "77.0", latitude: "28.0"))

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testToggleSelectionWithInvalidSectionDoesNothing() {
        viewModel.selectedCategoryIDs = ["c1"]
        viewModel.selectedStoreIDs = ["s1"]
        viewModel.selectedBrandIDs = ["b1"]

        // Act
        viewModel.toggleSelection(id: "x1", section: 999)

        // Assert
        XCTAssertEqual(viewModel.selectedCategoryIDs, ["c1"])
        XCTAssertEqual(viewModel.selectedStoreIDs, ["s1"])
        XCTAssertEqual(viewModel.selectedBrandIDs, ["b1"])
    }

    func testGetFormattedSelectedFilters_emptySelectionReturnsEmptyString() {
        // No selections
        viewModel.selectedCategoryIDs = []
        viewModel.selectedStoreIDs = []
        viewModel.selectedBrandIDs = []

        let result = viewModel.getFormattedSelectedFilters()
        XCTAssertEqual(result, "")
    }

    
    // MARK: - Selection Toggle

    func testToggleSelection_CategoryStoreBrand() {
        viewModel.toggleSelection(id: "c1", section: 0)
        viewModel.toggleSelection(id: "s1", section: 1)
        viewModel.toggleSelection(id: "b1", section: 2)
        
        XCTAssertEqual(viewModel.selectedCategoryIDs, ["c1"])
        XCTAssertEqual(viewModel.selectedStoreIDs, ["s1"])
        XCTAssertEqual(viewModel.selectedBrandIDs, ["b1"])
        
        // Toggle off
        viewModel.toggleSelection(id: "c1", section: 0)
        viewModel.toggleSelection(id: "s1", section: 1)
        viewModel.toggleSelection(id: "b1", section: 2)
        
        XCTAssertTrue(viewModel.selectedCategoryIDs.isEmpty)
        XCTAssertTrue(viewModel.selectedStoreIDs.isEmpty)
        XCTAssertTrue(viewModel.selectedBrandIDs.isEmpty)
    }

    // MARK: - Save and Restore Filters

    func testSaveAndRestoreSelections() {
        viewModel.selectedCategoryIDs = ["c1"]
        viewModel.selectedStoreIDs = ["s1"]
        viewModel.selectedBrandIDs = ["b1"]
        
        viewModel.saveSelections()
        
        // Reset
        viewModel.selectedCategoryIDs = []
        viewModel.selectedStoreIDs = []
        viewModel.selectedBrandIDs = []
        
        viewModel.restoreStoredFilters()
        
        XCTAssertEqual(viewModel.selectedCategoryIDs, ["c1"])
        XCTAssertEqual(viewModel.selectedStoreIDs, ["s1"])
        XCTAssertEqual(viewModel.selectedBrandIDs, ["b1"])
    }

    func testClearSelections() {
        viewModel.selectedCategoryIDs = ["c1"]
        viewModel.selectedStoreIDs = ["s1"]
        viewModel.selectedBrandIDs = ["b1"]
        Store.filterdata = ["c1"]
        Store.filterStore = ["s1"]
        Store.fitlerBrand = ["b1"]
        
        viewModel.clearSelections()
        
        XCTAssertTrue(viewModel.selectedCategoryIDs.isEmpty)
        XCTAssertTrue(viewModel.selectedStoreIDs.isEmpty)
        XCTAssertTrue(viewModel.selectedBrandIDs.isEmpty)
        XCTAssertNil(Store.filterdata)
        XCTAssertNil(Store.filterStore)
        XCTAssertNil(Store.fitlerBrand)
    }

    // MARK: - Formatting

    func testGetFormattedSelectedFilters() {
        viewModel.selectedCategoryIDs = ["cat1"]
        viewModel.selectedStoreIDs = ["store1"]
        viewModel.selectedBrandIDs = ["brand1"]

        let formatted = viewModel.getFormattedSelectedFilters()
        XCTAssertEqual(formatted, "Categories: cat1&Store Name: store1&Brand Name: brand1")
    }
    
    func testEmptyStateShouldBeTrueWhenAllListsEmpty() {
        // Given
        let emptyBody = FilterGetDataModalBody(category: [], store: [], brand: [])
        let response = FilterGetDataModal(success: true, code: 200, message: "OK", body: emptyBody)

        mockService.fetchFilterDataAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should set state to success and isEmpty true")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchFilterDataAPI(with: .init(longitude: "0", latitude: "0"))

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.isEmpty)
        XCTAssertTrue(viewModel.category?.isEmpty ?? false)
        XCTAssertTrue(viewModel.storeData?.isEmpty ?? false)
        XCTAssertTrue(viewModel.brand?.isEmpty ?? false)
    }

    
}
