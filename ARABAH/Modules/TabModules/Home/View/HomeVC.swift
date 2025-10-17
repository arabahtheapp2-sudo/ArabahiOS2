//
//  HomeVC.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine
import GooglePlaces
import CoreLocation

/// Main home screen controller that handles:
/// - Displaying product categories, banners and latest products
/// - Location management
/// - User search and navigation
class HomeVC: UIViewController {

    // MARK: - Outlets
    
    // All the UI components connected from storyboard
    @IBOutlet weak var homeTbl: UITableView?          // Main table view for content
    @IBOutlet weak var textFieldSearch: UITextField?  // Search field (currently decorative)
    @IBOutlet weak var labelUsername: UILabel?        // Greeting label with user name
    @IBOutlet weak var lblLocation: UILabel?        // Shows current city
    @IBOutlet weak var btnLocation: UIButton?        // Button to change location
    @IBOutlet weak var notificationButton: UIButton? // Notification bell icon
    @IBOutlet weak var searchButton: UIButton?       // Search icon button
    
    // MARK: - Properties
    
    private var viewModel = HomeViewModel()          // Handles all business logic
    private var cancellables = Set<AnyCancellable>() // Stores active subscriptions
    private let refreshControl = UIRefreshControl()  // Pull-to-refresh control
    private let locationManager = CLLocationManager() // Gets user's location
    private var isLoading = true                     // Tracks loading state
    private var apiCalled = false                    // Prevents duplicate API calls
    private var section = [                          // Table view section headers
        PlaceHolderTitleRegex.banner,
        PlaceHolderTitleRegex.categories,
        PlaceHolderTitleRegex.latestProducts
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Basic setup when view loads
        bindViewModel()          // Connect view model updates
        setupTableView()         // Configure table view
        setupUI()                // Additional UI setup
        checkLocationPermissions() // Request location access
        observeAppLifecycle()    // Handle app coming to foreground
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Update UI when view appears
        textFieldSearch?.textAlignment = Store.isArabicLang ? .right : .left
        
        // Personalize greeting with user's name if available
        if let name = Store.userDetails?.body?.name, !name.isEmpty {
            labelUsername?.text = "\(PlaceHolderTitleRegex.hello) \(name)"
        } else {
            labelUsername?.text = PlaceHolderTitleRegex.hello
        }
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Setup Methods
    
    /// Connects view model state changes to UI updates
    private func bindViewModel() {
        // React to view model state changes
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)

        // Update location label when city changes
        viewModel.$currentCity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city in
                self?.lblLocation?.text = city
            }
            .store(in: &cancellables)
    }

    /// Configures table view with refresh control
    private func setupTableView() {
        homeTbl?.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    /// Additional UI configuration
    private func setupUI() {
        // Set accessibility identifiers for testing
        searchButton?.accessibilityIdentifier = "Search"
        notificationButton?.accessibilityIdentifier = "Notification"
        btnLocation?.accessibilityIdentifier = "Location"
    }

    /// Listens for app coming to foreground to recheck location
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkLocationPermissions),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    // MARK: - Location Handling
    
    /// Checks and requests location permissions
    @objc private func checkLocationPermissions() {
        locationManager.delegate = self
        LocationPermissionManager.shared.checkLocationAuthorization(
            from: self,
            locationManager: locationManager
        )
    }

    // MARK: - Data Refresh
    
    /// Handles pull-to-refresh action
    @objc private func refreshData() {
        if let loc = viewModel.location {
            viewModel.updateLocation(loc) // Refresh with current location
        }
    }

    // MARK: - State Management
    
    /// Updates UI based on view model's current state
    private func handleState(_ state: AppState<HomeModal>) {
        switch state {
        case .idle:
            break // Initial state, no action needed
            
        case .loading:
            // Show loading state
            isLoading = true
            DispatchQueue.main.async {
                self.homeTbl?.reloadData()
            }
            
        case .success:
            // Data loaded successfully
            isLoading = false
            refreshControl.endRefreshing()
            homeTbl?.backgroundView = nil
            DispatchQueue.main.async {
                self.homeTbl?.reloadData()
            }
            
        case .failure(let error):
            // Show error state
            isLoading = false
            refreshControl.endRefreshing()
            homeTbl?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: .gray)
            
            // Offer retry option
            CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
                self?.viewModel.retryHomeAPI()
            }
        case .validationError(let error):
            isLoading = false
            DispatchQueue.main.async {
                self.homeTbl?.reloadData()
            }
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }

    // MARK: - Button Actions
    
    @IBAction func btnLocationTapped(_ sender: UIButton) {
        // Show Google Places picker when location button tapped
        let picker = GMSAutocompleteViewController()
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func btnNotificationTapped(_ sender: UIButton) {
        // Check auth before showing notifications
        guard Store.shared.authToken?.isEmpty == false else {
            authNil()
            return
        }
        navigate(to: "NotificationListVC")
    }

    @IBAction func btnSearchTapped(_ sender: UIButton) {
        // Check auth before showing search
        guard Store.shared.authToken?.isEmpty == false else {
            authNil()
            return
        }
        
        guard let searchCategoryVC = storyboard?.instantiateViewController(withIdentifier: "SearchCategoryVC") as? SearchCategoryVC else { return }
        
        // Pass current location to search
        if let loc = viewModel.location {
            searchCategoryVC.latitude = String(loc.latitude)
            searchCategoryVC.longitude = String(loc.longitude)
        }
        navigationController?.pushViewController(searchCategoryVC, animated: true)
    }

    @IBAction func btnScanTapped(_ sender: UIButton) {
        navigate(to: "ScannerVC")
    }

    @IBAction func btnFilterTapped(_ sender: UIButton) {
        // Show filter options
        guard let filterVC = storyboard?.instantiateViewController(withIdentifier: "FilterVC") as? FilterVC else { return }
        
        // Pass current location
        if let loc = viewModel.location {
            filterVC.latitude = String(loc.latitude)
            filterVC.longitude = String(loc.longitude)
        }
        
        // Handle filter selection callback
        filterVC.callback = { [weak self] categoryId, isClear in
            guard let self = self, let loc = self.viewModel.location else { return }

            if isClear {
                // Clear filters
                self.viewModel.fetchHomeData(
                    longitude: String(loc.longitude),
                    latitude: String(loc.latitude))
            } else {
                // Apply category filter
                self.viewModel.fetchHomeData(
                    longitude: String(loc.longitude),
                    latitude: String(loc.latitude),
                    categoryID: categoryId)
            }
        }

        filterVC.modalPresentationStyle = .overCurrentContext
        navigationController?.present(filterVC, animated: false)
    }

    /// Helper for navigation
    private func navigate(to identifier: String) {
        guard let toVC = storyboard?.instantiateViewController(withIdentifier: identifier) else { return }
        navigationController?.pushViewController(toVC, animated: true)
    }
}

