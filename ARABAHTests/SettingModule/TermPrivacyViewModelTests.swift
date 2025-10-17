//
//  TermPrivacyViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class TermPrivacyViewModelTests: XCTestCase {
     var cancellables = Set<AnyCancellable>()
    
    // MARK: - Success Tests
    
    func testFetchContentSuccess() {
        // Given
        let mockService = MockSettingsService()
        let body = TermsPrivacyModelBody(
            id: "1", type: 0, title: NSLocalizedString("Terms & Conditions", comment: ""), description: NSLocalizedString("الشروط والأحكام", comment: ""), descriptionArabic: "", updatedAt: "" )
        
        mockService.fetchContentPublisher = Just(TermsPrivacyModel(
            success: true,
            code: 200,
            message: "Success",
            body: body
        ))
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = TermPrivacyViewModel(settingsService: mockService)
        
        // Expectations
        let stateExpectation = XCTestExpectation(description: "State should reach success")
        let contentExpectation = XCTestExpectation(description: "Should receive correct content")
        
        // When
        viewModel.$state
            .dropFirst() // skip initial idle state
            .sink { state in
                if case .success(let content) = state {
                    XCTAssertEqual(content.title, "Terms of Service")
                    XCTAssertEqual(content.type, 0)
                    stateExpectation.fulfill()
                    contentExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchContent(with: 0) // 0 for Terms
        
        // Then
        wait(for: [stateExpectation, contentExpectation], timeout: 2.0)
    }
    
    // MARK: - Failure Tests
    
    func testFetchContentFailure() {
        // Given
        let mockService = MockSettingsService()
        mockService.fetchContentPublisher = Fail(error: NetworkError.badRequest(message: "Invalid content type"))
            .eraseToAnyPublisher()

        let viewModel = TermPrivacyViewModel(settingsService: mockService)
        let expectation = XCTestExpectation(description: "State should reach failure")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, "Invalid content type")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchContent(with: 99) // Invalid type
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchContentEmptyResponse() {
        // Given
        let mockService = MockSettingsService()
        mockService.fetchContentPublisher = Just(TermsPrivacyModel(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        ))
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = TermPrivacyViewModel(settingsService: mockService)
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

        viewModel.fetchContent(with: 1) // 1 for Privacy
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Retry Tests
    
    func testRetryFetchContent() {
        // Given
        let mockService = MockSettingsService()
        
        // First call fails
        mockService.fetchContentPublisher = Fail(error: NetworkError.networkError("Network error"))
            .eraseToAnyPublisher()
        
        let viewModel = TermPrivacyViewModel(settingsService: mockService)
        
        // Set up expectation for initial failure
        let initialFailureExpectation = XCTestExpectation(description: "Initial call should fail")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    initialFailureExpectation.fulfill()
                    
                    // After initial failure, set up success response for retry
                    mockService.fetchContentPublisher = Just(TermsPrivacyModel(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil
                    ))
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
                    
                    // Then retry
                    viewModel.retryFetchContent()
                }
            }
            .store(in: &cancellables)
        
        // Set up expectation for retry success
        let retrySuccessExpectation = XCTestExpectation(description: "Retry should succeed")
        
        viewModel.$state
            .dropFirst(2) // skip initial idle and first failure
            .sink { state in
                if case .success(let content) = state {
                    XCTAssertEqual(content.title, "About Us")
                    retrySuccessExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.fetchContent(with: 2) // 2 for About Us
        
        // Then
        wait(for: [initialFailureExpectation, retrySuccessExpectation], timeout: 3.0)
    }
    
    func testRetryParamsStorage() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = TermPrivacyViewModel(settingsService: mockService)
        
        // When
        viewModel.fetchContent(with: 1) // 1 for Privacy
        
        // Then
        XCTAssertEqual(viewModel.retryParams, 1, "Should store content type for retry")
    }
    
    func testRetryWithoutPreviousCall() {
        // Given
        let mockService = MockSettingsService()
        let viewModel = TermPrivacyViewModel(settingsService: mockService)
        
        // When
        viewModel.retryFetchContent() // No previous call made
        
        // Then
        // Should not crash and state should remain idle
        if case .idle = viewModel.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("State should remain idle when retrying without previous call")
        }
    }
    
    // MARK: - Content Type Tests
    
    
    func testCombineBindingEmitsCorrectValue() {
        // Given
        let mockService = MockSettingsService()
        let expectedTitle = "Privacy Policy"
        let body = TermsPrivacyModelBody(
            id: "1", type: 2, title: expectedTitle, description: "", descriptionArabic: "", updatedAt: "")
        
        mockService.fetchContentPublisher = Just(TermsPrivacyModel(
            success: true, code: 200, message: "OK", body: body)
        ).setFailureType(to: NetworkError.self)
         .eraseToAnyPublisher()

        let viewModel = TermPrivacyViewModel(settingsService: mockService)

        let expectation = XCTestExpectation(description: "Should emit correct content")

        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let content) = state {
                    XCTAssertEqual(content.title, expectedTitle)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchContent(with: 2)

        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
}
