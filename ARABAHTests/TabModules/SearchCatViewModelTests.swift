//
//  SearchCatViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class SearchCatViewModelTests: XCTestCase {

    private var viewModel: SearchCatViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = SearchCatViewModel(networkService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testPerformSearchSuccess() {
        let body = [CreateModalBody]()
        let response = CreateModal(success: true, code: 200, message: "OK", body: body)
        mockService.performSearchPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Search success")

        viewModel.updateSearchQuery("test")
        viewModel.performSearch(isRetry: false)

        viewModel.$createSearchState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testPerformSearchFailure() {
        mockService.performSearchPublisher = Fail(error: NetworkError.networkError("Failed"))
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Search failure")

        viewModel.updateSearchQuery("test")
        viewModel.performSearch(isRetry: false)

        viewModel.$createSearchState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == NetworkError.networkError("Failed") {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testRecentSearchSuccess() {
        let body = [RecentSearchModalBody]()
        let response = RecentSearchModal(success: true, code: 200, message: "OK", body: body)
        mockService.recentSearchAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Recent search success")

        viewModel.recentSearchAPI(isRetry: false)

        viewModel.$recentSearchState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testHistoryDeleteSuccess() {
        let response = SearchHistoryDeleteModal(success: true, code: 200, message: "Deleted", body: nil)
        mockService.historyDeleteAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Delete history success")

        viewModel.historyDeleteAPI(with: "123")

        viewModel.$historyDelState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 2.0)
    }

    func testClearCategory() {
        viewModel.clearCategory()
        XCTAssertEqual(viewModel.category?.count, 0)
    }

    func testPerformSearchStateTransition() {
        let body: [CreateModalBody] = []
        let response = CreateModal(success: true, code: 200, message: "OK", body: body)
        mockService.performSearchPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var states: [AppState<CreateModal>] = []
        let expectation = expectation(description: "Should go through .loading and .success")
        expectation.expectedFulfillmentCount = 2

        viewModel.$createSearchState
            .dropFirst()
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.updateSearchQuery("iphone")
        viewModel.performSearch(isRetry: false)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(states.first, .loading)
        XCTAssertTrue(states.contains { if case .success = $0 { return true } else { return false } })
    }

    
    func testPerformSearchWithEmptyQueryClearsCategory() {
        // Given existing data
        viewModel.updateSearchQuery("")
        viewModel.performSearch(isRetry: false)

        XCTAssertEqual(viewModel.category?.count, 0)
        XCTAssertEqual(viewModel.createSearchState, .idle)
    }

    
    func testFetchSearchResultsSuccess() {
        
        let response = CategorySearchModal(success: true, code: 200, message: "OK", body: nil)

        mockService.fetchSearchResultsPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Search results fetched")

        viewModel.$searchCatState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.updateSearchQuery("camera")
        viewModel.updateLocation(lat: "10.0", long: "20.0")
        viewModel.fetchSearchResults(isRetry: false)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.product?.count, 1)
        XCTAssertEqual(viewModel.category?.count, 1)
    }
    
    func testFetchSearchResultsFailure() {
        mockService.fetchSearchResultsPublisher = Fail(error: NetworkError.badRequest(message: "Something went wrong"))
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Search results failed")

        viewModel.$searchCatState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .badRequest(message:("Something went wrong")))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.updateSearchQuery("macbook")
        viewModel.updateLocation(lat: "10.0", long: "20.0")
        viewModel.fetchSearchResults(isRetry: false)

        wait(for: [expectation], timeout: 2)
    }

    func testRetryDeleteHistoryRetriesWithLastID() {
        let response = SearchHistoryDeleteModal(success: true, code: 200, message: "Deleted", body: nil)
        mockService.historyDeleteAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Retry deletes with same ID")

        viewModel.historyDeleteAPI(with: "456")

        viewModel.$historyDelState
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Retry with the same ID
        viewModel.retryDeleteHistory()

        wait(for: [expectation], timeout: 2)
    }

    func testRecentSearchStateTransition() {
        
        let response = RecentSearchModal(success: true, code: 200, message: "Fetched", body: [])

        mockService.recentSearchAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var states: [AppState<RecentSearchModal>] = []
        let expectation = self.expectation(description: "Recent search states transition")
        expectation.expectedFulfillmentCount = 2

        viewModel.$recentSearchState
            .dropFirst()
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.recentSearchAPI(isRetry: false)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(states.first, .loading)
        XCTAssertTrue(states.contains { if case .success = $0 { return true } else { return false } })
    }


}

