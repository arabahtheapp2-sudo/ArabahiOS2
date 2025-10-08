//
//  CategoryViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for fetching and managing category data.
final class CategoryViewModel {

    // MARK: - Input & Output

    /// Input structure for category API requests.
    struct Input {
        let latitude: String
        let longitude: String
    }


    // MARK: - Properties

    /// The fetched category data.
    @Published private(set) var categoryBody: [Categorys]? = []

    /// The current loading or result state.
    @Published private(set) var state: AppState<CategoryListModal> = .idle

    /// Indicates whether the fetched category list is empty.
    @Published private(set) var isEmpty: Bool = false

    /// Current latitude used for API call.
    var latitude: String = ""

    /// Current longitude used for API call.
    var longitude: String = ""

    /// Combine cancellables for memory management.
    private var cancellables = Set<AnyCancellable>()

    /// Network service used to fetch categories.
    private let networkService: HomeServicesProtocol
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization

    /// Initializes the view model with a network service.
    /// - Parameter networkService: Service conforming to `HomeServicesProtocol`. Defaults to `HomeServices()`.
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }

    // MARK: - Public Methods

    /// Fetches categories from the backend using the current latitude and longitude.
    func fetchCategories() {
        state = .loading
        retryCount = 0
        networkService.fetchCategories(latitude: latitude, longitude: longitude)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Handle error during API response
                if case .failure(let error) = completion {
                    self?.state = .failure(error)
                }
            } receiveValue: { [weak self] (response: CategoryListModal) in
                // Handle successful response and update state
                guard let contentBody = response.body?.category else {
                    self?.state = .failure(.invalidResponse)
                    return
                }
                self?.categoryBody = contentBody
                self?.isEmpty = contentBody.isEmpty
                self?.state = .success(response)
            }
            .store(in: &cancellables)
    }

    /// Retries the category fetch operation.
    func retry() {
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        fetchCategories()
    }

    /// Returns the category model for a given index.
    /// - Parameter index: Index of the desired category.
    /// - Returns: The `Categorys` object at the specified index, or `nil` if out of bounds.
    func categoryCell(for index: Int) -> Categorys? {
        return categoryBody?[safe: index]
    }

    /// Returns the total number of category items.
    var numberOfItems: Int {
        return categoryBody?.count ?? 0
    }
}
