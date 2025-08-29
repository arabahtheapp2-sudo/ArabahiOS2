//
//  NotificationViewModel.swift
//  ARABAH
//
//  ViewModel handling all notification-related business logic and data
//

import UIKit
import Combine

/// ViewModel responsible for handling notification-related API calls and data management.
final class NotificationViewModel {
    

    
    // MARK: - Properties
    
    // Published state that views can observe
    @Published private(set) var listState: AppState<GetNotificationModal> = .idle
    @Published private(set) var listDeleteState: AppState<NewCommonString> = .idle
    
    // Collection of notification cell models for the table view
    @Published private(set) var notificationCellModels: [NotificationCellModel] = []

    // Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Network service for API calls
    private let networkService: HomeServicesProtocol
    
    // Base URL for notification images
    private let imageBaseURL = AppConstants.imageURL
    
    // Language flag for localization
    private let isArabic = Store.isArabicLang
    private var retryCount = 0
    private var deleteRetryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with optional network service (defaults to HomeServices)
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Notification List Methods
    
    /// Fetches the list of notifications from the server
    func getNotificationList() {
        // Set loading state before making API call
        listState = .loading
        retryCount = 0
        networkService.getNotificationList()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API completion (failure case)
            if case .failure(let error) = completion {
                self?.listState = .failure(error)
            }
        } receiveValue: { [weak self] (response: GetNotificationModal) in
            // Handle successful API response
            guard let bodies = response.body else {
                self?.listState = .failure(.invalidResponse)
                return
            }
            
            // Convert API response to cell models
            self?.notificationCellModels = bodies.map {
                NotificationCellModel(
                    body: $0,
                    baseURL: self?.imageBaseURL ?? "",
                    isArabic: self?.isArabic ?? false
                )
            }
            
            // Update state to success
            self?.listState = .success(response)
        }
        .store(in: &cancellables)
    }
    
    /// Retry mechanism for failed notification list fetch
    func retryGetNotification() {
        guard retryCount < maxRetryCount else {
            listState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        listState = .idle
        self.getNotificationList()
    }
    
    // MARK: - Notification Deletion Methods
    
    /// Deletes all notifications via API
    func notificationDeleteAPI() {
        listDeleteState = .loading
        deleteRetryCount = 0
        networkService.notificationDeleteAPI()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle deletion failure
            if case .failure(let error) = completion {
                self?.listDeleteState = .failure(error)
            }
        } receiveValue: { [weak self] (response: NewCommonString) in
            // Handle successful deletion
            self?.listDeleteState = .success(response)
        }
        .store(in: &cancellables)
    }

    /// Retry mechanism for failed deletion
    func retryDeleteNotification() {
        
        guard retryCount < maxRetryCount else {
            listDeleteState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        listDeleteState = .idle
        self.notificationDeleteAPI()
    }
    
    // MARK: - Data Access Methods
    
    /// Returns whether the notification list is empty
    var isEmpty: Bool {
        return notificationCellModels.isEmpty
    }
    /// List  empty
    func clearList() {
        notificationCellModels.removeAll()
    }
    
    /// Returns the notification model at specified index
    func model(at index: Int) -> NotificationCellModel? {
        return notificationCellModels[safe: index]
    }

    /// Returns total count of notifications
    func count() -> Int {
        return notificationCellModels.count
    }

    /// Returns product ID for notification at specified index
    func productID(at index: Int) -> String {
        return notificationCellModels[safe: index]?.productID ?? ""
    }
}
