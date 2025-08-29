//
//  RatingListViewModel.swift
//  ARABAH
//
//  ViewModel for managing product ratings and reviews data
//

import UIKit
import Combine

/// Handles fetching and displaying product ratings and reviews
final class RatingListViewModel {
    
    // MARK: - Published Outputs
    
    /// Current state of the ViewModel (observed by the view)
    @Published private(set) var state: AppState<GetRaitingModal> = .idle
    
    /// Contains all rating data including average and count
    @Published private(set) var ratingBody: GetRaitingModalBody?
    
    /// Array of individual ratings/reviews
    @Published private(set) var ratingList: [Ratinglist] = []
    
    /// Formatted average rating (e.g. "4.5")
    @Published private(set) var averageRatingText: String = "0.0"
    
    /// Formatted total reviews count (e.g. "12 Ratings")
    @Published private(set) var totalReviewsText: String = "0 Ratings"
    
    /// Flag to determine if "no data" message should be shown
    @Published private(set) var showNoDataMessage: Bool = false
    
    // MARK: - Private Properties
    
    /// Stores Combine subscriptions to manage memory
    private var cancellables = Set<AnyCancellable>()
    
    /// Service handling product-related network requests
    private let networkService: ProductServicesProtocol
    private var previousInput: String?
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Creates a new RatingListViewModel
    /// - Parameter networkService: The service to use for network calls (defaults to ProductServices)
    init(networkService: ProductServicesProtocol = ProductServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Fetches rating data for a specific product
    /// - Parameter productId: The ID of the product to get ratings for
    func raitingListAPI(productId: String) {
        // Set loading state before making the request
        previousInput = productId
        state = .loading
        retryCount = 0
        networkService.raitingListAPI(productId: productId)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            
            // Handle request failure
            if case .failure(let error) = completion {
                self.state = .failure(error)
                
                // Reset all data to default/empty state
                self.ratingBody = nil
                self.ratingList = []
                self.averageRatingText = "0.0"
                self.totalReviewsText = "0 Ratings"
                self.showNoDataMessage = true
            }
        } receiveValue: { [weak self] (response: GetRaitingModal) in
            guard let self = self else { return }
            
            // Validate we received proper response data
            guard let body = response.body else {
                self.state = .failure(.invalidResponse)
                self.showNoDataMessage = true
                return
            }
            
            // Update all published properties with new data
            self.ratingBody = body
            self.ratingList = body.ratinglist ?? []
            self.averageRatingText = "\(body.averageRating ?? 0.0)"
            self.totalReviewsText = "\(body.ratingCount ?? 0) \(PlaceHolderTitleRegex.ratings)"
            
            // Show no data message if rating list is empty
            self.showNoDataMessage = (body.ratinglist?.isEmpty ?? true)
            
            // Mark operation as successful
            self.state = .success(response)
        }
        .store(in: &cancellables)
    }
    
    func retryRatingListAPI() {
        
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        if let input = previousInput {
            state = .idle
            self.raitingListAPI(productId: input)
        }
    }
}
