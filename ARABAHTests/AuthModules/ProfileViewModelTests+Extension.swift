//
//  ProfileViewModelTests+Extension.swift
//  ARABAHTests
//
//  Created by cqlm2 on 17/10/25.
//

import XCTest
import Combine
@testable import ARABAH

extension ProfileViewModelTests {
   
    // MARK: - Profile Completion Tests
    
    func testShouldShowCompleteProfile() {
        let viewModel = ProfileViewModel()
        
        // Test with complete profile
        Store.userDetails = LoginModal(
            success: true,
            code: 200,
            message: "",
            body: nil
        )
        XCTAssertFalse(viewModel.shouldShowCompleteProfile())
        
        // Test with missing name
        Store.userDetails?.body?.name = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
        
        // Test with missing email
        Store.userDetails?.body?.name = "Test User"
        Store.userDetails?.body?.email = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
        
        // Test with missing image
        Store.userDetails?.body?.email = "test@example.com"
        Store.userDetails?.body?.image = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
        
        // Test with no user details
        Store.userDetails = nil
        XCTAssertTrue(viewModel.shouldShowCompleteProfile())
    }
    
    func testProfileStateTransitions() {
        let mockService = MockAuthService()
        
        mockService.getProfilePublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "OK",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        var receivedStates: [AppState<LoginModalBody>] = []
        let expectation = XCTestExpectation(description: "Profile state transitions")
        expectation.expectedFulfillmentCount = 3 // idle → loading → success

        viewModel.$profileState
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.performAction(input: .init(notificationStatus: nil, actionType: .getProfile))
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedStates.first, .idle)
        XCTAssertEqual(receivedStates[1], .loading)
        if case .success(let body) = receivedStates.last {
            XCTAssertEqual(body.name, "John")
        } else {
            XCTFail("Expected .success with profile body")
        }
    }
    
    func testUpdateNotificationStateTransitions() {
        let mockService = MockAuthService()
        
        mockService.updateNotiStatusPublisher = Just(LoginModal(success: true, code: 200, message: "Done", body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        var receivedStates: [AppState<LoginModal>] = []
        let expectation = XCTestExpectation(description: "Update notification state transitions")
        expectation.expectedFulfillmentCount = 3

        viewModel.$updateNotiState
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.performAction(input: .init(notificationStatus: 1, actionType: .updateNotification(1)))
        
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(receivedStates[0], .idle)
        XCTAssertEqual(receivedStates[1], .loading)
    }

    func testDeleteAccountStateTransitions() {
        let mockService = MockAuthService()
        
        mockService.deleteAccountPublisher = Just(LoginModal(success: true, code: 200, message: "Deleted", body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        var receivedStates: [AppState<LoginModal>] = []
        let expectation = XCTestExpectation(description: "Delete account state transitions")
        expectation.expectedFulfillmentCount = 3

        viewModel.$deleteAccState
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.performAction(input: .init(notificationStatus: nil, actionType: .deleteAccount))
        
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(receivedStates[0], .idle)
        XCTAssertEqual(receivedStates[1], .loading)
    }

    func testLogoutStateTransitions() {
        let mockService = MockAuthService()
        
        mockService.logoutPublisher = Just(LoginModal(success: true, code: 200, message: "Logged out", body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        var receivedStates: [AppState<LoginModal>] = []
        let expectation = XCTestExpectation(description: "Logout state transitions")
        expectation.expectedFulfillmentCount = 3

        viewModel.$logoutState
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.performAction(input: .init(notificationStatus: nil, actionType: .logout))
        
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(receivedStates[0], .idle)
        XCTAssertEqual(receivedStates[1], .loading)
    }
}
