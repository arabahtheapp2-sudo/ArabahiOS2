//
//  AddTicketVC.swift
//  ARABAH
//
//  Created by cqlpc on 08/11/24.
//

import UIKit
import IQTextView
import Combine
import MBProgressHUD

/// ViewController responsible for handling the Add Ticket screen functionality.
class AddTicketVC: UIViewController, UITextViewDelegate {
    
    // MARK: - OUTLETS
    
    /// Label for description section
    @IBOutlet weak var lblDescription: UILabel?
    
    /// Label for title section
    @IBOutlet weak var lblTittle: UILabel?
    
    /// Text field for entering ticket title
    @IBOutlet weak var txtFldTittle: UITextField?
    
    /// Text view for entering ticket description
    @IBOutlet weak var txtViewDes: IQTextView?
    
    /// Button to submit the ticket
    @IBOutlet weak var submitButton: UIButton?

    // MARK: - VARIABLES
    
    /// ViewModel instance for handling business logic
    var viewModel = AddTicketViewModel()
    
    /// Set to store Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        accessibilityIdentifier()
        bindViewModel()
    }
    
    // MARK: - SETUP
    
    /// Sets up accessibility identifiers for UI testing
    private func accessibilityIdentifier() {
        txtFldTittle?.accessibilityIdentifier = "txtFldTittle"
        txtViewDes?.accessibilityIdentifier = "txtViewDes"
        submitButton?.accessibilityIdentifier = "SubmitButton"
    }
    
    /// Configures the initial view setup
    private func setupView() {
        txtViewDes?.placeholder = PlaceHolderTitleRegex.writeHere
        
        // Handle text alignment based on language
        if Store.isArabicLang {
            txtViewDes?.textAlignment = .right
            txtFldTittle?.textAlignment = .right
        } else {
            txtViewDes?.textAlignment = .left
            txtFldTittle?.textAlignment = .left
        }
    }
    
    // MARK: - DATA BINDING
    
    /// Binds the ViewModel state to the ViewController
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }

    /// Handles state changes from the ViewModel
    private func handleStateChange(_ state: AppState<ReportModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            self.navigationController?.popViewController(animated: true)
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlert(error: error)
        case .validationError(let error):
            showErrorAlertBanner(error: error)
        }
    }

    
    // MARK: - ALERTS
    
    /// Shows error alert with retry option
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryLastSubmission()
        }
    }

    /// Shows error banner alert
    private func showErrorAlertBanner(error: NetworkError) {
        CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
    }
    
    // MARK: - ACTIONS
    
    /// Handles submit button tap event
    @IBAction func didTapSubmitBtn(_ sender: UIButton) {
        viewModel.submitTicket(title: txtFldTittle?.text, description: txtViewDes?.text)
    }
    
    /// Handles back button tap event
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
