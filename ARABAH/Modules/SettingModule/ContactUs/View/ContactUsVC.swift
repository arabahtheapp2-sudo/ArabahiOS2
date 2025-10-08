//
//  ContactUsVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import IQTextView
import Combine
import MBProgressHUD

class ContactUsVC: UIViewController, UITextViewDelegate {
    
    // MARK: - OUTLETS
    
    /// Label for "Message" field
    @IBOutlet weak var lblMessage: UILabel!
    
    /// Label for "Email" field
    @IBOutlet weak var lblEmail: UILabel!
    
    /// Label for "Name" field
    @IBOutlet weak var lblName: UILabel!
    
    /// Text view for entering the message
    @IBOutlet var txtView: IQTextView!
    
    /// Text field for entering email
    @IBOutlet var txtFldEmail: UITextField!
    
    /// View container for message input
    @IBOutlet var viewMsg: UIView!
    
    /// Text field for entering name
    @IBOutlet var txt: UITextField!
    
    // MARK: - VARIABLES
    
    /// ViewModel for managing Contact Us API interactions
    var viewModel = ContactUsViewModel()
    
    /// Set of Combine cancellables for subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VIEW LIFECYCLE
    
    /// Called after the controller’s view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAccessibility()
        bindViewModel()
    }
    
    // MARK: - UI SETUP
    
    /// Initializes UI labels, placeholders, and text alignment based on selected language
    private func setupViews() {
        lblName.setLocalizedTitle(key: PlaceHolderTitleRegex.name)
        txtView.placeholder = PlaceHolderTitleRegex.writeHere
        lblEmail.text = PlaceHolderTitleRegex.email
        lblMessage.text = PlaceHolderTitleRegex.message
        
        // Adjust alignment for RTL languages
        if Store.isArabicLang {
            txtFldEmail.textAlignment = .right
            txt.textAlignment = .right
            txtView.textAlignment = .right
        } else {
            txtFldEmail.textAlignment = .left
            txt.textAlignment = .left
            txtView.textAlignment = .left
        }
    }
    
    /// Assigns accessibility identifiers for UI testing
    private func setupAccessibility() {
        txt.accessibilityIdentifier = "txtName"
        txtFldEmail.accessibilityIdentifier = "txtEmail"
        txtView.accessibilityIdentifier = "txtMessage"
    }
    
    // MARK: - DATA BINDING
    
    /// Subscribes to ViewModel state changes and updates UI accordingly
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Handles ViewModel state updates and reflects UI changes
    private func handleStateChange(_ state: AppState<ContactUsModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(let response):
            showLoadingIndicator()
            handleSuccess(model: response)
        case .failure(let error):
            showLoadingIndicator()
            showErrorAlert(error: error)
        case .validationError(let error):
            showValidationAlert(error: error)
            showLoadingIndicator()
        }
    }
    
    /// Displays success alert and navigates back
    private func handleSuccess(model: ContactUsModal) {
        CommonUtilities.shared.showAlert(message: model.message ?? "", isSuccess: .success)
        self.navigationController?.popViewController(animated: true)
    }
        
    /// Shows error alert and allows retry
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryContactUs()
        }
    }
    
    /// Shows error alert for validation
    private func showValidationAlert(error: NetworkError) {
        CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
    }
    
    /// Triggers Contact Us API call using the entered values
    func contactUsAPI() {
        let name = txt.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = txtFldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let message = txtView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        viewModel.contactUsAPI(name: name, email: email, message: message)
    }
    
    // MARK: - ACTIONS
    
    /// Handles back button tap - navigates to previous screen
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Handles update button tap - initiates Contact Us API request
    @IBAction func btnUpdate(_ sender: UIButton) {
        self.contactUsAPI()
    }
}
