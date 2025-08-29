//
//  ChangeLanViewModel.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import Combine

class ChangeLanViewModel: NSObject {
    
    // MARK: - Properties
    
    @Published private(set) var state: AppState<LoginModal> = .idle        // Observable state property for view binding
    private var cancellables = Set<AnyCancellable>()        // Stores Combine subscriptions
    private let settingsServices: SettingsServicesProtocol  // Protocol for API service abstraction
     var retryParams: String?                        // Stores last language used for retry
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a service layer (dependency injection supported)
    init(settingsServices: SettingsServicesProtocol = SettingsServices()) {
        self.settingsServices = settingsServices
    }
    
    // MARK: - API Call
    
    /**
     Triggers the API call to change the user's preferred language.
     
     - Parameter languageType: Language code string (e.g., "en" or "ar")
     
     On success, the view can transition or reload accordingly.
     On failure, the error state is set and the language is stored for retry.
     */
    func changeLanguageAPI(with languageType: String) {
        state = .loading
        self.retryParams = languageType
        self.retryCount = 0
        settingsServices.changeLanguageAPI(with: languageType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Retry
    
    /**
     Retries the language change API call with previously stored parameters.
     
     Useful in case of a network failure or server error.
     */
    func retryChangeLanguageAPI() {
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        if let languageType = self.retryParams {
            state = .idle
            self.changeLanguageAPI(with: languageType)
        }
    }
    
    
    
    
    
}
