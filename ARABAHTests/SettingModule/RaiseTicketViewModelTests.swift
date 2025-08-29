//
//  RaiseTicketViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class RaiseTicketViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Success Tests
    
    func testGetTicketAPISuccess() {
        // Given
        let mockService = MockSettingsService()
        
        
        mockService.getTicketAPIPublisher = Just(getTicketModal(
            success: true,
            code: 200,
            message: "Success",
            body: [])
        ).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        
        // Expectations
        let stateExpectation = XCTestExpectation(description: "State should reach success")
        let ticketBodyExpectation = XCTestExpectation(description: "Ticket body should be populated")
        
        // When
        // Test state transitions
        viewModel.$state
            .dropFirst() // skip initial idle state
            .sink { state in
                if case .success = state {
                    stateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Test ticket body population
        viewModel.$ticketBody
            .dropFirst() // skip initial empty array
            .sink { ticketBody in
                if ticketBody?.count == 1 {
                    ticketBodyExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getTicketAPI()
        
        // Then
        wait(for: [stateExpectation, ticketBodyExpectation], timeout: 2.0)
    }
    
    // MARK: - Failure Tests
    
    func testGetTicketAPIFailure() {
        // Given
        let mockService = MockSettingsService()
        mockService.getTicketAPIPublisher = Fail(error: NetworkError.badRequest(message: "Bad request"))
            .eraseToAnyPublisher()

        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, "Bad request")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getTicketAPI()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetTicketAPIEmptyResponse() {
        // Given
        let mockService = MockSettingsService()
        mockService.getTicketAPIPublisher = Just(getTicketModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil)
        ).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach failure with invalid response")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.invalidResponse.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getTicketAPI()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Retry Tests
    
    func testRetryGetTicket() {
        // Given
        let mockService = MockSettingsService()
        
        
        // First call fails
        mockService.getTicketAPIPublisher = Fail(error: NetworkError.networkError("Network error"))
            .eraseToAnyPublisher()
        
        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        
        // Set up expectation for initial failure
        let initialFailureExpectation = XCTestExpectation(description: "Initial call should fail")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    initialFailureExpectation.fulfill()
                    
                    // After initial failure, set up success response for retry
                    mockService.getTicketAPIPublisher = Just(getTicketModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: [])
                    ).setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
                    
                    // Then retry
                    viewModel.retryGetTicket()
                }
            }
            .store(in: &cancellables)
        
        // Set up expectation for retry success
        let retrySuccessExpectation = XCTestExpectation(description: "Retry should succeed")
        
        viewModel.$state
            .dropFirst(2) // skip initial idle and first failure
            .sink { state in
                if case .success = state {
                    retrySuccessExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.getTicketAPI()
        
        // Then
        wait(for: [initialFailureExpectation, retrySuccessExpectation], timeout: 3.0)
    }
    
    // MARK: - Ticket Body Initialization
    
    func testTicketBodyInitialization() {
        // Given
        let mockService = MockSettingsService()
        
        
        mockService.getTicketAPIPublisher = Just(getTicketModal(
            success: true,
            code: 200,
            message: "Success",
            body: [])
        ).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "Ticket body should contain correct data")
        
        // When
        viewModel.$ticketBody
            .dropFirst()
            .sink { ticketBody in
                if let firstTicket = ticketBody?.first {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getTicketAPI()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testStateSequenceOnSuccess() {
        // Given
        let mockService = MockSettingsService()
        mockService.getTicketAPIPublisher = Just(getTicketModal(
            success: true,
            code: 200,
            message: "Success",
            body: [])
        ).setFailureType(to: NetworkError.self)
         .eraseToAnyPublisher()
        
        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        
        var emittedStates: [AppState<getTicketModal>] = []
        let expectation = XCTestExpectation(description: "Should emit correct state transitions")
        expectation.expectedFulfillmentCount = 3

        // When
        viewModel.$state
            .sink { state in
                emittedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.getTicketAPI()

        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(emittedStates.count, 3)
        XCTAssertEqual(emittedStates[0], .idle)
        XCTAssertEqual(emittedStates[1], .loading)
        if case .success(let result) = emittedStates[2] {
            XCTAssertEqual(result.message, "Success")
        } else {
            XCTFail("Expected success state at position 2")
        }
    }

    
    func testTicketBodyCombineBinding() {
        // Given
        let mockService = MockSettingsService()
        
        mockService.getTicketAPIPublisher = Just(getTicketModal(
            success: true,
            code: 200,
            message: "OK",
            body: [])
        ).setFailureType(to: NetworkError.self)
         .eraseToAnyPublisher()
        
        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "ticketBody should emit list with one element")

        // When
        viewModel.$ticketBody
            .dropFirst() // skip initial empty state
            .sink { body in
                if let body = body, body.count == 1, body.first?.id == "42" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getTicketAPI()

        // Then
        wait(for: [expectation], timeout: 2.0)
    }

    func testRetryResetsStateToIdle() {
        // Given
        let mockService = MockSettingsService()
        
        // First call fails
        mockService.getTicketAPIPublisher = Fail(error: NetworkError.serverError(message: "Initial Failure"))
            .eraseToAnyPublisher()

        let viewModel = RaiseTicketViewModel(settingsServices: mockService)
        
        let failureExpectation = XCTestExpectation(description: "Initial call should fail")
        let idleExpectation = XCTestExpectation(description: "State should reset to idle before retry")
        let successExpectation = XCTestExpectation(description: "Retry should succeed")

        var stateHistory: [AppState<getTicketModal>] = []
        
        viewModel.$state
            .sink { state in
                stateHistory.append(state)
                
                if case .failure = state {
                    failureExpectation.fulfill()

                    // Set success response for retry
                    mockService.getTicketAPIPublisher = Just(getTicketModal(
                        success: true,
                        code: 200,
                        message: "OK",
                        body: [])
                    ).setFailureType(to: NetworkError.self)
                     .eraseToAnyPublisher()

                    viewModel.retryGetTicket()
                }

                if stateHistory.contains(.idle), state == .idle {
                    idleExpectation.fulfill()
                }

                if case .success = state {
                    successExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.getTicketAPI()

        // Then
        wait(for: [failureExpectation, idleExpectation, successExpectation], timeout: 3.0)
    }

    
    
}

