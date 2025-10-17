//
//  ProfileViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ProfileViewModelTests: XCTestCase {
     var cancellables = Set<AnyCancellable>()
    
    // MARK: - Get Profile Tests
    
    func testGetProfileSuccess() {
        let mockService = MockAuthService()
        
        
        mockService.getProfilePublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Get profile success")
        
        viewModel.$profileState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .getProfile
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGetProfileFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.unauthorized
        
        mockService.getProfilePublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Get profile failure")
        
        viewModel.$profileState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .getProfile
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Notification Update Tests
    
    func testUpdateNotificationSuccess() {
        let mockService = MockAuthService()
        let testStatus = 0
        
        mockService.updateNotiStatusPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Update notification success")
        
        // Set initial user details
        Store.userDetails = LoginModal(
            success: true,
            code: 200,
            message: "",
            body: nil
        )
        
        viewModel.$updateNotiState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    XCTAssertEqual(Store.userDetails?.body?.isNotification, testStatus)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: testStatus,
            actionType: .updateNotification(testStatus)
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateNotificationFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.badRequest(message: "Update failed")
        
        mockService.updateNotiStatusPublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Update notification failure")
        
        viewModel.$updateNotiState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: 1,
            actionType: .updateNotification(1)
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryUpdateNotification() {
        let mockService = MockAuthService()
        let testStatus = 1
        var callCount = 0
        
        mockService.updateNotiStatusPublisher = Deferred {
            Future<LoginModal, NetworkError> { promise in
                callCount += 1
                if callCount == 1 {
                    promise(.failure(.badRequest(message: "First failure")))
                } else {
                    promise(.success(LoginModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil
                    )))
                }
            }
        }.eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry update notification")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$updateNotiState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    viewModel.retryUpdateNotiStatus()
                    expectation.fulfill()
                } else if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: testStatus,
            actionType: .updateNotification(testStatus)
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Delete Account Tests
    
    func testDeleteAccountSuccess() {
        let mockService = MockAuthService()
        
        mockService.deleteAccountPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Delete account success")
        
        // Set initial auth token to verify it gets cleared
        Store.shared.authToken = "test_token"
        
        viewModel.$deleteAccState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    XCTAssertNil(Store.shared.authToken)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .deleteAccount
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryDeleteAccount() {
        let mockService = MockAuthService()
        var callCount = 0
        
        mockService.deleteAccountPublisher = Deferred {
            Future<LoginModal, NetworkError> { promise in
                callCount += 1
                if callCount == 1 {
                    promise(.failure(.badRequest(message: "First failure")))
                } else {
                    promise(.success(LoginModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil
                    )))
                }
            }
        }.eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry delete account")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$deleteAccState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    viewModel.retryDeleteAccount()
                    expectation.fulfill()
                } else if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .deleteAccount
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Logout Tests
    
    func testLogoutSuccess() {
        let mockService = MockAuthService()
        
        mockService.logoutPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )).setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()
        
        let viewModel = ProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Logout success")
        
        // Set initial values to verify they get cleared
        Store.shared.authToken = "test_token"
        Store.autoLogin = true
        
        viewModel.$logoutState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    XCTAssertNil(Store.shared.authToken)
                    XCTAssertFalse(Store.autoLogin)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: nil,
            actionType: .logout
        ))
        
        wait(for: [expectation], timeout: 1.0)
    }
}
