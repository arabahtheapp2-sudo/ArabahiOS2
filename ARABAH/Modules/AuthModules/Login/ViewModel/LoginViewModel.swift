//
//  LoginViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import Foundation
import Combine

/// ViewModel responsible for handling login logic via phone number and country code.
final class LoginViewModel {
    

    // MARK: - Properties
    
    /// Published state observable by UI
    @Published private(set) var state: AppState<LoginModal> = .idle
    
    private var cancellables = Set<AnyCancellable>()              // To hold Combine subscriptions
    private let authServices: AuthServicesProtocol                // API service for login
    private var previousInput: (countryCode: String, phoneNumber: String)?  // Store last login attempt for retry

    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with an optional custom auth service
    init(authServices: AuthServicesProtocol = AuthServices()) {
        self.authServices = authServices
    }
    
    // MARK: - Public Methods
    
    /// Performs login using country code and phone number.
    func login(countryCode: String, phoneNumber: String)  {
        // Save input for retry
        self.previousInput = (countryCode, phoneNumber)
        self.retryCount = 0
        // Validate input before proceeding
        guard validateInputs(countryCode: countryCode, phoneNumber: phoneNumber) else {
            return
        }
        
        // Notify UI that loading has started
        state = .loading
        
        // Call API to login
        authServices.loginUser(countryCode: countryCode, phoneNumber: phoneNumber)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle error
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                // On success, store data and update state
                Store.shared.authToken = response.body?.authToken
                Store.userDetails = response
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retry login using the previously stored input
    func retryLogin() {
        
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        if let input = previousInput {
            state = .idle
            login(countryCode: input.countryCode, phoneNumber: input.phoneNumber)
        }
    }
    
    // MARK: - Validation
    
    /// Validates the login input values before making the API request.
    private func validateInputs(countryCode: String, phoneNumber: String) -> Bool {
        let countryCodeValidation = Validator.validateCountryCode(countryCode)
        let phoneValidation = Validator.validatePhoneNumber(phoneNumber)
        
        switch (countryCodeValidation, phoneValidation) {
        case (.failure(let error), _):
             state = .validationError(.validationError(error.localizedDescription))
            return false
        case (_, .failure(let error)):
             state = .validationError(.validationError(error.localizedDescription))
            return false
        case (.success, .success):
            return true
        }
    }
}


