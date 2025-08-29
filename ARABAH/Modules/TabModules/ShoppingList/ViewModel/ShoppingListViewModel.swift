//
//  ShoppingListViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel responsible for managing Shopping List related API calls and data handling.
/// Handles fetching, deleting, and clearing shopping lists, as well as maintaining local data state.
final class ShoppingListViewModel {
    
    // MARK: - Properties
    
    /// Published property that notifies subscribers of state changes
    @Published private(set) var getListState: AppState<GetShoppingListModalBody> = .idle
    @Published private(set) var listDeleteState: AppState<shoppinglistDeleteModal> = .idle
    @Published private(set) var listClearState: AppState<CommentModal> = .idle
    
    /// Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Network service instance for making API calls
    private let networkService: HomeServicesProtocol
    
    /// Temporary storage for ID of item being deleted
    private var deleteID: String?
    private var getListRetryCount = 0
    private var listDeleteRetryCount = 0
    private var listClearRetryCount = 0
    private let maxRetryCount = 3
    // MARK: - Data Storage
    
    /// Local storage for shopping list items
    private(set) var shoppingList: [ShoppingList] = []
    
    /// Flattened list of all products across all shopping lists
    private(set) var products: [Products] = []
    
    /// Summary information about shops in the shopping list
    private(set) var shopSummary: [ShopSummary] = []
    
    /// Array of prices for all products
    private(set) var totalPrice: [Double] = []
    
