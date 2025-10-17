//
//  AddReviewVC.swift
//  ARABAH
//
//  ViewController for submitting product reviews and ratings
//

import UIKit
import Cosmos  // For star rating control
import MBProgressHUD  // For loading indicator
import Combine  // For reactive programming

class AddReviewVC: UIViewController {
    
    // MARK: - OUTLETS
    
    // Star rating selector (1-5 stars)
    @IBOutlet weak var ratingView: CosmosView?
    
    // Text view for writing the review
    @IBOutlet weak var txtView: UITextView?
    
    // Container view for the text view (for styling)
    @IBOutlet weak var viewTxtView: UIView?
    
    // MARK: - VARIABLES
    
    // Handles review submission logic
    var viewModel = AddRatingViewModel()
    
    // Stores Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // The product ID we're reviewing
    var productID = String()
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up accessibility for testing
        setUpAccessibilityIdentifier()
        // Connect to ViewModel
        bindViewModel()
        
        // You might want to add text view styling here
        // viewTxtView.layer.borderWidth = 1
        // viewTxtView.layer.cornerRadius = 8
    }
    
    // MARK: - SETUP
    
    /// Sets accessibility identifiers for UI testing
    private func setUpAccessibilityIdentifier() {
        ratingView?.accessibilityIdentifier = "ratingView"
        txtView?.accessibilityIdentifier = "reviewTextView"
    }
    
    // MARK: - BINDING
    
    /// Connects to ViewModel's published properties
    private func bindViewModel() {
        // React to state changes from ViewModel
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - STATE HANDLING
    
    /// Handles different states from ViewModel
    private func handleStateChange(_ state: AppState<AddCommentModal>) {
        switch state {
        case .idle:
            // No special handling needed
            break
            
        case .loading:
            // Show spinner when submitting
            showLoadingIndicator()
            
        case .success:
            // Hide spinner and go back on success
            hideLoadingIndicator()
            self.navigationController?.popViewController(animated: true)
            
        case .failure(let error):
            // Hide spinner and show error
            hideLoadingIndicator()
            showErrorAlert(error: error)
        case .validationError(let error):
            showValidationAlert(error: error)
            hideLoadingIndicator()
        }
    }
    
    // MARK: - ALERT & LOADING
    
    /// Shows error alert with retry option
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(
            title: AppConstants.appName,
            message: error.localizedDescription
        ) { [weak self] _ in
            // Retry submission when user taps retry
            self?.viewModel.retry()
        }
    }
    /// Shows error alert for validation
    private func showValidationAlert(error: NetworkError) {
        CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
    }
    
    // MARK: - ACTIONS
    
    /// Handles back button tap
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Handles submit button tap
    @IBAction func btnSubmit(_ sender: UIButton) {
        // Send rating and review to ViewModel
        viewModel.submitReview(
            productId: productID,
            rating: ratingView?.rating ?? 0.0,
            reviewText: txtView?.text ?? ""
        )
    }
}
