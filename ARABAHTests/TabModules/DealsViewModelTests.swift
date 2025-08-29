//
//  DealsViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class DealsViewModelTests: XCTestCase {

    var viewModel: DealsViewModel!
    var mockService: MockHomeService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = DealsViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testGetOfferDealsAPISuccess_shouldUpdateDealsAndSetSuccessState() {
        // Given
        
        let response = GetOfferDealsModal(success: true, code: 200, message: "OK", body: [])

        mockService.getOfferDealsAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "State becomes success")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let modal) = state {
                    XCTAssertEqual(modal.message, "OK")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.getOfferDealsAPI()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.dealsBody?.count, 1)
        XCTAssertEqual(viewModel.dealsBody?.first?.decription, "Big Sale")
    }


    func testGetOfferDealsAPIFailure_shouldSetFailureState() {
        // Given
        mockService.getOfferDealsAPIPublisher = Fail(error: NetworkError.serverError(message: "API failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "State becomes failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == NetworkError.serverError(message: "API failed") {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.getOfferDealsAPI()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }


    func testFormattedDealText_shouldReturnExpectedString() {

        let text = viewModel.formattedDealText(at: 0)
        XCTAssertTrue(text.contains("Mart"))
        XCTAssertTrue(text.contains("Save More"))
    }

    func testDealImageUrlAndStoreImageUrl_shouldReturnExpectedURLs() {

        let dealURL = viewModel.dealImageUrl(at: 0)
        let storeURL = viewModel.storeImageUrl(at: 0)

        XCTAssertTrue(dealURL.contains("deal.jpg"))
        XCTAssertTrue(storeURL.contains("store.jpg"))
    }
    
    func testStateTransitions_loadingToSuccess() {
        let response = GetOfferDealsModal(success: true, code: 200, message: "Loaded", body: [])

        mockService.getOfferDealsAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit loading then success")
        expectation.expectedFulfillmentCount = 2

        var states: [AppState<GetOfferDealsModal>] = []

        viewModel.$state
            .dropFirst()
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.getOfferDealsAPI()

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(states[0], .loading)
        XCTAssertEqual(states[1], .success(response))
    }

    func testNilBodyShouldSetFailure() {
        // Given
        let response = GetOfferDealsModal(success: true, code: 200, message: "Missing body", body: nil)

        mockService.getOfferDealsAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit failure due to nil body")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .invalidResponse)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.getOfferDealsAPI()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    func testIsDataEmptyShouldReturnTrueWhenEmpty() {
        let response = GetOfferDealsModal(success: true, code: 200, message: "OK", body: [])

        mockService.getOfferDealsAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "isDataEmpty should be true")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getOfferDealsAPI()

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isDataEmpty)
    }

    func testFormattedDealTextOutOfBoundsShouldReturnEmpty() {
        // No deals in the array
        let result = viewModel.formattedDealText(at: 5)
        XCTAssertEqual(result, "")
    }

    func testImageURLsWhenIndexOutOfBoundsShouldReturnBaseURL() {
        // Nothing added to dealsBody
        let dealURL = viewModel.dealImageUrl(at: 10)
        let storeURL = viewModel.storeImageUrl(at: 10)

        XCTAssertEqual(dealURL, AppConstants.imageURL)
        XCTAssertEqual(storeURL, AppConstants.imageURL)
    }

    
}