// MARK: - Table View Management
extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4 // Banners, Categories, Products, (empty section for layout)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Each section has just one row (containing a collection view)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Special case for empty layout section
        if indexPath.section == 3 {
            return homeTbl?.dequeueReusableCell(withIdentifier: "BannerTVC", for: indexPath) ?? UITableViewCell()
        }

        // Main content cell
        guard let cell = homeTbl?.dequeueReusableCell(withIdentifier: "HomeTVC", for: indexPath) as? HomeTVC else {
            return UITableViewCell()
        }
        guard let data = section[safe: indexPath.section] else {
             return cell
        }
        // Configure cell based on loading state
        cell.isLoading = isLoading
        cell.banner = viewModel.banner
        cell.category = viewModel.category
        cell.latProduct = viewModel.latProduct
        cell.homeColl?.reloadData()
        cell.homeColl?.tag = indexPath.section
        cell.btnSeeAll?.tag = indexPath.section
        cell.btnSeeAll?.setLocalizedTitleButton(key: PlaceHolderTitleRegex.seeAll)
        cell.headerLbl?.text = data
        cell.btnSeeAll?.addTarget(self, action: #selector(seeAllBtnTapped(_:)), for: .touchUpInside)
        return cell
    }

    /// Handles "See All" button taps in each section
    @objc private func seeAllBtnTapped(_ sender: UIButton) {
        // Determine which screen to show based on section
        let vcID = sender.tag == 1 ? "CategoryVC" : "SubCategoryVC"
        guard let seeAllVC = storyboard?.instantiateViewController(withIdentifier: vcID) else { return }
        
        // Pass location data if needed
        if sender.tag == 1, let loc = viewModel.location {
            (seeAllVC as? CategoryVC)?.latitude = String(loc.latitude)
            (seeAllVC as? CategoryVC)?.longitude = String(loc.longitude)
        } else {
            (seeAllVC as? SubCategoryVC)?.viewModel.check = 3
        }
        navigationController?.pushViewController(seeAllVC, animated: true)
    }

    // Sets different heights for each section
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return tableView.frame.size.width / 2  // Banners - half width
        case 1: return (viewModel.category.count <= 2) ? 210 : 352 // Categories - dynamic height
        case 2: return 192  // Products - fixed height
        case 3: return 305  // Spacer - fixed height
        default: return 100 // Fallback
        }
    }
}

// MARK: - Google Places Delegate
extension HomeVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // User selected a place - update our location
        let coord = place.coordinate
        viewModel.updateLocation(coord)
        dismiss(animated: true)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        dismiss(animated: true)
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true) // User cancelled place selection
    }
}

// MARK: - Location Manager Delegate
extension HomeVC: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            manager.requestLocation()
        case .denied, .restricted:
            LocationPermissionManager.shared.showLocationSettingsAlert(from: self)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Got new location - update UI and stop to save battery
        guard let loc = locations.last else { return }
        viewModel.updateLocation(loc.coordinate)
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       // Location error
    }
}
