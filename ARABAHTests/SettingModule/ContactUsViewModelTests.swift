//
//  ContactUsViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//


import XCTest
import Combine
@testable import ARABAH

final class ContactUsViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Success Tests
    
    func testContactUsAPISuccess() {
        // Given
        let mockService = MockSettingsService()
        let successResponse = ContactUsModal(
            success: true,
            code: 200,
            message: "Message sent successfully",
            body: nil
        )
        
        mockService.contactUsAPIPublisher = Just(successResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let viewModel = ContactUsViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach success")
        
        // When
        viewModel.$state
            .dropFirst() // skip initial idle state
            .sink { state in
                if case .success(let response) = state {
                    XCTAssertTrue(response.success ?? false)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.contactUsAPI(
            name: "John Doe",
            email: "john@example.com",
            message: "Test message"
        )
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Failure Tests
    
    func testContactUsAPIFailure() {
        // Given
        let mockService = MockSettingsService()
        mockService.contactUsAPIPublisher = Fail(error: NetworkError.badRequest(message: "Invalid email"))
            .eraseToAnyPublisher()

        let viewModel = ContactUsViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, "Invalid email")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.contactUsAPI(
            name: "John Doe",
            email: "john@example.com",
            message: "Test message"
        )
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Validation Tests
    
    func testEmptyNameValidation() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach validation failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, RegexMessages.emptyName)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.contactUsAPI(
            name: "",
            email: "john@example.com",
            message: "Test message"
        )
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testEmptyEmailValidation() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach validation failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, RegexMessages.emptyEmail)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.contactUsAPI(
            name: "John Doe",
            email: "",
            message: "Test message"
        )
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testInvalidEmailValidation() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach validation failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, RegexMessages.invalidEmail)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.contactUsAPI(
            name: "John Doe",
            email: "invalid-email",
            message: "Test message"
        )
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testEmptyMessageValidation() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        let expectation = XCTestExpectation(description: "State should reach validation failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, RegexMessages.emptyMessage)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.contactUsAPI(
            name: "John Doe",
            email: "john@example.com",
            message: ""
        )
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Retry Tests
    
    func testRetryContactUs() {
        // Given
        let mockService = MockSettingsService()
        let successResponse = ContactUsModal(
            success: true,
            code: 200,
            message: "Message sent successfully",
            body: nil
        )
        
        // First call fails
        mockService.contactUsAPIPublisher = Fail(error: NetworkError.networkError("Network error"))
            .eraseToAnyPublisher()
        
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        
        // Set up expectation for initial failure
        let initialFailureExpectation = XCTestExpectation(description: "Initial call should fail")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    initialFailureExpectation.fulfill()
                    
                    // After initial failure, set up success response for retry
                    mockService.contactUsAPIPublisher = Just(successResponse)
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                    
                    // Then retry
                    viewModel.retryContactUs()
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
        viewModel.contactUsAPI(
            name: "John Doe",
            email: "john@example.com",
            message: "Test message"
        )
        
        // Then
        wait(for: [initialFailureExpectation, retrySuccessExpectation], timeout: 3.0)
    }
    
    func testRetryParamsStorage() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        
        // When
        viewModel.contactUsAPI(
            name: "Jane Smith",
            email: "jane@example.com",
            message: "Another test message"
        )
        
        // Then
        XCTAssertEqual(viewModel.previousParams?.name, "Jane Smith")
        XCTAssertEqual(viewModel.previousParams?.email, "jane@example.com")
        XCTAssertEqual(viewModel.previousParams?.message, "Another test message")
    }
    
    func testRetryWithoutPreviousCall() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        
        // When
        viewModel.retryContactUs() // No previous call made
        
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
        let successResponse = ContactUsModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )
        
        mockService.contactUsAPIPublisher = Just(successResponse)
            .setFailureType(to: NetworkError.self)
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .eraseToAnyPublisher()

        let viewModel = ContactUsViewModel(settingsServices: mockService)
        let expectations = [
            XCTestExpectation(description: "Should transition to loading"),
            XCTestExpectation(description: "Should transition to success")
        ]
        
        var stateHistory: [AppState<ContactUsModal>] = []
        
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
        
        viewModel.contactUsAPI(
            name: "John Doe",
            email: "john@example.com",
            message: "Test message"
        )
        
        // Then
        wait(for: expectations, timeout: 2.0)
    }
    
    func testContactUsCombineStateEmissionOrder() {
        let mockService = MockSettingsService()
        let expected = ContactUsModal(success: true, code: 200, message: "Delivered", body: nil)

        mockService.contactUsAPIPublisher = Just(expected)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = ContactUsViewModel(settingsServices: mockService)
        var emittedStates: [AppState<ContactUsModal>] = []
        
        let expectation = XCTestExpectation(description: "State should emit in order")
        expectation.expectedFulfillmentCount = 3

        viewModel.$state
            .sink { state in
                emittedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.contactUsAPI(name: "A", email: "a@b.com", message: "Hi")

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(emittedStates.count, 3)
        XCTAssertEqual(emittedStates[0], .idle)
        XCTAssertEqual(emittedStates[1], .loading)
        XCTAssertEqual(emittedStates[2], .success(expected))
    }

    
}
