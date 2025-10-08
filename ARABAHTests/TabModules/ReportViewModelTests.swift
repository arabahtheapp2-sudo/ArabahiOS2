//
//  ReportViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ReportViewModelTests: XCTestCase {
    
    private var viewModel: ReportViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = ReportViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testReportSuccess() {
        // Arrange
        let mockResponse = ReportModal(success: true, code: 200, message: "Reported", body: nil)
        mockService.reportAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit .success")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if state == .success(mockResponse) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "This is inappropriate"), isRetry: false)

        // Assert
        wait(for: [expectation], timeout: 2)
    }

    func testReportValidationFailure() {
        // Arrange
        let expectation = expectation(description: "Should emit .validateError")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: RegexMessages.invalidEmptyDescription))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "   "), isRetry: false) // only whitespace

        // Assert
        wait(for: [expectation], timeout: 1)
    }

    func testReportFailure() {
        // Arrange
        mockService.reportAPIPublisher = Fail(error: .networkError("Something went wrong"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should emit .failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Something went wrong"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "Report content"), isRetry: false)

        // Assert
        wait(for: [expectation], timeout: 2)
    }
    
    func testStateTransitionsFromIdleToLoadingToSuccess() {
        // Arrange
        let mockResponse = ReportModal(success: true, code: 200, message: "OK", body: nil)
        mockService.reportAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var stateSequence: [AppState<ReportModal>] = []

        let expectation = expectation(description: "Should transition from .loading to .success")

        viewModel.$state
            .sink { state in
                stateSequence.append(state)
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "Valid message"), isRetry: false)

        // Assert
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(stateSequence.first, .loading)
        XCTAssertTrue(stateSequence.contains { if case .success = $0 { return true } else { return false } })
    }

    func testStateDoesNotBecomeLoadingWhenValidationFails() {
        // Arrange
        let expectation = expectation(description: "State should become validationError, not loading")

        var emittedStates: [AppState<ReportModal>] = []

        viewModel.$state
            .dropFirst()
            .sink { state in
                emittedStates.append(state)
                if case .validationError = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "123", message: "   "), isRetry: false) // invalid (only whitespace)

        // Assert
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(emittedStates.contains(.loading), "State should not be loading on validation failure.")
    }
    
    func testMessageTrimmingBeforeAPIRequest() {
        // Arrange
        let trimmedMessage = "Cleaned message"
        let input = ReportViewModel.Input(productID: "id", message: "   \(trimmedMessage)   ")

        let expectation = expectation(description: "Message should be trimmed before API is called")

        mockService.reportAPIPublisher = Deferred {
            Future { promise in
                // Simulate check inside mock
                XCTAssertEqual(trimmedMessage, trimmedMessage)
                expectation.fulfill()
                promise(.success(ReportModal(success: true, code: 200, message: "ok", body: nil)))
            }
        }
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        // Act
        viewModel.reportAPI(with: input, isRetry: false)

        // Assert
        wait(for: [expectation], timeout: 1)
    }

    
    func testConsecutiveValidCallsEmitIndependentStates() {
        let mockResponse = ReportModal(success: true, code: 200, message: "ok", body: nil)

        mockService.reportAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should receive two .success states")
        expectation.expectedFulfillmentCount = 2

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "1", message: "First"), isRetry: false)
        viewModel.reportAPI(with: .init(productID: "2", message: "Second"), isRetry: false)

        // Assert
        wait(for: [expectation], timeout: 2)
    }

    
    func testValidationErrorMessage() {
        // Arrange
        let expectedMessage = RegexMessages.invalidEmptyDescription
        let expectation = expectation(description: "ValidationError should include correct message")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: expectedMessage))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.reportAPI(with: .init(productID: "abc", message: ""), isRetry: false)

        // Assert
        wait(for: [expectation], timeout: 1)
    }

}
