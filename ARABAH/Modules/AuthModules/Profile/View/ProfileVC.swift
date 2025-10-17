//
//  ProfileVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import SDWebImage
import Combine
import MBProgressHUD

class ProfileVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var btnComplete: UIButton?
    @IBOutlet weak var lblCountyPhone: UILabel?
    @IBOutlet weak var lblUser: UILabel?
    @IBOutlet weak var profileImg: UIImageView?
    @IBOutlet weak var tblVw: UITableView?
    
    // MARK: - Properties
     let viewModel = ProfileViewModel()
     var cancellables = Set<AnyCancellable>()
    
    // Section titles and icons for profile menu
     let sectionTitles = [
        PlaceHolderTitleRegex.priceNotifications,
        PlaceHolderTitleRegex.raiseTicket,
        PlaceHolderTitleRegex.favouriteProduct,
        PlaceHolderTitleRegex.changeLanguage,
        PlaceHolderTitleRegex.notes,
        PlaceHolderTitleRegex.termsandConditions,
        PlaceHolderTitleRegex.privacyPolicy,
        PlaceHolderTitleRegex.aboutUs,
        PlaceHolderTitleRegex.contactUs,
        PlaceHolderTitleRegex.faq,
        PlaceHolderTitleRegex.signOut,
        PlaceHolderTitleRegex.deleteAccount
    ]
    
     let sectionIcons = [
        "notification", "ticket", "heart", "Layer 2", "notes-2",
        "document", "Group 38144", "info", "contact-mail", "Qutions", "exit", "Image 59"
    ]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.authNil(val: true) // Auth utility logic (likely user presence)
        setupAccessibility()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUIWithUserData()
    }
    
    // Set accessibility identifiers for UI testing
    private func setupAccessibility() {
        btnComplete?.accessibilityIdentifier = "EditProfileButton"
        profileImg?.accessibilityIdentifier = "ProfileImage"
        lblUser?.accessibilityIdentifier = "userNameLabel"
        lblCountyPhone?.accessibilityIdentifier = "phoneNumberLabel"
        tblVw?.accessibilityIdentifier = "profileTableView"
    }
    
    // Bind ViewModel state changes to UI handling
    private func bindViewModel() {
        viewModel.$profileState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$updateNotiState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleNotiState(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$deleteAccState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleDeleteAccState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$logoutState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleLogoutState(state)
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Actions
    
    // Navigates to Edit Profile screen
    @IBAction func btnEditProfile(_ sender: UIButton) {
        navigateToEditProfile()
    }
    
    // MARK: - State Handling
    // Handle ViewModel state updates
    private func handleStateChange(_ state: AppState<LoginModalBody>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(let value):
            updateUI(with: value)
            hideLoadingIndicator()
        case .failure:
            hideLoadingIndicator()
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // Handle ViewModel state updates
    private func handleNotiState(_ state: AppState<LoginModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            showNotificationUpdateSuccess()
            DispatchQueue.main.async {
                self.tblVw?.reloadData()
            }
        case .failure(let error):
            hideLoadingIndicator()
            handleUpdateStatusError(error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // Handle ViewModel state updates
    private func handleDeleteAccState(_ state: AppState<LoginModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            navigateToLogin()
        case .failure(let error):
            hideLoadingIndicator()
            handleDeleteAccountError(error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // Handle ViewModel state updates
    private func handleLogoutState(_ state: AppState<LoginModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: RegexMessages.userLogout, isSuccess: .success)
            navigateToLogin()
        case .failure(let error):
            hideLoadingIndicator()
            handleLogoutError(error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // Send API request to update notification status
    func updateNotificationStatus(status: Int) {
        viewModel.performAction(input: ProfileViewModel.Input(
            notificationStatus: status,
            actionType: .updateNotification(status)
        ))
    }
    
    // Refresh UI from stored user data
    private func updateUIWithUserData() {
        guard let userData = Store.userDetails?.body else { return }
        updateUI(with: userData)
    }
    
    // Update profile UI elements from user data
    private func updateUI(with profile: LoginModalBody) {
        self.btnComplete?.isHidden = false
        let profileImageURL = (AppConstants.imageURL) + (profile.image ?? "")
        profileImg?.sd_imageIndicator = SDWebImageActivityIndicator.gray
        profileImg?.sd_setImage(with: URL(string: profileImageURL), placeholderImage: UIImage(named: "Placeholder"))
        lblUser?.text = profile.name ?? ""
        lblCountyPhone?.text = "\(profile.countryCode ?? "") \(profile.phone ?? "")"
        
        // Set button title based on profile completeness
        let buttonTitle = viewModel.shouldShowCompleteProfile() ?
            PlaceHolderTitleRegex.completeYourProfile :
            PlaceHolderTitleRegex.editProfile
        btnComplete?.setTitle(buttonTitle, for: .normal)
    }
    
    // MARK: - Navigation
    
    // Navigate to Edit Profile screen
    private func navigateToEditProfile() {
        guard let editProfileVC = storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC else { return }
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    // Navigate to Login screen after logout or delete
    private func navigateToLogin() {
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
        let nav = UINavigationController(rootViewController: loginVC)
        nav.isNavigationBarHidden = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
    
    // Generic navigation method
     func navigateTo(_ identifier: String, header: Int? = nil) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: identifier) else { return }
        if let termsVC = viewController as? TermsConditionVC, let header = header {
            termsVC.contentType = header
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Helpers
    
    // Show alert when notification status is updated
    private func showNotificationUpdateSuccess() {
        let message = Store.userDetails?.body?.isNotification == 1 ?
            RegexMessages.notificationOn :
            RegexMessages.notificationOff
        CommonUtilities.shared.showAlert(message: message, isSuccess: .success)
    }
    
    private func handleLogoutError(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryLogout()
        }
    }
    
    private func handleDeleteAccountError(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryDeleteAccount()
        }
    }
    
    private func handleUpdateStatusError(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryUpdateNotiStatus()
        }
    }
}
