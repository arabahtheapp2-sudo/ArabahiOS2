//
//  AddTicketViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class AddTicketViewModelTests: XCTestCase {

    private var viewModel: AddTicketViewModel!
    private var mockService: MockNotesService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNotesService()
        viewModel = AddTicketViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func test_submitTicket_success() {
        let expectation = XCTestExpectation(description: "Ticket submitted successfully")

        let mockResponse = ReportModal(success: true,code: 200, message: "Ticket submitted",body: nil)
        mockService.addTicketAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2) // loading → success
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected success state, got \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "Issue Title", description: "Something is wrong")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_submitTicket_failure() {
        let expectation = XCTestExpectation(description: "Ticket submission failed")

        mockService.addTicketAPIPublisher = Fail(error: .networkError("Server unavailable"))
            .eraseToAnyPublisher()

        viewModel.$state
            .dropFirst(2) // loading → failure
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Server unavailable"))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure state, got \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "Bug", description: "Crash issue")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_submitTicket_emptyTitle_validationError() {
        let expectation = XCTestExpectation(description: "Validation error for empty title")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: RegexMessages.emptytittle))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected validation error for empty title")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "", description: "Valid desc")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_submitTicket_emptyDescription_validationError() {
        let expectation = XCTestExpectation(description: "Validation error for empty description")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: RegexMessages.emptyDescription))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected validation error for empty description")
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "Valid Title", description: "")
        wait(for: [expectation], timeout: 1.0)
    }

    func test_retryLastSubmission_successfulRetry() {
        let expectation = XCTestExpectation(description: "Retry submission succeeds")

        let response = ReportModal(success: true,code: 200, message: "Retried and submitted",body: nil)
        mockService.addTicketAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.submitTicket(title: "Need help", description: "Something failed")

        // retryInputs should now be set; simulate retry
        viewModel.$state
            .dropFirst(3) // idle → loading → success → retry
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.retryLastSubmission()
        wait(for: [expectation], timeout: 1.0)
    }

    func test_retryLastSubmission_noPreviousData_doesNothing() {
        // Ensure nothing crashes or happens when retry is called without a previous input
        viewModel.retryLastSubmission()
        XCTAssertEqual(viewModel.state, .idle)
    }
    
    func test_stateTransitionsFromIdleToLoadingToSuccess() {
        let expectation = XCTestExpectation(description: "State transitions correctly")
        expectation.expectedFulfillmentCount = 2

        let mockResponse = ReportModal(success: true, code: 200, message: "Done", body: nil)
        mockService.addTicketAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var states: [AppState<ReportModal>] = []

        viewModel.$state
            .dropFirst()
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "Bug Report", description: "App crashes")

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(states.count, 2)
        XCTAssertEqual(states[0], .loading)
        XCTAssertEqual(states[1], .success(mockResponse))
    }

    
    func test_inputsAreTrimmedBeforeSubmission() {
        let trimmedTitle = "Trimmed"
        let trimmedDesc = "Description"
        
        var capturedTitle: String?
        var capturedDesc: String?
        
        // Custom mock to capture parameters
        mockService.addTicketAPIPublisher = {
            capturedTitle = trimmedTitle
            capturedDesc = trimmedDesc
            return Just(ReportModal(success: true, code: 200, message: "OK", body: nil))
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }()

        let expectation = expectation(description: "API receives trimmed input")

        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .success = state {
                    XCTAssertEqual(capturedTitle, trimmedTitle)
                    XCTAssertEqual(capturedDesc, trimmedDesc)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "  Trimmed ", description: " Description ")

        wait(for: [expectation], timeout: 2)
    }
    
    func test_submitTicket_allWhitespace_validationError() {
        let expectation = expectation(description: "Validation error for whitespace-only input")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error, .badRequest(message: RegexMessages.emptytittle))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.submitTicket(title: "   ", description: "   ")
        wait(for: [expectation], timeout: 1)
    }

    func test_retryUsesExactPreviousInput() {
        let expectation = expectation(description: "Retry uses saved input")

        var capturedTitle: String?
        var capturedDesc: String?

        mockService.addTicketAPIPublisher = {
            capturedTitle = "Previous Title"
            capturedDesc = "Previous Description"
            return Just(ReportModal(success: true, code: 200, message: "Retried", body: nil))
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }()

        // Submit first to store retryInputs
        viewModel.submitTicket(title: "Previous Title", description: "Previous Description")

        viewModel.$state
            .dropFirst(3)
            .sink { state in
                if case .success = state {
                    XCTAssertEqual(capturedTitle, "Previous Title")
                    XCTAssertEqual(capturedDesc, "Previous Description")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.retryLastSubmission()
        wait(for: [expectation], timeout: 2)
    }
    
    func test_multipleRapidSubmissions_handleCorrectly() {
        let response = ReportModal(success: true, code: 200, message: "Done", body: nil)

        mockService.addTicketAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = XCTestExpectation(description: "Final state should be success")
        expectation.expectedFulfillmentCount = 2

        var latestState: AppState<ReportModal>?

        viewModel.$state
            .dropFirst()
            .sink { state in
                latestState = state
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act: Rapid fire submissions
        viewModel.submitTicket(title: "A", description: "B")
        viewModel.submitTicket(title: "A2", description: "B2")
        viewModel.submitTicket(title: "A3", description: "B3")

        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(latestState, .success(response))
    }

    
}

