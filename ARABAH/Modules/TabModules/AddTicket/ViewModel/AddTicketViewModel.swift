//
//  AddTicketViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling the business logic and API calls related to adding a ticket.
class AddTicketViewModel: NSObject {
    
    // MARK: - Input & Output

    /// Structure representing the input required to add a ticket.
    struct Input {
        let title: String
        let description: String
    }

    
    // MARK: - Properties

    /// Published property to notify the UI about state changes.
    @Published private(set) var state: AppState<ReportModal> = .idle

    /// Combine cancellables for managing memory.
    private var cancellables = Set<AnyCancellable>()

    /// Service that performs the API call.
    private let networkService: NotesServicesProtocol

    /// Stores the last attempted input for retrying in case of failure.
    private var retryInputs: (title: String, description: String)?
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization

    /// Initializes the ViewModel with a default or injected service.
    /// - Parameter networkService: Dependency-injected service conforming to `NotesServicesProtocol`.
    init(networkService: NotesServicesProtocol = NotesServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods

    /// Validates and submits the ticket using input from the UI.
    ///
    /// - Parameters:
    ///   - title: Optional raw title string.
    ///   - description: Optional raw description string.
    func submitTicket(title: String?, description: String?) {
        // Trim whitespaces and fallback to empty string if nil
        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedDescription = description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Validate before proceeding
        guard validateInputs(title: trimmedTitle, description: trimmedDescription) else {
            return
        }
        
        // Save for retry in case of failure
        self.retryInputs = (trimmedTitle, trimmedDescription)
        
        // Create input object and call API
        let input = Input(title: trimmedTitle, description: trimmedDescription)
        addTicketAPI(with: input)
    }

    /// Makes the API call using validated and trimmed input.
    ///
    /// - Parameter input: Validated input data for ticket submission.
    func addTicketAPI(with input: Input) {
        retryCount = 0
        state = .loading

        networkService.addTicketAPI(title: input.title, desc: input.description)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle error from API call
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: ReportModal) in
                // Show success alert and update state
                CommonUtilities.shared.showAlert(message: response.message ?? "", isSuccess: .success)
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the last failed ticket submission if input was previously saved.
    func retryLastSubmission() {
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        
        guard let retryInputs = self.retryInputs else { return }
        let input = Input(title: retryInputs.title, description: retryInputs.description)
        addTicketAPI(with: input)
    }
    
    // MARK: - Private Methods

    /// Validates the provided input fields before attempting API call.
    ///
    /// - Parameters:
    ///   - title: Trimmed title string.
    ///   - description: Trimmed description string.
    /// - Returns: A Boolean value indicating whether the inputs are valid.
    private func validateInputs(title: String, description: String) -> Bool {
        let validator = Validator.validateAddTicket(title, description)
        
        switch validator {
        case .success:
            return true
        case .failure(let error):
            state = .validationError(.badRequest(message: error.localizedDescription))
            return false
        }
    }
}
