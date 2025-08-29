//
//  SearchCatViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for handling the search feature, including recent searches,
/// search results, and history deletion, in the ARABAH app.
final class SearchCatViewModel {

    // MARK: - Published Properties
    
    /// Holds the current state of the view model.
    
    @Published private(set) var createSearchState: AppState<CreateModal> = .idle
    @Published private(set) var searchCatState: AppState<CategorySearchModal> = .idle
    @Published private(set) var recentSearchState: AppState<RecentSearchModal> = .idle
    @Published private(set) var historyDelState: AppState<SearchHistoryDeleteModal> = .idle
    
    /// List of search results from the create API.
    @Published private(set) var createModalBody: [CreateModalBody]? = []
    
    /// List of categories fetched from the search API.
    @Published private(set) var category: [Categorys]? = []
    
    /// List of products fetched from the search API.
    @Published private(set) var product: [Producted]? = []
    
    /// List of recent searches.
    @Published private(set) var recentModel: [RecentSearchModalBody]? = []
    
    // MARK: - Private Properties
    
    private var searchQuery = ""
    private var latitude = ""
    private var longitude = ""
    private var deleteHistoryID: String?
    private var cancellables = Set<AnyCancellable>()
    private let networkService: HomeServicesProtocol
    private var createSearchRetryCount = 0
    private var recentSearchRetryCount = 0
    private var historyDelRetryCount = 0
    private var searchCatRetryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with an optional custom network service.
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Updates the current search query.
    func updateSearchQuery(_ text: String) {
        searchQuery = text
    }
    
    /// Updates the current location with latitude and longitude.
    func updateLocation(lat: String, long: String) {
        latitude = lat
        longitude = long
    }
    
    /// Initiates the search by calling the create search API.
    func performSearch(isRetry: Bool) {
        guard !searchQuery.isEmpty else {
            clearCategory()
            return
        }
        
        if isRetry {
            guard createSearchRetryCount < maxRetryCount else {
                createSearchState = .validationError(.validationError(RegexMessages.retryMaxCount))
                return
            }
            createSearchRetryCount += 1
        } else {
            createSearchRetryCount = 0
        }
        
        
        createSearchState = .loading
        let name = searchQuery
        networkService.performSearch(name: name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.createSearchState = .failure(error)
                }
            } receiveValue: { [weak self] (response: CreateModal) in
                guard let contentBody = response.body else {
                    self?.createSearchState = .failure(.invalidResponse)
                    return
                }
                self?.createSearchState = .success(response)
                self?.createModalBody = contentBody
                self?.fetchSearchResults(isRetry: isRetry)
            }
            .store(in: &cancellables)
    }

    /// Fetches the search results (products and categories) based on the current query and location.
    func fetchSearchResults(isRetry: Bool) {
        
        if isRetry {
            guard searchCatRetryCount < maxRetryCount else {
                searchCatState = .validationError(.validationError(RegexMessages.retryMaxCount))
                return
            }
            searchCatRetryCount += 1
        } else {
            searchCatRetryCount = 0
        }
        
        searchCatState = .loading
        
        networkService.fetchSearchResults(searchQuery: searchQuery, longitude: longitude, latitude: latitude)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.searchCatState = .failure(error)
                }
            } receiveValue: { [weak self] (response: CategorySearchModal) in
                guard let contentBody = response.body else {
                    self?.searchCatState = .failure(.invalidResponse)
                    return
                }
                self?.product = contentBody.products ?? []
                self?.category = contentBody.category ?? []
                self?.searchCatState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Calls the recent search API to get the list of recent search items.
    func recentSearchAPI(isRetry: Bool) {
        
        if isRetry {
            guard recentSearchRetryCount < maxRetryCount else {
                recentSearchState = .validationError(.validationError(RegexMessages.retryMaxCount))
                return
            }
            recentSearchRetryCount += 1
        } else {
            recentSearchRetryCount = 0
        }
        
        recentSearchState = .loading
        networkService.recentSearchAPI()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.recentSearchState = .failure(error)
                }
            } receiveValue: { [weak self] (response: RecentSearchModal) in
                guard let contentBody = response.body else {
                    self?.recentSearchState = .failure(.invalidResponse)
                    return
                }
                self?.recentModel = contentBody
                self?.recentSearchState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Deletes a specific recent search history entry using its ID.
    func historyDeleteAPI(with id: String) {
        historyDelRetryCount = 0
        historyDelState = .loading
        deleteHistoryID = id
        networkService.historyDeleteAPI(with: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.historyDelState = .failure(error)
                }
            } receiveValue: { [weak self] (response: SearchHistoryDeleteModal) in
                self?.historyDelState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the delete API if it previously failed and a delete ID is available.
    func retryDeleteHistory() {
        
        
        guard historyDelRetryCount < maxRetryCount else {
            historyDelState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        historyDelRetryCount += 1
    
        guard let id = self.deleteHistoryID else { return }
        self.historyDeleteAPI(with: id)
    }
    
    /// Clears the current category list. Useful when the search query is empty.
    func clearCategory() {
        category?.removeAll()
    }
    
    /// Formats the lowest product price for display with currency.
    /// - Parameter product: The product data from which to extract and format price.
    /// - Returns: Formatted price string with currency symbol.
    func formattedPrice(for product: Producted) -> String {
        let data = product.product ?? []
        let newproduct = data.sorted { ($0.price ?? 0) < ($1.price ?? 0) }
        let lowestPrice = newproduct.first?.price ?? 0
        let val = (lowestPrice == 0) ? "0" : (lowestPrice.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", lowestPrice) : String(format: "%.2f", lowestPrice))
        return "₰" + val
    }
}
