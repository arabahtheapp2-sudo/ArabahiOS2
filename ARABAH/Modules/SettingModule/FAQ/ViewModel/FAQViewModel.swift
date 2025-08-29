//
//  FAQViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for managing FAQ data and coordinating API calls
final class FAQViewModel {

    // MARK: - Properties
    
    /// Published state for UI to observe and react to
    @Published private(set) var state: AppState<FaqModal> = .idle
    
    /// List of FAQs received from API
    @Published private(set) var faqList: [FaqModalBody]? = []
    
    /// Set to manage Combine's memory and subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Abstraction of the settings service layer (used for testability)
    private let settingsServices: SettingsServicesProtocol
    
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with optional custom service (default: real implementation)
    init(settingsServices: SettingsServicesProtocol = SettingsServices()) {
        self.settingsServices = settingsServices
    }
    
    // MARK: - Public Methods
    
    /// Triggers the API call to fetch FAQ list
    /// Updates state for UI and assigns results to `faqList`
    func getFaqListAPI() {
        // Indicate loading started
        state = .loading
        retryCount = 0
        // Call the service to fetch FAQs
        settingsServices.getFaqListAPI()
            .receive(on: DispatchQueue.main) // Ensure updates occur on main thread
            .sink { [weak self] completion in
                // Handle error scenario
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: FaqModal) in
                // Validate and assign FAQ list
                guard let contentBody = response.body else {
                    self?.state = .failure(.invalidResponse)
                    return
                }
                self?.faqList = contentBody
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries fetching the FAQ list (used on failure alert retry)
    func retryGetFaqList() {
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        // Reset to idle before retry
        state = .idle
        self.getFaqListAPI()
    }
}
