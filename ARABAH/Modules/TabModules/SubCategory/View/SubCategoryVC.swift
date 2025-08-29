//
//  SubCategoryVC.swift
//  ARABAH
//
//  This view controller displays a collection of sub-category products.
//  It handles displaying products, refreshing data, and adding products to cart.
//

import UIKit
import SDWebImage
import SkeletonView
import Combine
import MBProgressHUD

class SubCategoryVC: UIViewController {
    
    // MARK: - OUTLETS
    
    /// Refresh control for pull-to-refresh functionality
    private let refreshControl = UIRefreshControl()
    
    /// Collection view to display sub-category products
    @IBOutlet weak var subCategoryColl: UICollectionView!
    
    /// Header label showing the category title
    @IBOutlet weak var headerLbll: UILabel!
    
    /// Back button to navigate to previous screen
    @IBOutlet weak var btnBack: UIButton!
    
    // MARK: - VARIABLES
    
    /// ViewModel handling business logic for this view controller
    var viewModel = SubCatViewModel()
    
    /// Set to store Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    /// Callback closure to return selected product ID
    var idCallback: ((String) -> ())?
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAccessibilityIdentifier()
        setUpCollectionView()
        setUpRefreshController()
        bindViewModel()
        loadInitialData()
    }
    
    // MARK: - ACTIONS
    
    /// Handles back button tap action
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Loads initial data and sets up the view
    private func loadInitialData() {
        headerLbll.text = viewModel.currentHeaderTitle
        viewModel.refresh(isRetry: false)
    }
}

// MARK: - COLLECTION VIEW DELEGATES & DATA SOURCE

extension SubCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Returns number of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Show skeleton cells if data is not loaded yet
        return viewModel.displayItems.isEmpty ? 10 : viewModel.displayItems.count
    }
    
    /// Configures and returns collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = subCategoryColl.dequeueReusableCell(withReuseIdentifier: "SubCategoryCVC", for: indexPath) as? SubCategoryCVC else {
            return UICollectionViewCell()
        }
        
        // Configure skeleton view properties
        cell.imgView.isSkeletonable = true
        cell.lblName.isSkeletonable = true
        cell.lblProductUnit.isSkeletonable = true
        cell.btnAdd.isSkeletonable = true
        cell.btnAdd.layer.cornerRadius = cell.btnAdd.frame.size.width / 2
        cell.btnAdd.clipsToBounds = true
        
        if viewModel.displayItems.isEmpty {
            // Show skeleton loading views
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblName.showAnimatedGradientSkeleton()
            cell.lblProductUnit.showAnimatedGradientSkeleton()
            cell.btnAdd.showAnimatedGradientSkeleton()
        } else {
            // Configure cell with actual data
            let item = viewModel.displayItems[indexPath.row]
            cell.lblName.text = item.name
            cell.lblProductUnit.text = item.productUnit
            
            // Load product image with placeholder
            cell.imgView.sd_setImage(with: URL(string: item.imageURL), placeholderImage: UIImage(named: "Placeholder")) { [weak self] _, _, _, _ in
                guard let _ = self else { return }
                cell.imgView.hideSkeleton()
            }
            
            // Hide skeletons and set up real data
            cell.lblName.hideSkeleton()
            cell.lblProductUnit.hideSkeleton()
            cell.btnAdd.hideSkeleton()
            cell.btnAdd.tag = indexPath.row
            cell.btnAdd.addTarget(self, action: #selector(addbtn(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    /// Handles add to cart button tap
    @objc func addbtn(_ sender: UIButton) {
        viewModel.addProductToCart(at: sender.tag)
    }
    
    /// Returns size for collection view item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: subCategoryColl.frame.width / 2, height: 186)
    }
    
    /// Handles item selection in collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !viewModel.displayItems.isEmpty else { return }
        let selectedId = viewModel.displayItems[indexPath.row].id
        
        if viewModel.check == 2 {
            // If in selection mode, return the selected ID via callback
            idCallback?(selectedId)
            navigationController?.popViewController(animated: false)
        } else {
            // Otherwise, navigate to product detail view
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
            vc.prodcutid = selectedId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - PRIVATE METHODS

extension SubCategoryVC {
    
    /// Sets up accessibility identifiers for UI testing
    private func setUpAccessibilityIdentifier() {
        self.view.accessibilityIdentifier = "SubCatDetailVC_Container"
        subCategoryColl.accessibilityIdentifier = "subCategoryColl"
        btnBack.accessibilityIdentifier = "Back"
    }
    
    /// Sets up collection view delegates and data source
    private func setUpCollectionView() {
        subCategoryColl.delegate = self
        subCategoryColl.dataSource = self
    }
    
    /// Configures pull-to-refresh functionality
    private func setUpRefreshController() {
        if #available(iOS 10.0, *) {
            subCategoryColl.refreshControl = refreshControl
        } else {
            subCategoryColl.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    /// Handles refresh control action
    @objc private func refreshData() {
        viewModel.refresh(isRetry: false)
    }
    
    /// Binds to ViewModel state changes
    private func bindViewModel() {
        viewModel.$subCatProductState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.subCatProductState(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$getLatProductState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.getLatProductState(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$getSimilarProductState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.getSimilarProductState(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$addToShopState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.addToShopState(state)
            }
            .store(in: &cancellables)
        
        
    }
    
    /// Handles different states from ViewModel
    private func addToShopState(_ state: AppState<AddShoppingModal>) {
        
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
        case .failure(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
                self?.viewModel.retryAddToShop()
            }
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    private func getSimilarProductState(_ state: AppState<SimilarProductModal>) {
        
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            refreshControl.endRefreshing()
            subCategoryColl.reloadData()
            setNoDataMsg()
            hideLoadingIndicator()
        case .failure(let error):
            hideLoadingIndicator()
            refreshControl.endRefreshing()
            setNoDataMsg()
            CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
                self?.viewModel.refresh(isRetry: true)
            }
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
        
    }
    
    
    private func getLatProductState(_ state: AppState<LatestProModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            refreshControl.endRefreshing()
            subCategoryColl.reloadData()
            setNoDataMsg()
            hideLoadingIndicator()
        case .failure(let error):
            hideLoadingIndicator()
            refreshControl.endRefreshing()
            setNoDataMsg()
            CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
                self?.viewModel.refresh(isRetry: true)
            }
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    private func subCatProductState(_ state: AppState<SubCatProductModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            refreshControl.endRefreshing()
            subCategoryColl.reloadData()
            setNoDataMsg()
        case .failure(let error):
            hideLoadingIndicator()
            refreshControl.endRefreshing()
            setNoDataMsg()
            CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
                self?.viewModel.refresh(isRetry: true)
            }
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
        
    }
    
    /// Shows no data message when collection view is empty
    private func setNoDataMsg() {
        if viewModel.displayItems.isEmpty {
            subCategoryColl.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            subCategoryColl.backgroundView = nil
        }
    }

}
