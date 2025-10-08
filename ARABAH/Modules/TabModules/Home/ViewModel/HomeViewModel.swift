//
//  HomeViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import Foundation
import Combine
import CoreLocation

/// Handles all the business logic for the home screen including:
/// - Location management
/// - Data fetching from network
/// - State management
/// - Error handling
final class HomeViewModel: NSObject, ObservableObject {

    
    // These properties automatically notify views when they change
    @Published private(set) var state: AppState<HomeModal> = .idle
    @Published private(set) var banner: [Banner] = []       // Banner ads data
    @Published private(set) var category: [Categorys] = []  // Product categories
    @Published private(set) var latProduct: [LatestProduct] = []  // Latest products
    @Published private(set) var currentCity: String = ""    // User's current city
    @Published private(set) var currentCountry: String = "" // User's current country
    @Published private(set) var location: CLLocationCoordinate2D?  // User's coordinates
    
    // Private properties for internal use
    private var cancellables = Set<AnyCancellable>()  // Stores network requests
    private let homeServices: HomeServicesProtocol    // Handles API calls
    struct RetryParams {
        let longitude: String
        let latitude: String
        let categoryID: String?
        let categoryName: String?
    }
    private var retryParams: RetryParams?
    // Stores last request params for retries
    
    private let geocoder = CLGeocoder()  // Converts coordinates to addresses
    private var retryCount = 0
    private var maxRetryCount = 3
    // Initialize with either a mock service (for testing) or real service
    init(homeServices: HomeServicesProtocol = HomeServices()) {
        self.homeServices = homeServices
        super.init()
    }
    
    // MARK: - Main Data Fetching
    
    /// Gets all home screen data including banners, categories and products
    /// - Parameters:
    ///   - longitude: User's current longitude
    ///   - latitude: User's current latitude
    ///   - categoryID: Optional category filter
    ///   - categoryName: Optional category name for display
    func fetchHomeData(longitude: String, latitude: String, categoryID: String? = nil, categoryName: String? = nil) {
        // Update state and save params in case we need to retry
        state = .loading
        retryCount = 0
        retryParams = RetryParams(longitude: longitude, latitude: latitude, categoryID: categoryID, categoryName: categoryName)
        
        // Make the API call
        homeServices.homeListAPI(
            longitude: longitude,
            latitude: latitude,
            categoryID: categoryID ?? "",
            categoryName: categoryName ?? ""
        )
        .receive(on: DispatchQueue.main)  // Ensure we update UI on main thread
        .sink { [weak self] completion in
            // Handle errors
            if case .failure(let error) = completion {
                self?.state = .failure(error)
            }
        } receiveValue: { [weak self] response in
            // Validate and store the response data
            guard let self = self, let contentBody = response.body else {
                self?.state = .failure(.invalidResponse)
                return
            }
            
            // Update our published properties
            self.banner = contentBody.banner ?? []
            self.category = contentBody.category ?? []
            self.latProduct = contentBody.latestProduct ?? []
            self.state = .success(response)
        }
        .store(in: &cancellables)  // Keep the request alive
    }

    /// Retries the last failed request using stored parameters
    func retryHomeAPI() {
        
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        
        guard let params = retryParams else { return }
        fetchHomeData(
            longitude: params.longitude,
            latitude: params.latitude,
            categoryID: params.categoryID,
            categoryName: params.categoryName
        )
    }
    
    // MARK: - Location Handling
    
    /// Updates the user's location and triggers related updates
    /// - Parameter location: New coordinate received from location services
    func updateLocation(_ location: CLLocationCoordinate2D) {
        self.location = location
        let latString = String(location.latitude)
        let lngString = String(location.longitude)
        
        // Convert coordinates to human-readable address
        fetchAddressFromCoordinates(latitude: latString, longitude: lngString)
        
        // Refresh home data with new location
        fetchHomeData(longitude: lngString, latitude: latString)
    }
    
    /// Converts latitude/longitude to city/country names
    private func fetchAddressFromCoordinates(latitude: String, longitude: String) {
        // Safely convert strings to numbers
        guard let lat = Double(latitude), let lon = Double(longitude) else { return }
        
        let loc = CLLocation(latitude: lat, longitude: lon)
        // Use the device's preferred language for address formatting
        let locale = Locale(identifier: Locale.preferredLanguages.first ?? "en")
        
        // Perform reverse geocoding
        geocoder.reverseGeocodeLocation(loc, preferredLocale: locale) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if error != nil {
                // 🧭 Reverse geocode failed
                return
            }
            
            // Extract city and country from the first placemark
            guard let placemark = placemarks?.first else { return }

            // Update published properties
            self.currentCity = placemark.locality ?? ""
            self.currentCountry = placemark.country ?? ""
        }
    }
}
