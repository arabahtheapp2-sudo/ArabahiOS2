//
//  LoginVC.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit
import CountryPickerView
import Combine
import MBProgressHUD

/// Handles user login using phone number along with country code selection.
final class LoginVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var txtPhoneNumber: UITextField?
    @IBOutlet private weak var viewMain: UIView?
    @IBOutlet private weak var countryFlagImageView: UIImageView?
    @IBOutlet private weak var countryCodeLabel: UILabel?
    @IBOutlet private weak var signInButton: UIButton?
    @IBOutlet private weak var guestButton: UIButton?
    
    // MARK: - Properties
    private let countryPicker = CountryPickerView()                // Picker for country and phone code
    private var cancellables = Set<AnyCancellable>()              // For Combine subscriptions
    private var viewModel = LoginViewModel()                      // ViewModel for login logic
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCountryPicker()
        bindViewModel()
        setupAccessibility()
    }
    
    // MARK: - UI Configuration
    private func setupViews() {
        // Style phone number input container
        viewMain?.layer.borderWidth = 1
        viewMain?.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Set keyboard and alignment
        txtPhoneNumber?.keyboardType = .numberPad
        txtPhoneNumber?.textAlignment = Store.isArabicLang ? .right : .left
        
        // Round the buttons
        signInButton?.layer.cornerRadius = 8
        guestButton?.layer.cornerRadius = 8
        
        DeviceTokenManager.clearDeviceToken()
    }
    
    private func setupCountryPicker() {
        // Assign delegate and show default country
        countryPicker.delegate = self
        let currentCountry = countryPicker.getCountryByCode(Locale.current.regionCode ?? "US")
        updateCountryInfo(country: currentCountry)
    }
    
    // MARK: - Accessibility Identifiers (for UI testing)
    private func setupAccessibility() {
        txtPhoneNumber?.accessibilityIdentifier = "login.phoneNumberTextField"
        countryCodeLabel?.accessibilityIdentifier = "login.countryCodeLabel"
        countryFlagImageView?.accessibilityIdentifier = "login.countryFlagImage"
        signInButton?.accessibilityIdentifier = "login.signInButton"
        guestButton?.accessibilityIdentifier = "login.guestButton"
    }
    
    // MARK: - Combine ViewModel Binding
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
    }
    
    // React to ViewModel state changes
    private func handleStateChange(_ state: AppState<LoginModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(let response):
            hideLoadingIndicator()
            handleLoginSuccess(response: response)
        case .failure(let error):
            showErrorAlert(error: error)
            hideLoadingIndicator()
        case .validationError(let error):
            hideLoadingIndicator()
            showValidationErrorAlert(error: error)
        }
    }
    
    // Navigate to OTP Verification screen after successful login API response
    private func handleLoginSuccess(response: LoginModal) {
        guard let verificationVC = storyboard?.instantiateViewController(withIdentifier: "VerificationVC") as? VerificationVC else { return }
        let countryCode = countryCodeLabel?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let phoneNumber = txtPhoneNumber?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        verificationVC.countryCode =  countryCode
        // response.body?.countryCode ?? ""
        verificationVC.number = phoneNumber
        // response.body?.phone ?? ""
        self.navigationController?.pushViewController(verificationVC, animated: true)
    }
    
    // Triggers login API with entered country code and phone number
    private func apiRequest() {
        let countryCode = countryCodeLabel?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let phoneNumber = txtPhoneNumber?.text?.trimmingCharacters(in: .whitespaces) ?? ""
        viewModel.login(countryCode: countryCode, phoneNumber: phoneNumber)
    }
    
    // MARK: - Button Actions
    @IBAction private func didTapSignIn(_ sender: UIButton) {
        self.apiRequest()
    }
    
    @IBAction private func didTapGuest(_ sender: UIButton) {
        // Allow guest access by navigating to TabBarController
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else { return }
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    @IBAction private func didTapCountryButton(_ sender: UIButton) {
        // Show country list modal
        countryPicker.showCountriesList(from: self)
    }
    
    // MARK: - Helper Methods
    
    /// Updates UI with selected country's phone code and flag
    private func updateCountryInfo(country: Country?) {
        guard let country = country else { return }
        countryCodeLabel?.text = country.phoneCode
        countryFlagImageView?.image = country.flag
    }
    
    
    /// Shows error alert with retry option on login failure
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryLogin()
        }
    }
    
    /// Shows error alert on validation failure
    private func showValidationErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
    }
}

// MARK: - CountryPickerViewDelegate
extension LoginVC: CountryPickerViewDelegate {
    /// Update country info on selection from country list
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        updateCountryInfo(country: country)
    }
}

// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    /// Limit phone number field to max 12 digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 12
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }
}
