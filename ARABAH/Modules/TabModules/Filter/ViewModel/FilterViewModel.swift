import UIKit
import Combine

/// Manages filter data and selection state for categories, stores, and brands
final class FilterViewModel {
    
    // MARK: - Input / Output
    
    // Input parameters needed for fetching filter data
    struct Input {
        var longitude: String  // User's current longitude
        var latitude: String   // User's current latitude
    }
    
    // MARK: - Properties
    
    // Published state that views can observe
    @Published private(set) var state: AppState<FilterGetDataModal> = .idle
    
    // Filter data collections
    @Published private(set) var category: [Categorys]? = []  // Product categories
    @Published private(set) var storeData: [Stores]? = []    // Available stores
    @Published private(set) var brand: [Brand]? = []         // Product brands
    
    // Flags for empty state handling
    @Published var isEmpty: Bool = false
    
    // Currently selected filter IDs
    @Published var selectedCategoryIDs = [String]()  // Selected category IDs
    @Published var selectedStoreIDs = [String]()     // Selected store IDs
    @Published var selectedBrandIDs = [String]()     // Selected brand IDs
    
    // Private properties
    private var cancellables = Set<AnyCancellable>()  // Combine subscriptions
    private let networkService: HomeServicesProtocol  // Network service
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Creates a new FilterViewModel
    /// - Parameter networkService: Service for home-related network calls (defaults to HomeServices)
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Fetches filter data from the server
    /// - Parameter input: Contains location coordinates for filtering
    func fetchFilterDataAPI(with input: Input, isRetry: Bool = false) {
        if isRetry {
            guard retryCount < maxRetryCount else {
                state = .validationError(.validationError(RegexMessages.retryMaxCount))
                return
            }
            retryCount += 1
        } else {
            retryCount = 0
        }
        
        
        state = .loading  // Set loading state
        
        networkService.fetchFilterDataAPI(longitude: input.longitude, latitude: input.latitude)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API failure
            if case .failure(let error) = completion {
                self?.state = .failure(error)
            }
        } receiveValue: { [weak self] (response: FilterGetDataModal) in
            // Validate response contains data
            guard let contentBody = response.body else {
                self?.state = .failure(.invalidResponse)
                return
            }
            
            // Update data properties
            self?.category = contentBody.category ?? []
            self?.storeData = contentBody.store ?? []
            self?.brand = contentBody.brand ?? []
            
            // Check if all filter sections are empty
            let isAllEmpty = (self?.category?.isEmpty ?? true) &&
                            (self?.storeData?.isEmpty ?? true) &&
                            (self?.brand?.isEmpty ?? true)
            self?.isEmpty = isAllEmpty
            
            // Restore any previously saved selections
            self?.restoreStoredFilters()
            
            // Mark operation as successful
            self?.state = .success(response)
        }
        .store(in: &cancellables)
    }
    
    /// Toggles selection state for a filter item
    /// - Parameters:
    ///   - id: The ID of the item to toggle
    ///   - section: Which filter section (0: categories, 1: stores, 2: brands)
    func toggleSelection(id: String, section: Int) {
        switch section {
        case 0: toggle(&selectedCategoryIDs, id)  // Category selection
        case 1: toggle(&selectedStoreIDs, id)     // Store selection
        case 2: toggle(&selectedBrandIDs, id)     // Brand selection
        default: break
        }
    }
    
    // MARK: - Selection Management
    
    /// Helper method to toggle an item in a selection list
    private func toggle(_ list: inout [String], _ id: String) {
        if list.contains(id) {
            list.removeAll { $0 == id }  // Remove if already selected
        } else {
            list.append(id)  // Add if not selected
        }
    }
    
    /// Clears all current filter selections
    func clearSelections() {
        selectedCategoryIDs.removeAll()
        selectedStoreIDs.removeAll()
        selectedBrandIDs.removeAll()
        
        // Clear persisted selections
        Store.filterdata = nil
        Store.fitlerBrand = nil
        Store.filterStore = nil
    }
    
    /// Restores previously saved filter selections from persistent storage
    func restoreStoredFilters() {
        selectedCategoryIDs = Store.filterdata ?? []
        selectedStoreIDs = Store.filterStore ?? []
        selectedBrandIDs = Store.fitlerBrand ?? []
    }
    
    /// Saves current selections to persistent storage
    func saveSelections() {
        Store.fitlerBrand = selectedBrandIDs
        Store.filterStore = selectedStoreIDs
        Store.filterdata = selectedCategoryIDs
    }
    
    // MARK: - Formatting
    
    /// Creates a formatted string of all selected filters
    /// - Returns: String in format "Categories: id1,id2&Store Name: id3&Brand Name: id4"
    func getFormattedSelectedFilters() -> String {
        var selectedData: [String] = []
        
        // Add each non-empty filter section
        if !selectedCategoryIDs.isEmpty {
            selectedData.append("Categories: " + selectedCategoryIDs.joined(separator: ","))
        }
        if !selectedStoreIDs.isEmpty {
            selectedData.append("Store Name: " + selectedStoreIDs.joined(separator: ","))
        }
        if !selectedBrandIDs.isEmpty {
            selectedData.append("Brand Name: " + selectedBrandIDs.joined(separator: ","))
        }
        
        // Combine all sections with & separator
        return selectedData.joined(separator: "&")
    }
}
