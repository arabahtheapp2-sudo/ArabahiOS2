//
//  DealsOffVC.swift
//  ARABAH
//
//  Created by cqlios on 30/10/24.
//

import UIKit
import SDWebImage
import SkeletonView
import SafariServices
import MBProgressHUD
import Combine

/// ViewController responsible for displaying a list of deals and offers.
/// Uses a ViewModel to fetch data and shows skeleton loading views while data is loading.
class DealsOffVC: UIViewController {
    
    // MARK: - OUTLETS
    
    /// Header label for the view
    @IBOutlet weak var lblHeader: UILabel!
    
    /// TableView to display deals and offers
    @IBOutlet var tbl: UITableView!
    
    // MARK: - VARIABLES
    
    /// ViewModel to handle business logic and data fetching
    var viewModel = DealsViewModel()
    
    /// Flag to track if data is currently loading
    var isLoading = true
    
    /// Set to store Combine cancellables for memory management
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderText()
        bindViewModel()
        configureTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getOfferDeals()
    }
    
    // MARK: - FUNCTIONS
    
    /// Sets up the header text using localized string
    private func setupHeaderText() {
        lblHeader.text = PlaceHolderTitleRegex.deals
    }
    
    /// Configures table view delegate and data source
    private func configureTable() {
        tbl.delegate = self
        tbl.dataSource = self
    }
    
    /// Binds to ViewModel state changes to update UI accordingly
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Handles different states from ViewModel and updates UI
    /// - Parameter state: Current state of the ViewModel
    private func handleStateChange(_ state: AppState<GetOfferDealsModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            isLoading = true
            showLoadingIndicator()
        case .success:
            isLoading = false
            hideLoadingIndicator()
            showNoData()
            tbl.reloadData()
        case .failure(let error):
            isLoading = false
            hideLoadingIndicator()
            showNoData()
            showErrorAlert(error: error)
            tbl.reloadData()
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    /// Shows error alert when data fetch fails
    /// - Parameter error: Network error that occurred
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryGetOfferDealsAPI()
        }
    }
    
    /// Initiates API call to fetch deals and offers
    func getOfferDeals() {
        viewModel.getOfferDealsAPI()
    }
    
    /// Shows no data message if there are no deals available
    private func showNoData() {
        if viewModel.isDataEmpty {
            tbl.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            tbl.backgroundView = nil
        }
    }
}

// MARK: - UITableView Delegate & DataSource methods

extension DealsOffVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Show skeleton cells while loading, otherwise actual count
        return isLoading ? 10 : viewModel.dealsBody?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealsOffTVC", for: indexPath) as? DealsOffTVC else {
            return UITableViewCell()
        }

        // Configure skeleton view for loading state
        cell.imgView.isSkeletonable = true
        cell.lblName.isSkeletonable = true

        if isLoading {
            // Show skeleton animation while loading
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblName.showAnimatedGradientSkeleton()
        } else {
            // Hide skeleton when data is loaded
            cell.lblName.hideSkeleton()
            cell.imgView.hideSkeleton()

            // Set deal text
            cell.lblName.text = viewModel.formattedDealText(at: indexPath.row)

            // Load deal and store images asynchronously
            let dealImageUrl = viewModel.dealImageUrl(at: indexPath.row)
            let storeImageUrl = viewModel.storeImageUrl(at: indexPath.row)

            cell.imgView.sd_setImage(with: URL(string: dealImageUrl), placeholderImage: UIImage(named: "Placeholder")) { [weak self] _, _, _, _ in
                guard let _ = self else { return }
                cell.imgView.hideSkeleton()
            }

            cell.imageStore.sd_setImage(with: URL(string: storeImageUrl), placeholderImage: UIImage(named: "Placeholder")) { [weak self] _, _, _, _ in
                guard let _ = self else { return }
                cell.imageStore.hideSkeleton()
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dealImageUrl = viewModel.dealImageUrl(at: indexPath.row)

        // Handle PDF or image selection differently
        if viewModel.isPDF(dealImageUrl) {
            openPDFInSafariViewController(with: dealImageUrl)
        } else {
            // Navigate to zoom view for images
            guard let zoomVC = storyboard?.instantiateViewController(identifier: "ZoomImageVC") as? ZoomImageVC else { return }
            zoomVC.imageUrl = dealImageUrl
            navigationController?.pushViewController(zoomVC, animated: true)
        }
    }

    /// Opens PDF URL in Safari View Controller
    /// - Parameter urlString: URL string of the PDF to open
    private func openPDFInSafariViewController(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
}
