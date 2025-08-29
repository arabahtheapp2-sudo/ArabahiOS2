//
//  VerificationViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class VerificationViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Combine Binding & State Transition Tests
    
    func testVerifyOTPStateTransitionToSuccess() {
        let mockService = MockAuthService()
        let expected = LoginModal(success: true, code: 200, message: "OK", body: nil)
        mockService.verifyOTPPublisher = Just(expected)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        var states: [AppState<LoginModal>] = []
        let exp = expectation(description: "State transition to success")
        exp.expectedFulfillmentCount = 3
        
        viewModel.$state
            .sink { state in
                states.append(state)
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.verifyOTP(otp: "1234", phoneNumberWithCode: "+911234567890")
        wait(for: [exp], timeout: 2.0)
        
        XCTAssertEqual(states.count, 3)
        XCTAssertEqual(states[0], .idle)
        XCTAssertEqual(states[1], .loading)
        if case .success(let modal) = states[2] {
            XCTAssertEqual(modal.code, 200)
        } else {
            XCTFail("Expected success state")
        }
    }
    
    func testVerifyOTPValidationErrorState() {
        let mockService = MockAuthService()
        let viewModel = VerificationViewModel(authServices: mockService)
        let exp = expectation(description: "Validation error published")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, RegexMessages.enterAllOTP)
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.verifyOTP(otp: "", phoneNumberWithCode: "+911234567890")
        wait(for: [exp], timeout: 1.0)
    }
    
    func testCombineBindingResendStateToSuccess() {
        let mockService = MockAuthService()
        mockService.resendOTPPublisher = Just(LoginModal(success: true, code: 200, message: "OTP sent", body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        let exp = expectation(description: "Resend state updated to success")
        
        viewModel.$resendState
            .dropFirst()
            .sink { state in
                if case .success(let modal) = state {
                    XCTAssertEqual(modal.message, "OTP sent")
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.resendOTP(phoneNumberWithCode: "+911234567890")
        wait(for: [exp], timeout: 1.0)
    }
    
    func testVerifyOTPStateTransitionToFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.badRequest(message: "Invalid OTP")
        mockService.verifyOTPPublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = VerificationViewModel(authServices: mockService)
        var stateTransitions: [AppState<LoginModal>] = []
        let exp = expectation(description: "Failure state observed")
        exp.expectedFulfillmentCount = 3
        
        viewModel.$state
            .sink { state in
                stateTransitions.append(state)
                exp.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.verifyOTP(otp: "9999", phoneNumberWithCode: "+911234567890")
        wait(for: [exp], timeout: 2.0)
        
        XCTAssertEqual(stateTransitions.count, 3)
        XCTAssertEqual(stateTransitions[0], .idle)
        XCTAssertEqual(stateTransitions[1], .loading)
        if case .failure(let err) = stateTransitions[2] {
            XCTAssertEqual(err.localizedDescription, expectedError.localizedDescription)
        } else {
            XCTFail("Expected .failure state")
        }
    }
}