    /// Unique shop names from products
    private(set) var shopImages: [ShopName] = []
    
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a network service
    /// - Parameter networkService: The network service to use for API calls (defaults to HomeServices)
    init(networkService: HomeServicesProtocol = HomeServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Fetches the shopping list from the API
    func shoppingListAPI() {
        getListState = .loading
        getListRetryCount = 0
        networkService.shoppingListAPI()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.getListState = .failure(error)
                }
            } receiveValue: { [weak self] (response: GetShoppingListModal) in
                guard let self = self, var contentBody = response.body else {
                    self?.getListState = .failure(.invalidResponse)
                    return
                }
                self.processShoppingData(model: &contentBody)
                self.getListState = .success(contentBody)
            }
            .store(in: &cancellables)
    }
    
    /// Processes and cleans shopping data after API call
    private func processShoppingData(model: inout GetShoppingListModalBody) {
        cleanShoppingData(model: &model)
        prepareDataForDisplay()
    }
    
    /// Prepares all data needed for display in the view
    private func prepareDataForDisplay() {
        products = shoppingList.compactMap({ $0.productID?.product ?? [] }).flatMap { $0 }
        totalPrice = products.map { $0.price ?? 0.0 }
        shopImages = products.compactMap { $0.shopName }.removingDuplicates()
    }
    
    /// Gets the product name for a specific index
    func productName(at index: Int) -> String {
        guard index >= 0 && index < shoppingList.count else { return "" }
        return shoppingList[index].productID?.name ?? ""
    }
    
    /// Gets the products for a specific index
    func products(at index: Int) -> [Products] {
        guard index >= 0 && index < shoppingList.count else { return [] }
        return shoppingList[index].productID?.product ?? []
    }
    
    /// Gets the image URL for a product at specific index
    func productImage(at index: Int) -> String? {
        guard index >= 0 && index < shoppingList.count else { return nil }
        return shoppingList[index].productID?.image
    }
    
    /// Determines if the row is a header row
    func isHeaderRow(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == 0
    }
    
    /// Determines if the row is a footer row
    func isFooterRow(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == shoppingList.count + 1
    }
    
    /// Determines if the row is a product row
    func isProductRow(_ indexPath: IndexPath) -> Bool {
        return indexPath.row > 0 && indexPath.row <= shoppingList.count
    }
    
    /// Gets the product index from table index path
    func productIndex(from indexPath: IndexPath) -> Int {
        return indexPath.row - 1
    }
    
    /// Gets the total number of rows including header and footer
    func totalRows() -> Int {
        return shoppingList.count + 2
    }
    
    /// Checks if shopping list is empty
    var isEmpty: Bool {
        return shoppingList.isEmpty
    }
    
    
    /// Retries the shopping list API call after a failure
    func retryShoppingListAPI() {
        guard getListRetryCount < maxRetryCount else {
            getListState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        getListRetryCount += 1
        self.shoppingListAPI()
    }
    
    /// Deletes an item from the shopping list via API
    /// - Parameter id: The ID of the item to delete
    func shoppingListDeleteAPI(id: String) {
        listDeleteState = .loading
        listDeleteRetryCount = 0
        self.deleteID = id
        networkService.shoppingListDeleteAPI(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.listDeleteState = .failure(error)
                }
            } receiveValue: { [weak self] (response: shoppinglistDeleteModal) in
                self?.listDeleteState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the delete API call after a failure
    func retryListDeleteAPI() {
        guard listDeleteRetryCount < maxRetryCount else {
            listDeleteState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        listDeleteRetryCount += 1
        
        guard let id = self.deleteID else { return }
        self.shoppingListDeleteAPI(id: id)
    }
    
    /// Clears all items from the shopping list via API
    func shoppingListClearAllAPI() {
        listClearState = .loading
        listClearRetryCount = 0
        networkService.shoppingListClearAllAPI()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.listClearState = .failure(error)
                }
            } receiveValue: { [weak self] (response: CommentModal) in
                self?.listClearState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Retries the clear all API call after a failure
    func retryShoppingListClearAllAPI() {
        
        guard listClearRetryCount < maxRetryCount else {
            listClearState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        
        listClearRetryCount += 1
        
        self.shoppingListClearAllAPI()
    }
    
    // MARK: - Data Cleaning
    
    /// Cleans shopping data by removing shops with all zero-priced products
    /// - Parameter model: The shopping list model to clean (passed as inout to allow modification)
    func cleanShoppingData(model: inout GetShoppingListModalBody) {
        guard var shopSummary = model.shopSummary, var shoppingList = model.shoppingList else {
            self.shoppingList = []
            self.shopSummary = []
            return
        }
        
        var shopsToRemove = Set<String>()
        
        // Identify shops where all products have zero price
        for shop in shopSummary {
            guard let shopName = shop.shopName else { continue }
            let allPricesZero = shoppingList
                .compactMap { $0.productID?.product }
                .flatMap { $0 }
                .filter { $0.shopName?.name == shopName }
                .allSatisfy { ($0.price ?? 0) == 0 }
            
            if allPricesZero {
                shopsToRemove.insert(shopName)
            }
        }
        
        // Filter out products from shops to be removed
        shoppingList = shoppingList.compactMap { list -> ShoppingList? in
            guard var productID = list.productID else { return list }
            
            let filteredProducts = productID.product?.filter { product in
                guard let shopName = product.shopName?.name else { return true }
                return !shopsToRemove.contains(shopName)
            } ?? []
            
            if filteredProducts.isEmpty { return nil }
            
            productID.product = filteredProducts
            var updatedList = list
            updatedList.productID = productID
            return updatedList
        }
        
        // Remove empty shops from summary
        shopSummary = shopSummary.filter { shop in
            guard let shopName = shop.shopName else { return true }
            return !shopsToRemove.contains(shopName)
        }
        
        // Update local storage
        self.shoppingList = shoppingList
        self.shopSummary = shopSummary
    }
    
    // MARK: - Local Data Management
    
    /// Deletes a product from the local list and returns its ID
    /// - Parameter index: Index of the product to delete
    /// - Returns: The ID of the deleted product, or nil if index is invalid
    func deleteProduct(at index: Int) -> String? {
        guard index >= 0 && index < shoppingList.count else { return nil }
        let id = shoppingList[index].productID?.id
        shoppingList.remove(at: index)
        return id
    }
}
