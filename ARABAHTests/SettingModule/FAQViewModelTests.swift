//
//  FAQViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class FAQViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    func testGetFaqListAPISuccess() {
        // Given
        let mockService = MockSettingsService()
        let jsonString = """
        {
            "_id": "1",
            "question": "Test question",
            "answer": "Test answer"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let faqItem = try! JSONDecoder().decode(FaqModalBody.self, from: data)
        
        mockService.getFaqListAPIPublisher = Just(FaqModal(
            success: true,
            code: 200,
            message: "Success",
            body: [faqItem])
        ).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = FAQViewModel(settingsServices: mockService)
        
        // Expectations
        let stateExpectation = XCTestExpectation(description: "State should reach success")
        let faqListExpectation = XCTestExpectation(description: "FAQ list should be populated")
        
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
        
        // Test FAQ list population
        viewModel.$faqList
            .dropFirst() // skip initial empty array
            .sink { faqList in
                if faqList?.count == 1 {
                    faqListExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getFaqListAPI()
        
        // Then
        wait(for: [stateExpectation, faqListExpectation], timeout: 2.0)
    }
    
    func testGetFaqListAPIFailure() {
        // Given
        let mockService = MockSettingsService()
        mockService.getFaqListAPIPublisher = Fail(error: NetworkError.badRequest(message: "Bad request")).eraseToAnyPublisher()

        let viewModel = FAQViewModel(settingsServices: mockService)
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

        viewModel.getFaqListAPI()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testGetFaqListAPIEmptyResponse() {
        // Given
        let mockService = MockSettingsService()
        mockService.getFaqListAPIPublisher = Just(FaqModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil)
        ).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = FAQViewModel(settingsServices: mockService)
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

        viewModel.getFaqListAPI()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRetryGetFaqList() {
        // Given
        let mockService = MockSettingsService()
        let jsonString = """
        {
            "_id": "1",
            "question": "Test question",
            "answer": "Test answer"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let sampleFAQ = try! JSONDecoder().decode(FaqModalBody.self, from: data)
        
        // First call fails
        mockService.getFaqListAPIPublisher = Fail(error: NetworkError.networkError("Network error"))
            .eraseToAnyPublisher()
        
        let viewModel = FAQViewModel(settingsServices: mockService)
        
        // Set up expectation for initial failure
        let initialFailureExpectation = XCTestExpectation(description: "Initial call should fail")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    initialFailureExpectation.fulfill()
                    
                    // After initial failure, set up success response for retry
                    mockService.getFaqListAPIPublisher = Just(FaqModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: [sampleFAQ])
                    ).setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
                    
                    // Then retry
                    viewModel.retryGetFaqList()
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
        viewModel.getFaqListAPI()
        
        // Then
        wait(for: [initialFailureExpectation, retrySuccessExpectation], timeout: 3.0)
    }
    
    func testStateSequenceOnSuccess() {
        // Given
        let mockService = MockSettingsService()
        let jsonString = """
        {
            "_id": "1",
            "question": "Test question",
            "answer": "Test answer"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let sampleFAQ = try! JSONDecoder().decode(FaqModalBody.self, from: data)
        
        
        mockService.getFaqListAPIPublisher = Just(FaqModal(
            success: true,
            code: 200,
            message: "OK",
            body: [sampleFAQ])
        ).setFailureType(to: NetworkError.self)
         .eraseToAnyPublisher()
        
        let viewModel = FAQViewModel(settingsServices: mockService)
        var emittedStates: [AppState<FaqModal>] = []

        let expectation = XCTestExpectation(description: "Should emit idle → loading → success")
        expectation.expectedFulfillmentCount = 3

        // When
        viewModel.$state
            .sink { state in
                emittedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.getFaqListAPI()
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(emittedStates.count, 3)
        XCTAssertEqual(emittedStates[0], .idle)
        XCTAssertEqual(emittedStates[1], .loading)
        if case .success(let response) = emittedStates[2] {
            XCTAssertEqual(response.code, 200)
            XCTAssertEqual(response.message, "OK")
        } else {
            XCTFail("Expected .success state")
        }
    }

    func testFaqListCombineBinding() {
        // Given
        let mockService = MockSettingsService()
        let jsonString = """
        {
            "_id": "1",
            "question": "Test question",
            "answer": "Test answer"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let faqItem = try! JSONDecoder().decode(FaqModalBody.self, from: data)
        
        mockService.getFaqListAPIPublisher = Just(FaqModal(
            success: true,
            code: 200,
            message: "Fetched",
            body: [faqItem])
        ).setFailureType(to: NetworkError.self)
         .eraseToAnyPublisher()

        let viewModel = FAQViewModel(settingsServices: mockService)
        let faqExpectation = XCTestExpectation(description: "FAQ list should emit with correct content")

        viewModel.$faqList
            .dropFirst()
            .sink { list in
                guard let list = list else {
                    XCTFail("FAQ list should not be nil")
                    return
                }
                if list.count == 1, list[0].id == "42" {
                    faqExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.getFaqListAPI()

        // Then
        wait(for: [faqExpectation], timeout: 2.0)
    }
    
    
    func testRetryResetsStateToIdle() {
        // Given
        let mockService = MockSettingsService()
        mockService.getFaqListAPIPublisher = Fail(error: NetworkError.serverError(message: "Fail"))
            .eraseToAnyPublisher()
        
        let viewModel = FAQViewModel(settingsServices: mockService)
        
        let failureExpectation = XCTestExpectation(description: "Should reach failure first")
        let idleExpectation = XCTestExpectation(description: "Should reset to idle before retry")
        let successExpectation = XCTestExpectation(description: "Should succeed on retry")
        
        let jsonString = """
        {
            "_id": "1",
            "question": "Test question",
            "answer": "Test answer"
        }
        """

        let data = jsonString.data(using: .utf8)!
        let faqItem = try! JSONDecoder().decode(FaqModalBody.self, from: data)
        
        var stateHistory: [AppState<FaqModal>] = []

        viewModel.$state
            .sink { state in
                stateHistory.append(state)
                if case .failure = state {
                    failureExpectation.fulfill()
                    // Mock next call to succeed
                    mockService.getFaqListAPIPublisher = Just(FaqModal(success: true, code: 200, message: "OK", body: [faqItem]))
                        .setFailureType(to: NetworkError.self)
                        .eraseToAnyPublisher()
                    viewModel.retryGetFaqList()
                }
                if stateHistory.contains(.idle), stateHistory.last == .idle {
                    idleExpectation.fulfill()
                }
                if case .success = state {
                    successExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.getFaqListAPI()
        
        // Then
        wait(for: [failureExpectation, idleExpectation, successExpectation], timeout: 3.0)
    }

    
    
}
