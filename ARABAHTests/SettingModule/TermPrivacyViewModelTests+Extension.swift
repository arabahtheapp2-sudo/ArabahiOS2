//
//  TermPrivacyViewModelTests+Extension.swift
//  ARABAH
//
//  Created by cqlm2 on 17/10/25.
//

import XCTest
import Combine
@testable import ARABAH

extension TermPrivacyViewModelTests {
    
    func testDifferentContentTypes() {
        // Given
        let mockService = MockSettingsService()
        let termsContent = TermsPrivacyModelBody(
            id: "1", type: 0, title: NSLocalizedString("Terms & Conditions", comment: ""), description: NSLocalizedString("الشروط والأحكام", comment: ""), descriptionArabic: "", updatedAt: "")
        
        let privacyContent = TermsPrivacyModelBody(
            id: "1", type: 2, title: NSLocalizedString("Privacy Policy", comment: ""), description: NSLocalizedString("لشروط والأحكامسياسة الخصوصية,", comment: ""), descriptionArabic: "", updatedAt: "")
        
        let aboutContent = TermsPrivacyModelBody(
            id: "1", type: 1, title: NSLocalizedString("About Us", comment: ""), description: NSLocalizedString("لشروط والأحكامسياسة الخصوصيةمعلومات عنا", comment: ""), descriptionArabic: "", updatedAt: "")
        
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

    
    
}
