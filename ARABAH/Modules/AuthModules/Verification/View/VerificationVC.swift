//
//  VerificationVC.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit
import Combine
import MBProgressHUD

/// ViewController responsible for OTP input, validation, verification, and resend logic.
class VerificationVC: UIViewController {
    
    // MARK: - IBOutlets (UI elements)
    @IBOutlet weak var resendBtn: UIButton?
    @IBOutlet weak var verifyBtn: UIButton?
    @IBOutlet weak var labelOTP: UILabel?
    @IBOutlet var txtFldCollection: [OtpTextField]?
    @IBOutlet weak var lblNumber: UILabel?
    @IBOutlet weak var viewFour: UIView?
    @IBOutlet weak var viewThree: UIView?
    @IBOutlet weak var viewTwo: UIView?
    @IBOutlet weak var viewOne: UIView?
    
    // MARK: - Properties
    private var phoneNumberWithCode: String {
        return countryCode + number
    }
    
    var number = ""                 // Passed from previous screen
    var countryCode = ""           // Passed from previous screen
    
    private let viewModel = VerificationViewModel() // ViewModel instance
    private var cancellables = Set<AnyCancellable>() // Combine subscriptions
    
    private var timer: Timer?                      // OTP countdown timer
    private var remainingSeconds = 300             // Countdown in seconds (5 mins)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        setupAccessibility()
        startOTPTimer()
    }
    
    deinit {
        timer?.invalidate() // Invalidate timer on deallocation
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        // Style OTP input containers
        let borderViews = [viewOne, viewTwo, viewThree, viewFour]
        borderViews.forEach {
            $0?.layer.borderColor = UIColor.systemGray4.cgColor
            $0?.layer.borderWidth = 1
        }
        
        // Assign custom backspace delegate for OTP fields
        txtFldCollection?.forEach {
            $0.backspaceDelegate = self
        }
        
        resendBtn?.setLocalizedTitleButton(key: PlaceHolderTitleRegex.resend)
        lblNumber?.text = PlaceHolderTitleRegex.enter4DigitCode + "\(countryCode) \(number)"
    }
    
    // MARK: - Accessibility Identifiers (For UI testing)
    private func setupAccessibility() {
        resendBtn?.accessibilityIdentifier = "verification.resendButton"
        verifyBtn?.accessibilityIdentifier = "verification.verifyButton"
        labelOTP?.accessibilityIdentifier = "verification.timerLabel"
        lblNumber?.accessibilityIdentifier = "verification.phoneNumberLabel"
        
        txtFldCollection?.enumerated().forEach { index, textField in
            textField.accessibilityIdentifier = "verification.otpTextField\(index + 1)"
        }
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        viewModel.$resendState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleResendStateChange(state)
            }
            .store(in: &cancellables)
        
    }
    
    private func handleResendStateChange(_ state: AppState<LoginModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            handleResendSuccess()
            hideLoadingIndicator()
        case .failure(let error):
            handleResendFailure(error)
            hideLoadingIndicator()
        case .validationError(let error):
            showValidationErrorAlert(error)
            hideLoadingIndicator()
        }
    }
    
    // React to state changes from ViewModel
    private func handleStateChange(_ state: AppState<LoginModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            handleVerificationSuccess()
            hideLoadingIndicator()
        case .failure(let error):
            handleVerificationFailure(error)
            hideLoadingIndicator()
        case .validationError(let error):
            showValidationErrorAlert(error)
            hideLoadingIndicator()
        }
    }
    
    // MARK: - Actions
    @IBAction private func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func didTapVerify(_ sender: UIButton) {
        verifyOTP()
    }
    
    @IBAction private func didTapResend(_ sender: UIButton) {
        resendOTP()
    }
    
    // MARK: - API Call Triggers
    private func verifyOTP() {
        self.view.endEditing(true)
        let otp = (txtFldCollection?.map { $0.text ?? "" }.joined() ?? "")
        
        viewModel.verifyOTP(otp: otp, phoneNumberWithCode: phoneNumberWithCode)
    }
    
    private func resendOTP() {
        viewModel.resendOTP(phoneNumberWithCode: phoneNumberWithCode)
    }
    
    // MARK: - OTP Timer
    private func startOTPTimer() {
        remainingSeconds = 300 // Reset timer
        resendBtn?.isEnabled = false
        updateTimerLabel()
        
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            labelOTP?.text = ""
            resendBtn?.isEnabled = true
        }
    }
    
    private func updateTimerLabel() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        labelOTP?.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - UI/State Handling Helpers
    private func handleVerificationSuccess() {
        Store.autoLogin = true
        navigateToMainScreen()
    }
    
    private func handleResendSuccess() {
        // Reset input fields on successful resend
        txtFldCollection?.forEach { $0.text = "" }
        txtFldCollection?.first?.becomeFirstResponder()
        startOTPTimer()
    }
    
    private func handleVerificationFailure(_ error: NetworkError) {
        if error.shouldClearOTPFields {
            // Clear fields on specific failure messages
            txtFldCollection?.forEach { $0.text = "" }
            txtFldCollection?.first?.becomeFirstResponder()
        } else {
            // Show retry alert
            CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
                self?.viewModel.retryVerifyOTP()
            }
        }
    }
    
    private func showValidationErrorAlert(_ error: NetworkError) {
        CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
    }
    
    private func handleResendFailure(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryResendOTP()
        }
    }
    
    // MARK: - Navigation
    private func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else { return }
        
        let nav = UINavigationController(rootViewController: tabBarController)
        nav.isNavigationBarHidden = true
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
}

// MARK: - OTP TextField Behavior
extension VerificationVC: UITextFieldDelegate, BackspaceTextFieldDelegate {
    
    /// Handles character input and OTP field focus navigation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.count > 1 { return false } // Prevent paste
        
        if string.isEmpty {
            // Handle backspace
            textField.text = ""
            if let otpTextField = textField as? OtpTextField, let index = txtFldCollection?.firstIndex(of: otpTextField), index > 0 {
                txtFldCollection?[index - 1].becomeFirstResponder()
            }
            return false
        } else {
            // Handle digit input and move forward
            textField.text = string
            if let otpTextField = textField as? OtpTextField, let index = txtFldCollection?.firstIndex(of: otpTextField), index < (txtFldCollection?.count ?? 0) - 1 {
                txtFldCollection?[index + 1].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            return false
        }
    }
    
    /// Handles backspace tap in custom OTP field
    func textFieldDidDelete(_ textField: OtpTextField) {
        if let index = txtFldCollection?.firstIndex(of: textField), index > 0 {
            txtFldCollection?[index - 1].becomeFirstResponder()
        }
    }
}
