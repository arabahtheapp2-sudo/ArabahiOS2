import UIKit
import Combine
import MBProgressHUD

/// ViewController for filtering products by categories, stores, and brands
class FilterVC: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var clearAllBn: UIButton!  // Button to clear all filters
    @IBOutlet weak var lblFilter: UILabel!   // Title label "Filter"
    @IBOutlet weak var fitlerTbl: UITableView!  // Table showing filter options
    @IBOutlet var btnApply: UIButton!        // Button to apply selected filters
    @IBOutlet var viewMain: UIView!          // Main container view with rounded corners
    
    // MARK: - VARIABLES
    
    var viewModel = FilterViewModel()        // Handles filter data and logic
    private var cancellables = Set<AnyCancellable>() // For Combine subscriptions
    var latitude = String()                  // User's current latitude
    var longitude = String()                 // User's current longitude
    var callback: ((String, Bool) -> ())?    // Closure to return filter results
    
    // Section headers for the table
    var HeaderSection = [PlaceHolderTitleRegex.categories,
                        PlaceHolderTitleRegex.storeName,
                        PlaceHolderTitleRegex.brandName]
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()      // Setup ViewModel bindings
        setupView()         // Configure UI elements
        fetchfilterListing(isRetry: false) // Load initial filter data
    }
    
    // MARK: - VIEWMODEL BINDING
    
    private func bindViewModel() {
        // React to ViewModel state changes
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
        
        // Update empty state message when data changes
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.setNoDataMsg(count: isEmpty ? 0 : 1)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - STATE HANDLING
    
    private func handleStateChange(_ state: AppState<FilterGetDataModal>) {
        switch state {
        case .idle:
            break // No action needed
            
        case .loading:
            showLoadingIndicator() // Show spinner during loading
            
        case .success:
            hideLoadingIndicator() // Hide spinner
            fitlerTbl.reloadData() // Refresh table with new data
            
        case .failure(let error):
            hideLoadingIndicator()
            setNoDataMsg(count: 0) // Show empty state
            showErrorAlert(error: error) // Display error
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // MARK: - UI SETUP
    
    private func setupView() {
        // Localize UI elements
        self.lblFilter.setLocalizedTitle(key: PlaceHolderTitleRegex.filter)
        self.clearAllBn.setLocalizedTitleButton(key: PlaceHolderTitleRegex.clear)
        
        // Style the main view with rounded top corners
        viewMain.layer.cornerRadius = 26
        viewMain.layer.masksToBounds = true
        viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        // Style the apply button
        btnApply.layer.cornerRadius = 8
        btnApply.layer.masksToBounds = true
        
        fitlerTbl.accessibilityIdentifier = "fitlerTbl"
        btnApply.accessibilityIdentifier = "btnApply"
        clearAllBn.accessibilityIdentifier = "clearAllBn"
    }
    
    // MARK: - DATA LOADING
    
    private func fetchfilterListing(isRetry: Bool) {
        let input = FilterViewModel.Input(longitude: longitude, latitude: latitude)
        viewModel.fetchFilterDataAPI(with: input,isRetry: isRetry)
    }
    
    // MARK: - ALERT & LOADING
    
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName,
                                                message: error.localizedDescription) { [weak self] (_) in
            self?.fetchfilterListing(isRetry: true) // Retry on error
        }
    }
    
    
    // MARK: - EMPTY STATE
    
    func setNoDataMsg(count: Int) {
        if count == 0 {
            fitlerTbl.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            fitlerTbl.backgroundView = nil
        }
    }
    
    // MARK: - ACTIONS
    
    @IBAction func btnApply(_ sender: UIButton) {
        viewModel.saveSelections()
        let result = viewModel.getFormattedSelectedFilters()
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.callback?(result, false) // Return selected filters
        }
    }
    
    @IBAction func btnClear(_ sender: UIButton) {
        viewModel.clearSelections()
        fitlerTbl.reloadData()
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.callback?("", true) // Clear all filters
        }
    }
    
    @IBAction func btnDismiss(_ sender: UIButton) {
        self.dismiss(animated: true) // Close without changes
    }
}

// MARK: - TableView Delegate & DataSource

extension FilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HeaderSection.count // 3 sections: Categories, Stores, Brands
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.category?.count ?? 0  // Categories count
        case 1: return viewModel.storeData?.count ?? 0 // Stores count
        case 2: return viewModel.brand?.count ?? 0     // Brands count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterHeaderTVC") as? FilterHeaderTVC else {
            return UIView()
        }
        cell.lblHeader.text = HeaderSection[section] // Set section title
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTVC", for: indexPath) as? FilterTVC else {
            return UITableViewCell()
        }
        
        // Set accessibility ID for testing
        cell.btnCheck.accessibilityIdentifier = "checkbox_\(indexPath.section)_\(indexPath.row)"
        
        // Configure cell based on section
        switch indexPath.section {
        case 0: // Categories
            let category = viewModel.category?[indexPath.row]
            cell.lblName?.text = category?.categoryName ?? PlaceHolderTitleRegex.unknownCategory
            let categoryID = category?.id ?? ""
            cell.btnCheck.setImage(viewModel.selectedCategoryIDs.contains(categoryID) ?
                UIImage(named: "Check") : UIImage(named: "UnCheck"), for: .normal)
            
        case 1: // Stores
            let store = viewModel.storeData?[indexPath.row]
            cell.lblName?.text = store?.name ?? ""
            let storeID = store?.id ?? ""
            cell.btnCheck.setImage(viewModel.selectedStoreIDs.contains(storeID) ?
                UIImage(named: "Check") : UIImage(named: "UnCheck"), for: .normal)
            
        case 2: // Brands
            let brand = viewModel.brand?[indexPath.row]
            cell.lblName?.text = brand?.brandname ?? ""
            let brandID = brand?.id ?? ""
            cell.btnCheck.setImage(viewModel.selectedBrandIDs.contains(brandID) ?
                UIImage(named: "Check") : UIImage(named: "UnCheck"), for: .normal)
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26 // Fixed height for section headers
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get ID of selected item
        var id = ""
        switch indexPath.section {
        case 0: id = viewModel.category?[indexPath.row].id ?? ""
        case 1: id = viewModel.storeData?[indexPath.row].id ?? ""
        case 2: id = viewModel.brand?[indexPath.row].id ?? ""
        default: return
        }
        
        // Toggle selection and refresh table
        viewModel.toggleSelection(id: id, section: indexPath.section)
        tableView.reloadData()
    }
}
