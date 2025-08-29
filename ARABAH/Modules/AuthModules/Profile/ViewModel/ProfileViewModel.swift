//
//  ProfileViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling profile-related network interactions.
final class ProfileViewModel {
    
    // MARK: - Input & Output
    
    /// Struct used to pass action data into the ViewModel.
    struct Input {
        let notificationStatus: Int?
        let actionType: ActionType
    }
    
    /// Enum representing the types of actions this ViewModel can perform.
    enum ActionType {
        case getProfile
        case updateNotification(Int)
        case deleteAccount
        case logout
    }
    
    // MARK: - Properties
    
    /// Current state of the ViewModel; UI listens to this.
    @Published private(set) var profileState: AppState<LoginModalBody> = .idle
    @Published private(set) var updateNotiState: AppState<LoginModal> = .idle
    @Published private(set) var deleteAccState: AppState<LoginModal> = .idle
    @Published private(set) var logoutState: AppState<LoginModal> = .idle
    
    /// Stores Combine cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// API service to perform auth/profile-related calls.
    private let authServices: AuthServicesProtocol
    
    /// Temporary storage for notification status update.
    private var updateNotiParam: Int?
    private var deleteRetryCount = 0
    private var logoutRetryCount = 0
    private var notiStatusRetryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with the given auth service.
    init(authServices: AuthServicesProtocol = AuthServices()) {
        self.authServices = authServices
    }
    
    // MARK: - Public Methods
    
    /// Handles all supported actions (e.g. fetch profile, logout).
    /// - Parameter input: Defines what action to perform and with what data.
    func performAction(input: Input) {
        
        switch input.actionType {
        case .getProfile:
            profileState = .loading
            getProfile()
        case .updateNotification(let status):
            updateNotiState = .loading
            updateNotificationStatus(status: status)
        case .deleteAccount:
            deleteAccState = .loading
            deleteAccount()
        case .logout:
            logoutState = .loading
            logout()
        }
    }
    
    // MARK: - Private Methods
    
    /// Calls the getProfile API and updates state accordingly.
    private func getProfile() {
        authServices.getProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.profileState = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                Store.userDetails = response
                if let body = response.body {
                    self?.profileState = .success(body)
                }
            }
            .store(in: &cancellables)
    }
    
    /// Checks if the current profile is incomplete.
    /// - Returns: True if name, email, or image is missing.
    func shouldShowCompleteProfile() -> Bool {
        guard let userData = Store.userDetails?.body else { return true }
        return userData.image?.isEmpty ?? true ||
               userData.name?.isEmpty ?? true ||
               userData.email?.isEmpty ?? true
    }
    
    /// Updates the notification status through API.
    /// - Parameter status: Integer representing notification on/off.
    private func updateNotificationStatus(status: Int) {
        updateNotiParam = status
        notiStatusRetryCount = 0
        authServices.updateNotificationStatus(status: status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.updateNotiState = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                // Update local cache and UI
                Store.userDetails?.body?.isNotification = status
                self?.updateNotiState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the last failed notification status update.
    func retryUpdateNotiStatus() {
        guard notiStatusRetryCount < maxRetryCount else {
            updateNotiState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        notiStatusRetryCount += 1
        
        
        if let input = updateNotiParam {
            updateNotiState = .idle
            self.updateNotificationStatus(status: input)
        }
    }
    
    /// Deletes the user's account from the backend.
    private func deleteAccount() {
        deleteRetryCount = 0
        authServices.deleteAccount()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.deleteAccState = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                self?.clearUserSession()
                self?.deleteAccState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the last failed account deletion.
    func retryDeleteAccount() {
        guard deleteRetryCount < maxRetryCount else {
            deleteAccState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        deleteRetryCount += 1
        
        deleteAccState = .idle
        self.deleteAccount()
    }
    
    /// Logs the user out by calling the logout API.
    private func logout() {
        logoutRetryCount = 0
        authServices.logout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.logoutState = .failure(error)
                }
            } receiveValue: { [weak self] (response: LoginModal) in
                self?.clearUserSession()
                self?.logoutState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the logout API call.
    func retryLogout() {
        guard logoutRetryCount < maxRetryCount else {
            logoutState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        logoutRetryCount += 1
        
        logoutState = .idle
        self.logout()
    }
    
    /// Clears all user-related data from the session (used after logout or account delete).
    private func clearUserSession() {
        Store.shared.clearSession()
    }
    
}
