//
//  LoginViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 04/06/25.
//

import XCTest
import Combine
@testable import ARABAH

final class LoginViewModelTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Test: Successful Login
    
    func testLoginSuccess() {
        let mockService = MockAuthService()
        let expectedToken = "123"
        
        mockService.loginUserPublisher = Just(LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil)
        )
        .setFailureType(to: NetworkError.self)
        .eraseToAnyPublisher()

        let viewModel = LoginViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Login success")

        viewModel.$state
            .dropFirst(2) // idle → loading → success
            .sink { state in
                if case .success(let response) = state {
                    XCTAssertEqual(response.body?.authToken, expectedToken)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "+1", phoneNumber: "12345678")
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Test: API Failure
    
    func testLoginFailure() {
        let mockService = MockAuthService()
        mockService.loginUserPublisher = Fail(error: NetworkError.badRequest(message: "Invalid phone"))
            .eraseToAnyPublisher()

        let viewModel = LoginViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Login fails")

        viewModel.$state
            .dropFirst(2) // idle → loading → failure
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, "Invalid phone")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "+1", phoneNumber: "12345678")
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Test: Validation Failure - Country Code
    
    func testLoginValidationFailure_InvalidCountryCode() {
        let viewModel = LoginViewModel(authServices: MockAuthService())
        let expectation = XCTestExpectation(description: "Validation fails - invalid country code")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertTrue(error.localizedDescription.contains("country"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "invalid", phoneNumber: "12345678")
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Test: Validation Failure - Phone Number
    
    func testLoginValidationFailure_InvalidPhone() {
        let viewModel = LoginViewModel(authServices: MockAuthService())
        let expectation = XCTestExpectation(description: "Validation fails - invalid phone number")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertTrue(error.localizedDescription.contains("phone"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "+1", phoneNumber: "")
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Test: Retry Login
    
    func testRetryLogin_ReusesLastInput() {
        let mockService = MockAuthService()
        var callCount = 0

        mockService.loginUserPublisher = Deferred {
            Future { promise in
                callCount += 1
                promise(.failure(NetworkError.serverError(message: "error")))
            }
        }
        .eraseToAnyPublisher()

        let viewModel = LoginViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry triggers second API call")

        viewModel.$state
            .dropFirst(4) // idle → loading → failure → idle → loading → failure
            .sink { state in
                if case .failure = state, callCount == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "+91", phoneNumber: "9876543210")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.retryLogin()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - Test: State Transitions

    func testStateTransitionsOnLogin() {
        let mockService = MockAuthService()
        mockService.loginUserPublisher = Just(LoginModal(success: true, code: 200, message: "OK", body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let viewModel = LoginViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "States transition correctly")
        var receivedStates: [AppState<LoginModal>] = []

        viewModel.$state
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login(countryCode: "+1", phoneNumber: "12345678")

        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(receivedStates.count, 3)
        XCTAssertEqual(receivedStates[0], .idle)
        XCTAssertEqual(receivedStates[1], .loading)
        if case .success = receivedStates[2] {
            // pass
        } else {
            XCTFail("Expected .success state")
        }
    }
}
