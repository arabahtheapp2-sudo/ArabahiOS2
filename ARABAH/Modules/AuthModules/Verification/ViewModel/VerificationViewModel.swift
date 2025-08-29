//
//  VerificationViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling OTP verification and resend logic.
final class VerificationViewModel {
    
    // MARK: - Properties
    
    /// Publisher for exposing current state changes to the View
    @Published private(set) var state: AppState<LoginModal> = .idle
    @Published private(set) var resendState: AppState<LoginModal> = .idle
    
    /// Holds Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// API layer dependency
    private let authServices: AuthServicesProtocol
    
    /// Stores latest OTP verification input for retry
    var previousInput: (otp: String, phoneNnumberWithCode: String)?
    
    /// Stores last resend attempt phone number for retry
    var previousResendInput: String?
    private var resendRetryCount = 0
    private var verifyRetryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Dependency Injection with default fallback
    init(authServices: AuthServicesProtocol = AuthServices()) {
        self.authServices = authServices
    }
    
    // MARK: - Public Methods
    
    /// Initiates OTP verification process
    func verifyOTP(otp: String, phoneNumberWithCode: String) {
        // Cache the input for potential retry
        self.previousInput = (otp, phoneNumberWithCode)
        self.verifyRetryCount = 0
        // Input validation
        guard validateInputs(otp: otp) else {
            state = .failure(.badRequest(message: RegexMessages.enterAllOTP))
            return
        }
        
        state = .loading
        
        // Call verification API
        authServices.verifyOTP(otp: otp, phoneNumberWithCode: phoneNumberWithCode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle API error response
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                // Store user session on success
                Store.shared.authToken = response.body?.token
                Store.userDetails = response
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retry last failed OTP verification attempt
    func retryVerifyOTP() {
        
        guard verifyRetryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        self.verifyRetryCount += 1
        
        if let input = previousInput {
            state = .idle
            self.verifyOTP(otp: input.otp, phoneNumberWithCode: input.phoneNnumberWithCode)
        }
    }
    
    /// Request OTP to be resent
    func resendOTP(phoneNumberWithCode: String) {
        state = .loading
        previousResendInput = phoneNumberWithCode
        self.resendRetryCount = 0
        // Call resend API
        authServices.resendOTP(phoneNumberWithCode: phoneNumberWithCode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle resend failure
                if case .failure(let error) = completion {
                    self?.resendState = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                // On success, update state
                self?.resendState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retry last failed resend attempt
    func retryResendOTP() {
        guard resendRetryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        self.resendRetryCount += 1
        
        if let input = previousResendInput {
            state = .idle
            self.resendOTP(phoneNumberWithCode: input)
        }
    }
    
    // MARK: - Validation
    
    /// Basic validation for OTP input
    private func validateInputs(otp: String) -> Bool {
        let otpValidation = Validator.validateOTP(otp)
        switch otpValidation {
        case .success:
            return true
        case .failure(let error):
            state = .validationError(.validationError(error.localizedDescription))
            return false
        }
    }
}

// MARK: - NetworkError Extension

extension NetworkError {
    
    /// Determines whether OTP fields should be cleared based on error message
    var shouldClearOTPFields: Bool {
        switch self {
        case .badRequest(let message):
            return message == PlaceHolderTitleRegex.PleaseEnterValidOTP ||
                   message == PlaceHolderTitleRegex.PleaseEnterValidOTPAR ||
                   message == PlaceHolderTitleRegex.apiFailTryAgain
        default:
            return false
        }
    }
}
