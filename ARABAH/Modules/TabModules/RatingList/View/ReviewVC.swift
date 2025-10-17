//
//  ReviewVC.swift
//  VenteUser
//
//  ViewController for displaying product reviews and ratings
//

import UIKit
import SDWebImage
import MBProgressHUD
import Combine

class ReviewVC: UIViewController {
    
    // MARK: - Outlets
    
    // Displays the average rating
    @IBOutlet weak var lblAvgRating: UILabel?
    
    // Shows total review count
    @IBOutlet weak var lblTotalCountReview: UILabel?
    
    // Table view to display individual reviews
    @IBOutlet weak var reviewTbl: UITableView?
    
    // MARK: - Variables
    // Handles review data fetching and processing
    var viewModel = RatingListViewModel()
    
    // Stores Combine subscriptions to prevent memory leaks
    private var cancellables = Set<AnyCancellable>()
    
    // The product ID we're showing reviews for
    var productID = String()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up initial configuration
        bindViewModel()
        setUpAccessibilityIdentifier()
        configureTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh reviews when view appears
        viewModel.raitingListAPI(productId: productID)
    }
    
    // MARK: - Setup Methods
    
    /// Sets accessibility identifiers for UI testing
    private func setUpAccessibilityIdentifier() {
        lblAvgRating?.accessibilityIdentifier = "lblAvgRating"
        lblTotalCountReview?.accessibilityIdentifier = "lblTotalCountReview"
        reviewTbl?.accessibilityIdentifier = "reviewTbl"
    }

    /// Configures table view delegate and data source
    private func configureTable() {
        reviewTbl?.delegate = self
        reviewTbl?.dataSource = self
    }

    // MARK: - Data Binding
    
    /// Sets up observers for ViewModel properties
    private func bindViewModel() {
        // Handle state changes (loading, success, error)
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        // Update average rating label when value changes
        viewModel.$averageRatingText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.lblAvgRating?.text = value
            }
            .store(in: &cancellables)

        // Update total reviews label when value changes
        viewModel.$totalReviewsText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.lblTotalCountReview?.text = value
            }
            .store(in: &cancellables)
        
        // Reload table when review data changes
        viewModel.$ratingList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reviewTbl?.reloadData()
            }
            .store(in: &cancellables)
        
        // Show/hide "no reviews" message
        viewModel.$showNoDataMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showEmpty in
                if showEmpty {
                    self?.reviewTbl?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                } else {
                    self?.reviewTbl?.backgroundView = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Handling
    
    /// Handles different states from ViewModel
    private func handleStateChange(_ state: AppState<GetRaitingModal>) {
        switch state {
        case .idle:
            // No action needed for idle state
            break
            
        case .loading:
            // Show loading indicator during API calls
            showLoadingIndicator()
            
        case .success:
            // Hide loading indicator when data loads successfully
            hideLoadingIndicator()
            
        case .failure(let error):
            // Hide loading and show error on failure
            hideLoadingIndicator()
            showErrorAlert(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // MARK: - Alert Methods
    
    /// Shows error alert with retry option
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            // Retry loading reviews when user taps retry
            self?.viewModel.retryRatingListAPI()
        }
    }
    
    // MARK: - Actions
    
    /// Handles tap on "Add Review" button
    @IBAction func didTapAddReviewBtn(_ sender: UIButton) {
        // Navigate to Add Review screen
        guard let addReviewVC = storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as? AddReviewVC else { return }
        addReviewVC.productID = productID
        navigationController?.pushViewController(addReviewVC, animated: true)
    }

    /// Handles tap on back button
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ReviewVC: UITableViewDelegate, UITableViewDataSource {
    /// Returns number of reviews to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ratingList.count
    }

    /// Configures each review cell with data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewTbl?.dequeueReusableCell(withIdentifier: "ReviewTVC", for: indexPath) as? ReviewTVC else {
            return UITableViewCell()
        }
        // Pass review data to cell for display
        guard let data = viewModel.ratingList[safe: indexPath.row] else {
             return cell
        }
        cell.ratingListing = data
        return cell
    }
}
