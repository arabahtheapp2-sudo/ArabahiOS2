//
//  ChangeLanViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ChangeLanViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Success Tests
    
    func testChangeLanguageAPISuccess() {
        // Given
        let mockService = MockSettingsService()
        let successResponse = LoginModal(
            success: true,
            code: 200,
            message: "Language changed successfully",
            body: nil
        )
        
        mockService.changeLanguageAPIPublisher = Just(successResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let viewModel = ChangeLanViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach success")
        
        // When
        viewModel.$state
            .dropFirst() // skip initial idle state
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.changeLanguageAPI(with: "en")
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Failure Tests
    
    func testChangeLanguageAPIFailure() {
        // Given
        let mockService = MockSettingsService()
        mockService.changeLanguageAPIPublisher = Fail(error: NetworkError.badRequest(message: "Invalid language code"))
            .eraseToAnyPublisher()

        let viewModel = ChangeLanViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, "Invalid language code")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.changeLanguageAPI(with: "invalid")
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Retry Tests
    
    func testRetryChangeLanguageAPI() {
        // Given
        let mockService = MockSettingsService()
        let successResponse = LoginModal(
            success: true,
            code: 200,
            message: "Language changed successfully",
            body: nil
        )
        
        // First call fails
        mockService.changeLanguageAPIPublisher = Fail(error: NetworkError.networkError("Network error"))
            .eraseToAnyPublisher()
        
        let viewModel = ChangeLanViewModel(settingsServices: mockService)
        
        // Set up expectation for initial failure
        let initialFailureExpectation = XCTestExpectation(description: "Initial call should fail")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    initialFailureExpectation.fulfill()
                    
                    // After initial failure, set up success response for retry
                    mockService.changeLanguageAPIPublisher = Just(successResponse)
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                    
                    // Then retry
                    viewModel.retryChangeLanguageAPI()
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
        viewModel.changeLanguageAPI(with: "ar")
        
        // Then
        wait(for: [initialFailureExpectation, retrySuccessExpectation], timeout: 3.0)
    }
    
    func testRetryParamsStorage() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ChangeLanViewModel(settingsServices: mockService)
        
        // When
        viewModel.changeLanguageAPI(with: "fr")
        
        // Then
        XCTAssertEqual(viewModel.retryParams, "fr", "Should store language for retry")
    }
    
    func testRetryWithoutPreviousCall() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ChangeLanViewModel(settingsServices: mockService)
        
        // When
        viewModel.retryChangeLanguageAPI() // No previous call made
        
        // Then
        // Should not crash and state should remain idle
        if case .idle = viewModel.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("State should remain idle when retrying without previous call")
        }
    }
    
    // MARK: - State Transition Tests
    
    func testStateTransitions() {
        // Given
        let mockService = MockSettingsService()
        let successResponse = LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )
        
        mockService.changeLanguageAPIPublisher = Just(successResponse)
            .setFailureType(to: NetworkError.self)
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .eraseToAnyPublisher()

        let viewModel = ChangeLanViewModel(settingsServices: mockService)
        let expectations = [
            XCTestExpectation(description: "Should transition to loading"),
            XCTestExpectation(description: "Should transition to success")
        ]
        
        var stateHistory: [AppState<LoginModal>] = []
        
        // When
        viewModel.$state
            .sink { state in
                stateHistory.append(state)
                
                if stateHistory.count == 2 {
                    if case .loading = stateHistory[1] {
                        expectations[0].fulfill()
                    }
                }
                
                if stateHistory.count == 3 {
                    if case .success = stateHistory[2] {
                        expectations[1].fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.changeLanguageAPI(with: "en")
        
        // Then
        wait(for: expectations, timeout: 2.0)
    }
    
    func testCombineBindingOrderOnSuccess() {
        let mockService = MockSettingsService()
        
        let successResponse = LoginModal(
            success: true,
            code: 200,
            message: "OK",
            body: nil
        )
        
        mockService.changeLanguageAPIPublisher = Just(successResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = ChangeLanViewModel(settingsServices: mockService)
        
        var states: [AppState<LoginModal>] = []
        let expectation = XCTestExpectation(description: "Expect 3 state changes")
        expectation.expectedFulfillmentCount = 3

        viewModel.$state
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.changeLanguageAPI(with: "en")

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(states.count, 3)
        XCTAssertEqual(states[0], .idle)
        XCTAssertEqual(states[1], .loading)
        XCTAssertEqual(states[2], .success(successResponse))
    }

    
    
}
