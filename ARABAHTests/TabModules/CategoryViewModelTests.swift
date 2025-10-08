//
//  CategoryViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class CategoryViewModelTests: XCTestCase {
    
    private var viewModel: CategoryViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = CategoryViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchCategoriesSuccess() {
        // Given
        
        let mockBody = CategoryListModal(success: true, code: 200, message: "OK", body: nil)
        mockService.fetchCategoriesPublisher = Just(mockBody)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "State should be success")

        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.latitude = "25.0"
        viewModel.longitude = "55.0"
        viewModel.fetchCategories()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfItems, 1)
        XCTAssertFalse(viewModel.isEmpty)
    }

    func testFetchCategoriesFailure() {
        // Given
        mockService.fetchCategoriesPublisher = Fail(error: NetworkError.serverError(message: "Internal error"))
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "State should be failure")

        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Internal error"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.latitude = "25.0"
        viewModel.longitude = "55.0"
        viewModel.fetchCategories()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfItems, 0)
        XCTAssertTrue(viewModel.isEmpty)
    }

    func testRetryTriggersFetch() {
        // Given
        
        let mockBody = CategoryListModal(success: true, code: 200, message: "OK", body: nil)
        mockService.fetchCategoriesPublisher = Just(mockBody)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Retry should succeed")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.latitude = "24.0"
        viewModel.longitude = "54.0"
        viewModel.retry()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.numberOfItems, 1)
    }

    func testCategoryCellAccess() {
        // Given
        
        // viewModel.categoryBody = [CategoryListModalBody.init(category: nil)]

        // When
        let result = viewModel.categoryCell(for: 0)

        // Then
        XCTAssertEqual(result?.id, "10")
        XCTAssertEqual(viewModel.numberOfItems, 1)
    }
    
    func testStateTransitionsToSuccess() {
        
        let modal = CategoryListModal(success: true, code: 200, message: "OK", body: CategoryListModalBody(category: []))

        mockService.fetchCategoriesPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "State transitions from loading to success")
        expectation.expectedFulfillmentCount = 2

        var states: [AppState<CategoryListModal>] = []

        viewModel.$state
            .dropFirst()
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.latitude = "1.0"
        viewModel.longitude = "2.0"
        viewModel.fetchCategories()

        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(states.first, .loading)
        XCTAssertEqual(states.last, .success(modal))
    }

    
    func testStateTransitionsToFailure() {
        mockService.fetchCategoriesPublisher = Fail(error: .invalidResponse)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "State transitions to failure")
        expectation.expectedFulfillmentCount = 2

        var observedStates: [AppState<CategoryListModal>] = []

        viewModel.$state
            .dropFirst()
            .sink { state in
                observedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.latitude = "3.0"
        viewModel.longitude = "4.0"
        viewModel.fetchCategories()

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(observedStates[0], .loading)
        XCTAssertEqual(observedStates[1], .failure(.invalidResponse))
    }

    func testEmptyCategoryResponseSetsIsEmptyTrue() {
        let modal = CategoryListModal(success: true, code: 200, message: "OK", body: CategoryListModalBody(category: []))

        mockService.fetchCategoriesPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "isEmpty should be true on empty category list")

        viewModel.$isEmpty
            .dropFirst()
            .sink { isEmpty in
                XCTAssertTrue(isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.latitude = "12.0"
        viewModel.longitude = "88.0"
        viewModel.fetchCategories()

        wait(for: [expectation], timeout: 2.0)
    }

    func testCategoryCellOutOfBoundsReturnsNil() {
        // Empty state by default
        let cell = viewModel.categoryCell(for: 5)
        XCTAssertNil(cell)
    }    
    
}
