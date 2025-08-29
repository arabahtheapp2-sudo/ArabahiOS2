//
//  CategoryVC.swift
//  ARABAH
//
//  Created by cqlios on 22/10/24.
//

import UIKit
import SDWebImage
import SkeletonView
import Combine

/// ViewController responsible for displaying a list of categories in a collection view.
class CategoryVC: UIViewController {

    // MARK: - OUTLETS
    
    /// Text field for searching categories
    @IBOutlet weak var txtFldSearch: UITextField!
    
    /// Collection view to display categories
    @IBOutlet var categoryCollection: UICollectionView!

    // MARK: - VARIABLES
    
    /// ViewModel instance for handling business logic
    var viewModel = CategoryViewModel()
    
    /// Latitude for location-based services
    var latitude = String()
    
    /// Longitude for location-based services
    var longitude = String()
    
    /// Refresh control for pull-to-refresh functionality
    private let refreshControl = UIRefreshControl()
    
    /// Set to store Combine cancellables
    private var cancellables = Set<AnyCancellable>()

    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set location coordinates in ViewModel
        viewModel.latitude = latitude
        viewModel.longitude = longitude
        // Fetch initial categories
        viewModel.fetchCategories()
        // Setup accessibility identifiers
        accessibilityIdentifier()
        // Configure refresh control
        setupRefreshConroller()
        // Bind ViewModel to ViewController
        bindViewModel()
    }

    // MARK: - FUNCTIONS
    
    /// Binds ViewModel state changes to ViewController updates
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)

        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    // Show no data message when collection is empty
                    self?.categoryCollection.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                } else {
                    // Remove background view when data is available
                    self?.categoryCollection.backgroundView = nil
                }
            }
            .store(in: &cancellables)
    }

    /// Handles different states from ViewModel
    /// - Parameter state: Current state of the ViewModel
    private func handleStateChange(_ state: AppState<CategoryListModal>) {
        switch state {
        case .idle:
            // No action needed in idle state
            break
        case .loading:
            // Reload collection to show skeleton views
            categoryCollection.reloadData()
        case .success:
            // Reload with actual data
            categoryCollection.reloadData()
            refreshControl.endRefreshing()
        case .failure(let error):
            // Show error alert
            showErrorAlert(error: error)
            refreshControl.endRefreshing()
        case .validationError(let error):
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
            break
        }
    }

    /// Sets up accessibility identifiers for UI testing
    private func accessibilityIdentifier() {
        categoryCollection.accessibilityIdentifier = "categoryCollection"
    }

    /// Configures pull-to-refresh functionality
    private func setupRefreshConroller() {
        if #available(iOS 10.0, *) {
            categoryCollection.refreshControl = refreshControl
        } else {
            categoryCollection.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    /// Shows error alert with retry option
    /// - Parameter error: Network error to display
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retry()
        }
    }

    /// Handles refresh action
    @objc private func refreshData() {
        refreshControl.beginRefreshing()
        viewModel.retry()
    }

    /// Back button action
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// Returns number of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if case .loading = viewModel.state {
            // Return 10 skeleton cells during loading
            return 10
        } else {
            // Return actual count from ViewModel
            return viewModel.numberOfItems
        }
    }

    /// Configures and returns collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCVC", for: indexPath) as? CategoryCVC else {
            return UICollectionViewCell()
        }

        // Make views skeletonable
        cell.categoryImg.isSkeletonable = true
        cell.categoryName.isSkeletonable = true

        if case .loading = viewModel.state {
            // Show skeleton view during loading
            cell.categoryImg.showAnimatedGradientSkeleton()
            cell.categoryName.showAnimatedGradientSkeleton()
        } else if let model = viewModel.categoryCell(for: indexPath.row) {
            // Configure cell with actual data
            cell.categoryName.hideSkeleton()
            cell.categoryName.text = model.categoryName ?? ""

            // Load category image with SDWebImage
            let catImageUrl = (AppConstants.imageURL) + (model.image ?? "")
            cell.categoryImg.sd_setImage(with: URL(string: catImageUrl), placeholderImage: UIImage(named: "Placeholder")) { [weak self] _, _, _, _ in
                guard let _ = self else { return }
                cell.categoryImg.hideSkeleton()
            }
        }
        return cell
    }

    /// Returns size for collection view item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Two items per row with fixed height
        return CGSize(width: collectionView.frame.width / 2, height: 174)
    }

    /// Handles item selection in collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ignore selection during loading state
        if case .loading = viewModel.state { return }

        // Navigate to SubCategoryVC with selected category details
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as? SubCategoryVC else { return }
        vc.viewModel.productID = viewModel.categoryBody?[indexPath.row].id ?? ""
        vc.viewModel.check = 1
        vc.viewModel.categoryName = viewModel.categoryBody?[indexPath.row].categoryName ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
