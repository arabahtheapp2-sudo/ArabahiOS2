//
//  SearchCategoryVC.swift
//  ARABAH
//
//  Created by cql71 on 17/01/25.
//

// MARK: - ViewController: SearchCategoryVC.swift (Updated for MVVM)

import UIKit
import SDWebImage
import Combine
import MBProgressHUD

class SearchCategoryVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - OUTLETS
    
    /// Constraints
    @IBOutlet weak var categoryHight: NSLayoutConstraint?
    
    /// Labels
    @IBOutlet weak var lblProdcut: UILabel?
    @IBOutlet weak var lblCategory: UILabel?
    
    /// Collection Views
    @IBOutlet weak var productCollection: UICollectionView?
    @IBOutlet weak var searchCollectionCateogy: UICollectionView?
    
    /// Table View
    @IBOutlet weak var recentSearchTbl: UITableView?
    
    /// Views
    @IBOutlet weak var viewRecentSearch: UIView?
    
    /// Text Field
    @IBOutlet weak var txtFldSearch: UITextField?
    
    /// UIButton
    @IBOutlet weak var filterButton: UIButton?
    @IBOutlet weak var backButton: UIButton?
    
    // MARK: - VARIABLES
    
    /// ViewModel instance for handling business logic
    var viewModel = SearchCatViewModel()
    
    /// Location coordinates
    var latitude = ""
    var longitude = ""
    
    /// Combine cancellables storage
    private var cancellables = Set<AnyCancellable>()

    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupAccessibilityIdentifier()
        setupListingViews()
        setUpView()
        viewModel.updateLocation(lat: latitude, long: longitude)
        viewModel.recentSearchAPI(isRetry: false)
    }

    // MARK: - UITextFieldDelegate
    
    /// Handles the return key press on the search text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let resultString = textField.text ?? ""

        if resultString.isEmpty {
            // Clear search when text field is empty
            viewModel.updateSearchQuery("")
            viewModel.clearCategory()
            self.searchCollectionCateogy?.isHidden = true
        } else {
            // Perform search with entered text
            viewModel.updateSearchQuery(resultString)
            viewModel.performSearch(isRetry: false)
            self.searchCollectionCateogy?.isHidden = false
        }

        txtFldSearch?.resignFirstResponder()
        return true
    }

    // MARK: - ACTIONS
    
    /// Filter button action - presents filter view controller
    @IBAction func btnFilter(_ sender: UIButton) {
        guard let filterVC = storyboard?.instantiateViewController(withIdentifier: "FilterVC") as? FilterVC else { return }
        filterVC.latitude = self.latitude
        filterVC.longitude = self.longitude
        filterVC.callback = { [weak self] (_, _) in
            guard let self = self else { return }
            let name = txtFldSearch?.text
            viewModel.updateSearchQuery(name ?? "")
            viewModel.fetchSearchResults(isRetry: false)
        }
        filterVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(filterVC, animated: false)
    }

    /// Back button action - pops the view controller
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - BINDING
    
    /// Sets up binding to ViewModel state changes
    private func bindViewModel() {
        viewModel.$createSearchState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.createSearchState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$searchCatState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.searchCatState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$recentSearchState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.recentSearchState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$historyDelState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.historyDelState(state)
            }
            .store(in: &cancellables)
        
    }

    /// Handles different states from ViewModel
   
    private func historyDelState(_ state: AppState<SearchHistoryDeleteModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            viewModel.recentSearchAPI(isRetry: false)
        case .failure(let error):
            hideLoadingIndicator()
            showRetry(error: error, retry: viewModel.retryDeleteHistory )
        case .validationError(let error):
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
            hideLoadingIndicator()
        }
    }
    
    private func recentSearchState(_ state: AppState<RecentSearchModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            setNoData(count: viewModel.recentModel?.count ?? 0)
            DispatchQueue.main.async {
                self.recentSearchTbl?.reloadData()
            }
        case .failure(let error):
            hideLoadingIndicator()
            setNoData(count: 0)
            DispatchQueue.main.async {
                self.recentSearchTbl?.reloadData()
            }
            showRetry(error: error) { [weak self] in
                self?.viewModel.recentSearchAPI(isRetry: true)
                
            }
        case .validationError(let error):
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
            hideLoadingIndicator()
        }
    }
    
    
    private func searchCatState(_ state: AppState<CategorySearchModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            self.viewRecentSearch?.isHidden = true
            hideLoadingIndicator()
            updateSearchResultUI()
        case .failure(let error):
            hideLoadingIndicator()
            showRetry(error: error) { [weak self] in
                self?.viewModel.fetchSearchResults(isRetry: true)
            }
        case .validationError(let error):
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
            hideLoadingIndicator()
        }
    }
    
    
    private func createSearchState(_ state: AppState<CreateModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
        case .failure(let error):
            hideLoadingIndicator()
            showRetry(error: error) { [weak self] in
                self?.viewModel.performSearch(isRetry: true)
            }
        case .validationError(let error):
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
            hideLoadingIndicator()
        }
    }

    /// Shows retry alert with the given error message
    private func showRetry(error: NetworkError, retry: (() -> Void)? = nil) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) {  _ in
            retry?()
        }
    }

    /// Updates UI based on search results
    private func updateSearchResultUI() {
        let catCount = viewModel.category?.count ?? 0
        let prodCount = viewModel.product?.count ?? 0
        
        searchCollectionCateogy?.setNoDataMessage(catCount == 0 ? PlaceHolderTitleRegex.noDataFound : "", txtColor: (catCount == 0 ? UIColor.set : .clear))
        productCollection?.setNoDataMessage(prodCount == 0 ? PlaceHolderTitleRegex.noDataFound : "", txtColor: (catCount == 0 ? UIColor.set : .clear))
        
        categoryHight?.constant = catCount == 0 ? 0 : 186
        lblCategory?.isHidden = catCount == 0
        lblProdcut?.isHidden = prodCount == 0
        DispatchQueue.main.async {
            self.searchCollectionCateogy?.reloadData()
            self.productCollection?.reloadData()
        }
    }
    /// Sets no data message for table view based on item count
    private func setNoData(count: Int) {
        if count == 0 {
            recentSearchTbl?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            recentSearchTbl?.backgroundView = nil
        }
    }

    /// Sets up accessibility identifiers for UI testing
    private func setupAccessibilityIdentifier() {
        txtFldSearch?.accessibilityIdentifier = "txtFldSearch"
        recentSearchTbl?.accessibilityIdentifier = "recentSearchTbl"
        productCollection?.accessibilityIdentifier = "productCollection"
        searchCollectionCateogy?.accessibilityIdentifier = "searchCollectionCateogy"
        viewRecentSearch?.accessibilityIdentifier = "viewRecentSearch"
        filterButton?.accessibilityIdentifier = "BtnFilter"
        backButton?.accessibilityIdentifier = "btnBack"

    }

    /// Sets up delegates and data sources for listing views
    private func setupListingViews() {
        recentSearchTbl?.delegate = self
        recentSearchTbl?.dataSource = self
        productCollection?.delegate = self
        productCollection?.dataSource = self
        searchCollectionCateogy?.delegate = self
        searchCollectionCateogy?.dataSource = self
    }

    /// Initial view setup
    private func setUpView() {
        txtFldSearch?.delegate = self
        txtFldSearch?.becomeFirstResponder()
        viewRecentSearch?.isHidden = false
        txtFldSearch?.textAlignment = Store.isArabicLang ? .right : .left
        lblProdcut?.setLocalizedTitle(key: PlaceHolderTitleRegex.product)
        lblCategory?.setLocalizedTitle(key: PlaceHolderTitleRegex.category)
        lblProdcut?.isHidden = true
        lblCategory?.isHidden = true
    }
}

// MARK: - TableView Delegate & DataSource

extension SearchCategoryVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns number of rows in recent search table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recentModel?.count ?? 0
    }

    /// Configures recent search table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchTVC", for: indexPath) as? RecentSearchTVC else {
             return UITableViewCell()
        }
        if let data = viewModel.recentModel?[safe: indexPath.row] {
            cell.lblName?.text = data.name ?? ""
            cell.btnCross?.tag = indexPath.row
            cell.btnCross?.addTarget(self, action: #selector(deleteBtn(_:)), for: .touchUpInside)
        } else {
            cell.lblName?.text = ""
        }
        
        return cell
    }

    /// Handles selection of recent search item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = viewModel.recentModel?[safe: indexPath.row] {
            let name = data.name ?? ""
            txtFldSearch?.text = name
            viewModel.updateSearchQuery(name)
            viewModel.performSearch(isRetry: false)
            viewRecentSearch?.isHidden = true
            lblProdcut?.isHidden = false
            lblCategory?.isHidden = false
        }
    }

    /// Handles delete button action for recent search items
    @objc func deleteBtn(_ sender: UIButton) {
        let id = viewModel.recentModel?[sender.tag].id ?? ""
        viewModel.historyDeleteAPI(with: id)
    }
}
