//
//  FavProductVC.swift
//  ARABAH
//
//  ViewController for displaying and managing favorite products
//

import UIKit
import Combine
import MBProgressHUD

class FavProductVC: UIViewController {
    
    // MARK: - Outlets
    
    // Collection view to display favorite products
    @IBOutlet weak var favProdCollection: UICollectionView?
    
    // MARK: - Properties
    
    // ViewModel handling favorite products logic
    var viewModel = FavViewModel()
    
    // Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // ID of the selected provider (if applicable)
    var selectedProviderID = String()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up view model binding
        bindViewModel()
        
        // Configure collection view
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh favorite products list when view appears
        viewModel.getProductfavList()
    }
    
    // MARK: - Setup Methods
    
    /// Configures the collection view delegate and data source
    private func configureCollectionView() {
        favProdCollection?.delegate = self
        favProdCollection?.dataSource = self
        
        // Set accessibility identifier for UI testing
        favProdCollection?.accessibilityIdentifier = "favProdCollection"
        favProdCollection?.backgroundView?.accessibilityIdentifier = "noDataLabel"
    }
    
    /// Sets up bindings to ViewModel properties
    private func bindViewModel() {
        // Handle state changes from ViewModel
        viewModel.$likeDislikeState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleLikeDislikeState(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$likeListState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleListState(state)
            }
            .store(in: &cancellables)
        
        // Reload collection when liked products change
        viewModel.$likedBody
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.favProdCollection?.reloadData()
            }
            .store(in: &cancellables)
        
        // Show/hide no data message
        viewModel.$showNoDataMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.favProdCollection?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                } else {
                    self?.favProdCollection?.backgroundView = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Handling
    private func handleLikeDislikeState(_ state: AppState<LikeModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: RegexMessages.productDislike, isSuccess: .success)
        case .failure(let error):
            hideLoadingIndicator()
            showDislikeErrorAlert(error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    private func handleListState(_ state: AppState<LikeProductModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
        case .failure(let error):
            hideLoadingIndicator()
            showFavListErrorAlert(error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // MARK: - Alert Methods
    
    /// Shows error alert for like/dislike failure
    private func showDislikeErrorAlert(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
    
    /// Shows error alert for favorite list fetch failure with retry option
    private func showFavListErrorAlert(_ error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryGetProductfavList()
        }
    }
    
    // MARK: - Actions
    
    /// Handles back button tap
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Collection View Delegate & Data Source

extension FavProductVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.likedBody?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavProductCVC", for: indexPath) as? FavProductCVC else {
            return UICollectionViewCell()
        }
        
        // Configure cell with product data
        if let model = viewModel.likedBody?[safe: indexPath.row] {
            cell.setupObj = model
            // Set favorite button state based on product status
            cell.btnFav?.isSelected = model.status == 0
            cell.btnFav?.tag = indexPath.row
            // Add target for favorite button tap
            cell.btnFav?.addTarget(self, action: #selector(btnLike(_:)), for: .touchUpInside)
        } else {
            cell.setupObj = nil
        }
        
        return cell
    }
    
    // MARK: - Delegate
    
    /// Handles favorite button tap in collection view cells
    @objc func btnLike(_ sender: UIButton) {
       if let productData = viewModel.likedBody?[safe: sender.tag], let productID = productData.id {
            // Call like/dislike API for the tapped product
            viewModel.likeDislikeAPI(productID: productID)
        }
       
    }
    
    /// Returns size for collection view items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Two items per row with fixed height
        return CGSize(width: (favProdCollection?.frame.width ?? 0) / 2, height: 163)
    }
    
    /// Handles product selection in collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Navigate to product detail screen
        guard let likedBody = viewModel.likedBody?[safe: indexPath.row], let productId = likedBody.productID?.id, let subCatDetailVC = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
        subCatDetailVC.prodcutid = productId
        self.navigationController?.pushViewController(subCatDetailVC, animated: true)
    }
}
