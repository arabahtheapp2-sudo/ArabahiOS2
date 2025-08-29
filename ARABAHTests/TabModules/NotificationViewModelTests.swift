//
//  NotificationViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class NotificationViewModelTests: XCTestCase {
    
    private var viewModel: NotificationViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = NotificationViewModel(networkService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test: getNotificationList Success
    
    func testGetNotificationListSuccess() {
        // Given
        
        let modal = GetNotificationModal(success: true, code: 200, message: "ok", body: nil)
        
        mockService.getNotificationListPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Get notification list success")
        
        // When
        viewModel.$listState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getNotificationList()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.count(), 1)
        XCTAssertFalse(viewModel.isEmpty)
        XCTAssertEqual(viewModel.productID(at: 0), "p1")
    }
    
    // MARK: - Test: getNotificationList Failure
    
    func testGetNotificationListFailure() {
        // Given
        mockService.getNotificationListPublisher = Fail(error: NetworkError.networkError("No internet"))
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Get notification list failure")
        
        viewModel.$listState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.networkError("No internet").localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.getNotificationList()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertTrue(viewModel.isEmpty)
    }
    
    // MARK: - Test: notificationDeleteAPI Success
    
    func testNotificationDeleteSuccess() {
        // Given
        let response = NewCommonString(success: true, code: 200, message: "Deleted",body: nil)
        mockService.notificationDeleteAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Notification delete success")
        
        viewModel.$listDeleteState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.notificationDeleteAPI()
        
        // Then
        wait(for: [expectation], timeout: 2)
    }
    
    // MARK: - Test: notificationDeleteAPI Failure
    
    func testNotificationDeleteFailure() {
        // Given
        mockService.notificationDeleteAPIPublisher = Fail(error: NetworkError.badRequest(message: "Delete failed"))
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Notification delete failure")
        
        viewModel.$listDeleteState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.badRequest(message: "Delete failed").localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.notificationDeleteAPI()
        
        // Then
        wait(for: [expectation], timeout: 2)
    }
    
    // MARK: - Test: Retry
    
    func testRetryGetNotificationTriggersFetch() {
        // First trigger a failure
        mockService.getNotificationListPublisher = Fail(error: NetworkError.badRequest(message: "error"))
            .eraseToAnyPublisher()
        viewModel.getNotificationList()
        
        // Set up a success response
        
        let modal = GetNotificationModal(success: true, code: 200, message: "ok", body: nil)
        mockService.getNotificationListPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Retry get notification works")
        
        viewModel.$listState
            .dropFirst(2) // skip loading + failure
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.retryGetNotification()
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.count(), 1)
    }
    
    func testInitialListStateIsIdle() {
        XCTAssertEqual(viewModel.listState, .idle)
    }
    
    func testInitialDeleteStateIsIdle() {
        XCTAssertEqual(viewModel.listDeleteState, .idle)
    }
    
    func testIsEmptyWhenNoData() {
        viewModel.clearList()
        XCTAssertTrue(viewModel.isEmpty)
    }
    
    
    func testStateTransitionsFromLoadingToSuccess() {
        let modal = GetNotificationModal(success: true, code: 200, message: "ok", body: [])
        mockService.getNotificationListPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        var states: [AppState<GetNotificationModal>] = []
        
        let expectation = expectation(description: "Track state changes")
        
        viewModel.$listState
            .sink { state in
                states.append(state)
                if states.count == 2 { // loading → success
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getNotificationList()
        
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(states.count, 2)
        XCTAssertEqual(states[0], .loading)
        if case .success(let modal) = states[1] {
            XCTAssertEqual(modal.message, "ok")
        } else {
            XCTFail("Expected success state")
        }
    }
    
    func testStateTransitionsFromLoadingToFailure() {
        mockService.getNotificationListPublisher = Fail(error: NetworkError.serverError(message: "Fail"))
            .eraseToAnyPublisher()
        
        var states: [AppState<GetNotificationModal>] = []
        
        let expectation = expectation(description: "Track failure state transitions")
        
        viewModel.$listState
            .sink { state in
                states.append(state)
                if states.count == 2 { // loading → failure
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.getNotificationList()
        
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(states[0], .loading)
        if case .failure(let error) = states[1] {
            XCTAssertEqual(error.localizedDescription, NetworkError.serverError(message: "Fail").localizedDescription)
        } else {
            XCTFail("Expected failure state")
        }
    }
    
    
    
}

