//
//  DealsViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 03/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling the Deals-related data fetching and processing logic.
final class DealsViewModel {
    
    // MARK: - Properties
    
    /// Holds the list of fetched deals from the API.
    @Published private(set) var dealsBody: [GetOfferDealsModalBody]? = []
    
    /// Publishes the current state of the API operation to update the UI reactively.
    @Published private(set) var state: AppState<GetOfferDealsModal> = .idle

    /// Used to store Combine subscriptions for lifecycle management.
    private var cancellables = Set<AnyCancellable>()
    
    /// Network service responsible for executing API calls.
    private let networkService: HomeServicesProtocol
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a network service.
    /// - Parameter networkService: Dependency injected network service conforming to `HomeServicesProtocol`.
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Fetches offer deals from the backend API.
    /// Updates the `state` to loading during the fetch,
    /// and to success/failure based on the result.
    func getOfferDealsAPI() {
        state = .loading
        retryCount = 0
        networkService.getOfferDealsAPI()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle errors by updating the state to `.failure`
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: GetOfferDealsModal) in
                // If response body is nil, treat as failure
                guard let contentBody = response.body else {
                    self?.state = .failure(.invalidResponse)
                    return
                }
                // Update data and state on successful response
                self?.dealsBody = contentBody
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }
    
    func retryGetOfferDealsAPI() {
        
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        self.getOfferDealsAPI()
    }
    
    
    /// Returns whether the deals data is empty.
    var isDataEmpty: Bool {
        return dealsBody?.isEmpty ?? true
    }
    
    /// Returns a formatted string for a given deal index, including store name and description.
    /// - Parameter index: Index of the deal in the `dealsBody` array.
    /// - Returns: A user-friendly string with placeholders and actual data.
    func formattedDealText(at index: Int) -> String {
        guard let deal = dealsBody?[safe: index] else { return "" }
        let storeName = deal.storeID?.name ?? ""
        let dealDescription = deal.decription ?? ""
        return "\(PlaceHolderTitleRegex.storeName) \(storeName)\n\(PlaceHolderTitleRegex.deal) \(dealDescription)"
    }

    /// Returns the full deal image URL for a given deal index.
    /// - Parameter index: Index of the deal in the `dealsBody` array.
    /// - Returns: Full image URL as a `String`.
    func dealImageUrl(at index: Int) -> String {
        guard let deal = dealsBody?[safe: index], let image = deal.image else { return "" }
        return (AppConstants.imageURL) + (image)
    }
    
    /// Returns the full store image URL for a given deal index.
    /// - Parameter index: Index of the deal in the `dealsBody` array.
    /// - Returns: Full image URL as a `String`.
    func storeImageUrl(at index: Int) -> String {
        guard let deal = dealsBody?[safe: index], let storeImage = deal.storeID?.image else { return "" }
        return (AppConstants.imageURL) + (storeImage)
    }
    
    /// Determines whether a given image URL points to a PDF.
    /// - Parameter urlString: The URL string to check.
    /// - Returns: `true` if the URL ends with `.pdf`, `false` otherwise.
    func isPDF(_ urlString: String) -> Bool {
        return urlString.lowercased().hasSuffix(".pdf")
    }
}
