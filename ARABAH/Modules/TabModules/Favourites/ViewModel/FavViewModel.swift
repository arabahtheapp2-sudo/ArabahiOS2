//
//  FavViewModel.swift
//  ARABAH
//
//  ViewModel handling favorite products logic and API interactions
//

import UIKit
import Combine

final class FavViewModel {
    
    // MARK: - Published Properties
    
    /// Current state of the ViewModel (observable by views)
    @Published private(set) var likeDislikeState: AppState<LikeModal> = .idle
    @Published private(set) var likeListState: AppState<LikeProductModal> = .idle
    
    /// Array of favorite products (observable by views)
    @Published private(set) var likedBody: [LikeProductModalBody]? = []
    
    /// Flag to show/hide "no data" message (observable by views)
    @Published var showNoDataMessage: Bool = false
    
    // MARK: - Private Properties
    
    /// Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Service handling product-related network calls
    private let networkService: ProductServicesProtocol
    private var retryCount = 0
    private var favRetryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with optional network service
    /// - Parameter networkService: Service conforming to ProductServicesProtocol (defaults to ProductServices)
    init(networkService: ProductServicesProtocol = ProductServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Handles like/dislike action for a product
    /// - Parameter productID: The ID of the product to like/dislike
    func likeDislikeAPI(productID: String) {
        // Set loading state before API call
        likeDislikeState = .loading
        favRetryCount = 0
        networkService.likeDislikeAPI(productID: productID)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API failure
            if case .failure(let error) = completion {
                self?.likeDislikeState = .failure(error)
            }
        } receiveValue: { [weak self] (response: LikeModal) in
            // Handle successful like/dislike
            self?.likeDislikeState = .success(response)
            
            // Refresh the favorites list to reflect changes
            self?.getProductfavList()
        }
        .store(in: &cancellables)
    }

    /// Fetches the current list of favorite products
    func getProductfavList() {
       
        retryCount = 0
        likeListState = .loading
        
        networkService.getProductfavList()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle API failure
                if case .failure(let error) = completion {
                    self?.likeListState = .failure(error)
                    
                    // Clear existing data and show no data message
                    self?.likedBody = []
                    self?.showNoDataMessage = true
                }
            } receiveValue: { [weak self] (response: LikeProductModal) in
                // Validate response contains body
                guard let contentBody = response.body else {
                    self?.likeListState = .failure(.invalidResponse)
                    self?.likedBody = []
                    self?.showNoDataMessage = true
                    return
                }
                
                // Update data and UI state
                self?.likedBody = contentBody
                self?.showNoDataMessage = contentBody.isEmpty
                self?.likeListState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    func retryGetProductfavList() {
        guard retryCount < maxRetryCount else {
            likeListState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        self.getProductfavList()
    }
}
