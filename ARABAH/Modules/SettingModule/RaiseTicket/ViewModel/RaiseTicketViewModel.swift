//
//  RaiseTicketViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for managing support ticket fetching logic
final class RaiseTicketViewModel {
    
    // MARK: - Properties
    
    /// Published property to notify observers about state changes
    @Published private(set) var state: AppState<getTicketModal> = .idle
    
    /// Holds the list of support tickets fetched from the server
    @Published private(set) var ticketBody: [getTicketModalBody]? = []
    
    /// Combine cancellables to manage subscription lifecycle
    private var cancellables = Set<AnyCancellable>()
    
    /// Dependency to perform API requests (injected or default)
    private let settingsServices: SettingsServicesProtocol
    
    private var retryCount = 0
    private let maxRetryCount = 3
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with an optional custom service implementation
    init(settingsServices: SettingsServicesProtocol = SettingsServices()) {
        self.settingsServices = settingsServices
    }
    
    // MARK: - Public Methods
    
    /// Calls the API to retrieve the list of support tickets
    func getTicketAPI() {
        // Move to loading state to trigger UI feedback
        state = .loading
        retryCount = 0
        // Request tickets via service
        settingsServices.getTicketAPI()
            .receive(on: DispatchQueue.main) // UI updates on main thread
            .sink { [weak self] completion in
                // Handle network or parsing error
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: getTicketModal) in
                // Safely unwrap ticket list from response body
                guard let contentBody = response.body else {
                    self?.state = .failure(.invalidResponse)
                    return
                }
                
                // Store the ticket list and mark success
                self?.ticketBody = contentBody
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries fetching tickets in case of failure
    func retryGetTicket() {
        
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        // Reset state to idle before retrying
        state = .idle
        self.getTicketAPI()
    }
}
