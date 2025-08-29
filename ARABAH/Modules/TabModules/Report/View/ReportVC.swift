//
//  ReportVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit
import IQTextView
import MBProgressHUD
import Combine

/// ViewController to allow users to submit a report regarding a specific product.
class ReportVC: UIViewController {
    
    // MARK: - OUTLETS
    
    /// TextView for user to enter their report message
    @IBOutlet weak var txtView: IQTextView!
    
    /// Main container view with rounded corners
    @IBOutlet var viewMain: UIView!
    
    /// Button to dismiss the report view
    @IBOutlet weak var btnCross: UIButton!
    
    /// Button to submit the report
    @IBOutlet weak var BtnSubmit: UIButton!

    // MARK: - VARIABLES
    
    /// ViewModel handling report submission logic
    var viewModel = ReportViewModel()
    
    /// ID of the product being reported
    var productID = String()
    
    /// Set to store Combine cancellables
    private var cancellables = Set<AnyCancellable>()

    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up accessibility identifiers for UI testing
        setupAccessibilityIdentifier()
        // Configure initial view appearance
        setupView()
        // Bind to ViewModel state changes
        bindViewModel()
    }
    
    // MARK: - Binding
    
    /// Sets up binding to observe ViewModel state changes
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Handles different states from ViewModel and updates UI accordingly
    private func handleStateChange(_ state: AppState<ReportModal>) {
        switch state {
        case .idle:
            // No action needed in idle state
            break
        case .loading:
            // Show loading indicator during API call
            showLoadingIndicator()
        case .success:
            // Handle successful report submission
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: RegexMessages.reportSuccess, isSuccess: .success)
            self.dismiss(animated: true)
        case .failure(let error):
            // Handle API failure with retry option
            hideLoadingIndicator()
            CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
                self?.submitReport(isRetry: true)
            }
        case .validationError(let error):
            // Handle validation errors
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }

    /// Sets up accessibility identifiers for UI testing
    private func setupAccessibilityIdentifier() {
        txtView.accessibilityIdentifier = "txtView"
        viewMain.accessibilityIdentifier = "viewMain"
        btnCross.accessibilityIdentifier = "btnCross"
        BtnSubmit.accessibilityIdentifier = "BtnSubmit"
    }

    /// Configures initial view appearance
    private func setupView() {
        // Set placeholder text for the text view
        txtView.placeholder = PlaceHolderTitleRegex.writeHere
        // Configure rounded corners for the main view (top corners only)
        viewMain.layer.cornerRadius = 26
        viewMain.layer.masksToBounds = true
        viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    // MARK: - Report Submission
    
    /// Handles report submission process
    private func submitReport(isRetry: Bool) {
        // Check for authentication token before proceeding
        guard let token = Store.shared.authToken, !token.isEmpty else {
            self.authNil()
            return
        }

        // Create input model for ViewModel
        let input = ReportViewModel.Input(
            productID: self.productID,
            message: self.txtView.text
        )
        // Trigger report API call through ViewModel
        viewModel.reportAPI(with: input, isRetry: isRetry)
    }

    // MARK: - ACTIONS
    
    /// Handles cross button tap to dismiss the view
    @IBAction func btnCross(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    /// Handles submit button tap to initiate report submission
    @IBAction func BtnSubmit(_ sender: UIButton) {
        submitReport(isRetry: false)
    }
}
