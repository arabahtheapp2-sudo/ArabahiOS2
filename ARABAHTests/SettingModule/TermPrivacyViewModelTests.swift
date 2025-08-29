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
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Success Tests
    
    func testFetchContentSuccess() {
        // Given
        let mockService = MockSettingsService()
        let body = TermsPrivacyModelBody(
            id: "1",
            type:0,
            title: "Terms & Conditions",
            description: "الشروط والأحكام",
            descriptionArabic: "",
            updatedAt: ""
        )
        
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
    
    func testDifferentContentTypes() {
        // Given
        let mockService = MockSettingsService()
        let termsContent = TermsPrivacyModelBody(
            id: "1",
            type:0,
            title: "Terms & Conditions",
            description: "الشروط والأحكام",
            descriptionArabic: "",
            updatedAt: ""
        )
        
        let privacyContent = TermsPrivacyModelBody(
            id: "1",
            type:2,
            title: "Privacy Policy",
            description: "لشروط والأحكامسياسة الخصوصية,",
            descriptionArabic: "",
            updatedAt: ""
        )
        
        let aboutContent = TermsPrivacyModelBody(
            id: "1",
            type:1,
            title: "About Us",
            description: "لشروط والأحكامسياسة الخصوصيةمعلومات عنا",
            descriptionArabic: "",
            updatedAt: ""
        )
        
        // Test for Terms (type 0)
        mockService.fetchContentPublisher = Just(TermsPrivacyModel(
            success: true,
            code: 200,
            message: "Success",
            body: termsContent
        ))
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let termsViewModel = TermPrivacyViewModel(settingsService: mockService)
        let termsExpectation = XCTestExpectation(description: "Should receive terms content")
        
        termsViewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let content) = state {
                    XCTAssertEqual(content.type, 0)
                    termsExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        termsViewModel.fetchContent(with: 0)
        
        // Test for Privacy (type 1)
        mockService.fetchContentPublisher = Just(TermsPrivacyModel(
            success: true,
            code: 200,
            message: "Success",
            body: privacyContent
        ))
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let privacyViewModel = TermPrivacyViewModel(settingsService: mockService)
        let privacyExpectation = XCTestExpectation(description: "Should receive privacy content")
        
        privacyViewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let content) = state {
                    XCTAssertEqual(content.type, 1)
                    privacyExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        privacyViewModel.fetchContent(with: 1)
        
        // Test for About (type 2)
        mockService.fetchContentPublisher = Just(TermsPrivacyModel(
            success: true,
            code: 200,
            message: "Success",
            body: aboutContent
        ))
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let aboutViewModel = TermPrivacyViewModel(settingsService: mockService)
        let aboutExpectation = XCTestExpectation(description: "Should receive about content")
        
        aboutViewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let content) = state {
                    XCTAssertEqual(content.type, 2)
                    aboutExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        aboutViewModel.fetchContent(with: 2)
        
        // Then
        wait(for: [termsExpectation, privacyExpectation, aboutExpectation], timeout: 3.0)
    }
    
    
    func testStateTransitionSequenceOnSuccess() {
        // Given
        let mockService = MockSettingsService()
        let body = TermsPrivacyModelBody(
            id: "1", type: 0, title: "Terms", description: "", descriptionArabic: "", updatedAt: "")
        
        mockService.fetchContentPublisher = Just(TermsPrivacyModel(
            success: true, code: 200, message: "OK", body: nil)
        ).setFailureType(to: NetworkError.self)
         .eraseToAnyPublisher()

        let viewModel = TermPrivacyViewModel(settingsService: mockService)
        
        var stateHistory: [AppState<TermsPrivacyModelBody>] = []
        let expectation = XCTestExpectation(description: "Should emit loading then success")
        expectation.expectedFulfillmentCount = 2
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                stateHistory.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchContent(with: 0)

        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(stateHistory.count, 2)
        XCTAssertEqual(stateHistory[0], .loading)
        if case .success(let content) = stateHistory[1] {
            XCTAssertEqual(content.title, "Terms")
        } else {
            XCTFail("Expected .success in second state")
        }
    }

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

    func testRetryStartsWithIdleThenLoading() {
        // Given
        let mockService = MockSettingsService()
        let body = TermsPrivacyModelBody(
            id: "1", type: 1, title: "About Us", description: "", descriptionArabic: "", updatedAt: "")
        
        // First call fails
        mockService.fetchContentPublisher = Fail(error: NetworkError.unauthorized)
            .eraseToAnyPublisher()
        
        let viewModel = TermPrivacyViewModel(settingsService: mockService)

        var stateChanges: [AppState<TermsPrivacyModelBody>] = []
        let expectation = XCTestExpectation(description: "Should emit failure, idle, loading, success")
        expectation.expectedFulfillmentCount = 4

        viewModel.$state
            .sink { state in
                stateChanges.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Trigger failure
        viewModel.fetchContent(with: 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Setup for retry
            mockService.fetchContentPublisher = Just(TermsPrivacyModel(
                success: true,
                code: 200,
                message: "OK",
                body: body
            )).setFailureType(to: NetworkError.self)
             .eraseToAnyPublisher()
            
            viewModel.retryFetchContent()
        }

        // Then
        wait(for: [expectation], timeout: 3.0)

        XCTAssertTrue(stateChanges.contains(.idle), "Should include idle before retry")
        XCTAssertTrue(stateChanges.contains(.loading), "Should go to loading after idle")
        XCTAssertTrue(stateChanges.contains(where: {
            if case .success(let value) = $0 {
                return value.title == "About Us"
            }
            return false
        }), "Should emit success eventually")
    }

    
}
