//
//  RatingListViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class RatingListViewModelTests: XCTestCase {

    private var viewModel: RatingListViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = RatingListViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testRatingListAPISuccessWithData() {
        // Arrange
        
        let response = GetRaitingModal(success: true, code: 200, message: "Success", body: nil)

        mockService.raitingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let stateExpectation = expectation(description: "State should become .success")
        let listExpectation = expectation(description: "Rating list should be updated")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .success(response) {
                    stateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.$ratingList
            .dropFirst()
            .sink { list in
                if list.count == 1 {
                    listExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.raitingListAPI(productId: "123")

        // Assert
        wait(for: [stateExpectation, listExpectation], timeout: 2)

        XCTAssertEqual(viewModel.ratingBody?.averageRating, 4.5)
        XCTAssertEqual(viewModel.ratingList.count, 1)
        XCTAssertEqual(viewModel.averageRatingText, "4.5")
        XCTAssertEqual(viewModel.totalReviewsText, "1 Ratings")
        XCTAssertFalse(viewModel.showNoDataMessage)
    }

    func testRatingListAPISuccessWithEmptyData() {
        // Arrange
        let response = GetRaitingModal(success: true, code: 200, message: "Empty", body: nil)

        mockService.raitingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Success with empty list")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .success(response) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.raitingListAPI(productId: "123")

        // Assert
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.ratingList.count, 0)
        XCTAssertEqual(viewModel.averageRatingText, "0.0")
        XCTAssertEqual(viewModel.totalReviewsText, "0 Ratings")
        XCTAssertTrue(viewModel.showNoDataMessage)
    }

    func testRatingListAPIFailure() {
        // Arrange
        mockService.raitingListAPIPublisher = Fail(error: NetworkError.networkError("Request failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit failure state")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Request failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.raitingListAPI(productId: "123")

        // Assert
        wait(for: [expectation], timeout: 2)

        XCTAssertNil(viewModel.ratingBody)
        XCTAssertEqual(viewModel.ratingList.count, 0)
        XCTAssertEqual(viewModel.averageRatingText, "0.0")
        XCTAssertEqual(viewModel.totalReviewsText, "0 Ratings")
        XCTAssertTrue(viewModel.showNoDataMessage)
    }

    func testRatingListAPIInvalidResponseBody() {
        // Arrange
        let response = GetRaitingModal(success: true, code: 200, message: "No body", body: nil)

        mockService.raitingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Invalid response body should fail")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == .invalidResponse {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.raitingListAPI(productId: "123")

        // Assert
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.showNoDataMessage)
    }
    
    func testShowNoDataMessageWhenListIsEmpty() {
        let response = GetRaitingModal(success: true, code: 200, message: "Success", body: nil)

        mockService.raitingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "showNoDataMessage should be true")

        viewModel.$showNoDataMessage
            .dropFirst()
            .sink { value in
                if value {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.raitingListAPI(productId: "id")
        wait(for: [expectation], timeout: 1)
    }
    
    func testFormattedTextsOnValidData() {
        let body = GetRaitingModalBody(ratinglist: [Ratinglist](), ratingCount: 8, averageRating: 3.75)
        let response = GetRaitingModal(success: true, code: 200, message: "OK", body: body)

        mockService.raitingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Formatted texts set correctly")

        viewModel.$averageRatingText
            .dropFirst()
            .sink { _ in
                XCTAssertEqual(self.viewModel.averageRatingText, "3.75")
                XCTAssertEqual(self.viewModel.totalReviewsText, "8 Ratings")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.raitingListAPI(productId: "123")
        wait(for: [expectation], timeout: 1.0)
    }

    func testStateResetOnFailure() {
        mockService.raitingListAPIPublisher = Fail(error: NetworkError.unauthorized)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "State resets on error")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == .unauthorized {
                    XCTAssertNil(self.viewModel.ratingBody)
                    XCTAssertEqual(self.viewModel.ratingList.count, 0)
                    XCTAssertEqual(self.viewModel.averageRatingText, "0.0")
                    XCTAssertEqual(self.viewModel.totalReviewsText, "0 Ratings")
                    XCTAssertTrue(self.viewModel.showNoDataMessage)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.raitingListAPI(productId: "error-case")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testStateTransitions() {
        let response = GetRaitingModal(success: true, code: 200, message: "OK", body: GetRaitingModalBody(ratinglist: [Ratinglist](), ratingCount: 0, averageRating: 0))

        mockService.raitingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var stateSequence: [AppState<GetRaitingModal>] = []

        let expectation = expectation(description: "Should go through loading and success states")

        viewModel.$state
            .sink { state in
                stateSequence.append(state)
                if stateSequence.contains(where: {
                    if case .success = $0 { return true }
                    return false
                }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.raitingListAPI(productId: "id")
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(stateSequence.first, .loading)
        XCTAssertTrue(stateSequence.contains { if case .success = $0 { return true } else { return false } })
    }

}
