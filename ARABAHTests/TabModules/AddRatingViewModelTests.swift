//
//  AddRatingViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class AddRatingViewModelTests: XCTestCase {

    private var viewModel: AddRatingViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = AddRatingViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testSubmitReviewSuccess() {
        // Arrange
        let modal = AddCommentModal(success: true, code: 200, message: "Review Added",body: nil)
        mockService.createRatingAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should receive .success state")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .success(modal) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.submitReview(productId: "p1", rating: 4.0, reviewText: "Great!")

        // Assert
        wait(for: [expectation], timeout: 2)
    }

    func testSubmitReviewValidationFailure() {
        // Arrange
        let expectation = expectation(description: "Should emit .validationFailure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error, .validationError(RegexMessages.invalidEmptyDescription))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.submitReview(productId: "p1", rating: 4.0, reviewText: "   ") // only whitespace

        // Assert
        wait(for: [expectation], timeout: 1)
    }

    func testSubmitReviewAPIFailure() {
        // Arrange
        mockService.createRatingAPIPublisher = Fail(error: .networkError("Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit .failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.submitReview(productId: "p1", rating: 3.0, reviewText: "Bad")

        // Assert
        wait(for: [expectation], timeout: 2)
    }

    func testRetrySubmitsLastInput() {
        // Arrange
        let modal = AddCommentModal(success: true, code: 200, message: "Retry Success",body: nil)
        mockService.createRatingAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Retry should emit .success")

        viewModel.$state
            .dropFirst(2) // idle → loading → success
            .sink { state in
                if state == .success(modal) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.submitReview(productId: "retry-id", rating: 5.0, reviewText: "Nice")
        viewModel.retry()

        // Assert
        wait(for: [expectation], timeout: 2)
    }
    
    func testStateTransitionSequenceOnSuccess() {
        // Arrange
        let modal = AddCommentModal(success: true, code: 200, message: "Done", body: nil)
        mockService.createRatingAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Should emit loading then success")
        expectation.expectedFulfillmentCount = 2
        
        var stateTransitions: [AppState<AddCommentModal>] = []

        viewModel.$state
            .dropFirst()
            .sink { state in
                stateTransitions.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        viewModel.submitReview(productId: "22", rating: 5.0, reviewText: "Awesome")

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(stateTransitions.count, 2)
        XCTAssertEqual(stateTransitions[0], .loading)
        XCTAssertEqual(stateTransitions[1], .success(modal))
    }

    func testSubmitReviewTrimsWhitespace() {
        // Arrange
        let trimmedReview = "Nice product"
        let modal = AddCommentModal(success: true, code: 200, message: "Added", body: nil)
        
        // Custom service to capture sent review
        var sentReview: String?
        mockService.createRatingAPIPublisher = {
            sentReview = trimmedReview
            return Just(modal)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }()

        let expectation = expectation(description: "Should send trimmed review text")

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .success = state {
                    XCTAssertEqual(sentReview, trimmedReview)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.submitReview(productId: "prod123", rating: 4.0, reviewText: "  Nice product   ")

        // Assert
        wait(for: [expectation], timeout: 2.0)
    }
    func testRetryWithoutLastInputDoesNothing() {
        // Arrange
        let expectation = expectation(description: "State should remain idle")
        expectation.isInverted = true

        viewModel.$state
            .dropFirst()
            .sink { _ in
                expectation.fulfill() // Should not be called
            }
            .store(in: &cancellables)

        // Act
        viewModel.retry()

        // Assert
        wait(for: [expectation], timeout: 1.0)
    }
    func testStateEmitsOnlyOnceForSingleSubmission() {
        // Arrange
        let modal = AddCommentModal(success: true, code: 200, message: "Okay", body: nil)
        mockService.createRatingAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var emissionCount = 0
        let expectation = expectation(description: "Should emit loading and success")
        expectation.expectedFulfillmentCount = 2

        viewModel.$state
            .dropFirst()
            .sink { _ in
                emissionCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        viewModel.submitReview(productId: "prod456", rating: 3.0, reviewText: "Good")

        // Assert
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(emissionCount, 2)
    }

    
}

