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
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var lblCountyPhone: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var tblVw: UITableView!
    
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // Section titles and icons for profile menu
    private let sectionTitles = [
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
    
    private let sectionIcons = [
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
        btnComplete.accessibilityIdentifier = "EditProfileButton"
        profileImg.accessibilityIdentifier = "ProfileImage"
        lblUser.accessibilityIdentifier = "userNameLabel"
        lblCountyPhone.accessibilityIdentifier = "phoneNumberLabel"
        tblVw.accessibilityIdentifier = "profileTableView"
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
    @IBAction func BtnEditProfile(_ sender: UIButton) {
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
        case .failure(_):
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
        case .success(_):
            hideLoadingIndicator()
            showNotificationUpdateSuccess()
            tblVw.reloadData()
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
        case .success(_):
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
        case .success(_):
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
    private func updateNotificationStatus(status: Int) {
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
        self.btnComplete.isHidden = false
        let profileImageURL = (AppConstants.imageURL) + (profile.image ?? "")
        profileImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        profileImg.sd_setImage(with: URL(string: profileImageURL), placeholderImage: UIImage(named: "Placeholder"))
        lblUser.text = profile.name ?? ""
        lblCountyPhone.text = "\(profile.countryCode ?? "") \(profile.phone ?? "")"
        
        // Set button title based on profile completeness
        let buttonTitle = viewModel.shouldShowCompleteProfile() ?
            PlaceHolderTitleRegex.completeYourProfile :
            PlaceHolderTitleRegex.editProfile
        btnComplete.setTitle(buttonTitle, for: .normal)
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
        let navController = MainNavigationController(rootViewController: loginVC)
        navController.isNavigationBarHidden = true
        UIApplication.shared.keyWindow?.rootViewController = navController
    }
    
    // Generic navigation method
    private func navigateTo(_ identifier: String, header: Int? = nil) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: identifier) else { return }
        if let termsVC = vc as? TermsConditionVC, let header = header {
            termsVC.contentType = header
        }
        navigationController?.pushViewController(vc, animated: true)
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

// MARK: - TableView Extension
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitles.count
    }
    
    // Cell setup
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVC", for: indexPath) as? ProfileTVC else {
            return UITableViewCell()
        }
        configureCell(cell, at: indexPath)
        return cell
    }
    
    // Configure each cell based on row
    private func configureCell(_ cell: ProfileTVC, at indexPath: IndexPath) {
        cell.lblHeading.text = NSLocalizedString(sectionTitles[indexPath.row], comment: "")
        cell.imgView.image = UIImage(named: sectionIcons[indexPath.row])
        
        switch indexPath.row {
        case 0: // Notification
            cell.btnOnOff.isHidden = false
            configureNotificationCell(cell)
        case 2, 9: // Favorites or FAQ
            cell.btnOnOff.isHidden = true
            cell.viewBottom.isHidden = false
        case 10, 11: // Logout or Delete
            cell.btnOnOff.isHidden = true
            configureActionCell(cell, at: indexPath)
        default:
            cell.btnOnOff.isHidden = true
            configureDefaultCell(cell)
        }
        
        let nextImageName = Store.isArabicLang ? "ic_next_screen 1" : "ic_next_screen"
        cell.btnNext.setImage(UIImage(named: nextImageName), for: .normal)
    }
    
    private func configureNotificationCell(_ cell: ProfileTVC) {
        cell.btnNext.isHidden = true
        cell.viewBottom.isHidden = true
        
        cell.btnOnOff.isSelected = Store.userDetails?.body?.isNotification == 1
        cell.lblHeading.textColor = .black
        cell.btnOnOff.accessibilityIdentifier = "notificationToggle"
        cell.btnOnOff.addTarget(self, action: #selector(notificationToggleTapped(_:)), for: .touchUpInside)
    }
    
    private func configureActionCell(_ cell: ProfileTVC, at indexPath: IndexPath) {
        cell.btnNext.isHidden = true
        cell.viewBottom.isHidden = true
        cell.lblHeading.textColor = indexPath.row == 11 ? #colorLiteral(red: 0.788, green: 0.204, blue: 0.204, alpha: 1) : .black
    }
    
    private func configureDefaultCell(_ cell: ProfileTVC) {
        cell.lblHeading.textColor = .black
        cell.btnNext.isHidden = false
        cell.btnOnOff.isHidden = true
        cell.viewBottom.isHidden = true
    }
    
    // Handle row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleRowSelection(at: indexPath)
    }
    
    // Notification toggle button tapped
    @objc private func notificationToggleTapped(_ sender: UIButton) {
        let newStatus = Store.userDetails?.body?.isNotification == 1 ? 0 : 1
        updateNotificationStatus(status: newStatus)
    }
    
    // Navigate based on selected row
    private func handleRowSelection(at indexPath: IndexPath) {
        switch indexPath.row {
        case 1: navigateTo("RaiseTicketVC")
        case 2: navigateTo("FavProductVC")
        case 3: navigateTo("ChangeLangVC")
        case 4: navigateTo("NotesListingVC")
        case 5: navigateTo("TermsConditionVC", header: 3)
        case 6: navigateTo("TermsConditionVC", header: 2)
        case 7: navigateTo("TermsConditionVC", header: 1)
        case 8: navigateTo("ContactUsVC")
        case 9: navigateTo("FaqVC")
        case 10: showConfirmationPopup(type: .logout)
        case 11: showConfirmationPopup(type: .deleteAccount)
        default: break
        }
    }
    
    // Show logout/delete confirmation popup
    private func showConfirmationPopup(type: ConfirmationType) {
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "popUpVC") as? popUpVC else { return }
        popupVC.check = type
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.confirmationHandler = { [weak self] confirmed in
            guard confirmed else { return }
            self?.handleConfirmedAction(for: type)
        }
        present(popupVC, animated: false)
    }
    
    // Handle confirmed popup action
    private func handleConfirmedAction(for type: ConfirmationType) {
        switch type {
        case .logout:
            viewModel.performAction(input: ProfileViewModel.Input(notificationStatus: nil, actionType: .logout))
        case .deleteAccount:
            viewModel.performAction(input: ProfileViewModel.Input(notificationStatus: nil, actionType: .deleteAccount))
        default: break
        }
    }
}
