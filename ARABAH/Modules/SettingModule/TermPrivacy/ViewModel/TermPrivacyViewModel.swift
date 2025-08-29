//
//  TermPrivacyViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling Terms, Privacy Policy, and About Us content API flow
final class TermPrivacyViewModel {
    
    // MARK: - Input & Output
    
    /// Input struct for potential future extensibility
    struct Input {
        let type: Int
    }
    
    /// Enum representing the current state of the view
    enum State {
        case idle                                 // Initial/default state
        case loading                              // Data is being fetched
        case success(TermsPrivacyModelBody)       // Data fetched successfully with content
        case failure(NetworkError)                // Error occurred during fetch
    }
    
    // MARK: - Properties
    
    /// Publishes state changes to observers (usually the ViewController)
    @Published private(set) var state: AppState<TermsPrivacyModelBody> = .idle
    
    /// Set to manage Combine subscriptions and cancel on deinit
    private var cancellables = Set<AnyCancellable>()
    
    /// API service dependency injected via protocol for flexibility and testability
    private let settingsService: SettingsServicesProtocol
    
    /// Stores the last attempted type so that retry can work with same parameters
    var retryParams: Int?
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a service instance (defaults to live implementation)
    init(settingsService: SettingsServicesProtocol = SettingsServices()) {
        self.settingsService = settingsService
    }
    
    // MARK: - Public Methods
    
    /**
     Triggers API call to fetch static content based on the type.
     
     - Parameter type: Integer value representing the content type (e.g. 0 = Terms, 1 = About Us, 2 = Privacy Policy)
     */
    func fetchContent(with type: Int) {
        state = .loading                  // Notify UI to show loading state
        retryParams = type               // Save the param in case a retry is needed
        retryCount = 0
        // Call the API
        settingsService.fetchContent(with: type)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle failure case
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: TermsPrivacyModel) in
                // Parse and validate the response
                guard let contentBody = response.body else {
                    self?.state = .failure(.invalidResponse)
                    return
                }
                // Notify success with the parsed content
                self?.state = .success(contentBody)
            }
            .store(in: &cancellables)  // Hold the subscription
    }
    
    /**
     Retries the last failed API call using stored parameters.
     */
    func retryFetchContent() {
        
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        if let type = self.retryParams {
            state = .idle
            self.fetchContent(with: type)
        }
    }
}
