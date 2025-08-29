//
//  HomeServices.swift
//  ARABAH
//
//  Created by cqlm2 on 23/06/25.
//

import Foundation
import Combine

/// Protocol defining all home-related API services
protocol HomeServicesProtocol {
    
    /// Fetches home list data based on location and optional category filters
    func homeListAPI(longitude: String, latitude: String, categoryID: String, categoryName: String) -> AnyPublisher<HomeModal, NetworkError>
    
    /// Retrieves user's notification list
    func getNotificationList() -> AnyPublisher<GetNotificationModal, NetworkError>
    
    /// Deletes all notifications for the current user
    func notificationDeleteAPI() -> AnyPublisher<NewCommonString, NetworkError>
    
    /// Fetches filter data based on location
    func fetchFilterDataAPI(longitude: String, latitude: String) -> AnyPublisher<FilterGetDataModal, NetworkError>
    
    /// Performs a search operation with the given name
    func performSearch(name: String) -> AnyPublisher<CreateModal, NetworkError>
    
    /// Fetches search results with optional filters
    func fetchSearchResults(searchQuery: String, longitude: String, latitude: String) -> AnyPublisher<CategorySearchModal, NetworkError>
    
    /// Retrieves recent search history
    func recentSearchAPI() -> AnyPublisher<RecentSearchModal, NetworkError>
    
    /// Deletes a specific search history item
    func historyDeleteAPI(with id: String) -> AnyPublisher<SearchHistoryDeleteModal, NetworkError>
    
    /// Fetches categories list based on location
    func fetchCategories(latitude: String, longitude: String) -> AnyPublisher<CategoryListModal, NetworkError>
    
    /// Retrieves offers and deals
    func getOfferDealsAPI() -> AnyPublisher<GetOfferDealsModal, NetworkError>
    
    /// Gets user's shopping list
    func shoppingListAPI() -> AnyPublisher<GetShoppingListModal, NetworkError>
    
    /// Deletes an item from shopping list
    func shoppingListDeleteAPI(id: String) -> AnyPublisher<shoppinglistDeleteModal, NetworkError>
    
    /// Clears all items from shopping list
    func shoppingListClearAllAPI() -> AnyPublisher<CommentModal, NetworkError>
}

/// Service class implementing home-related API calls
final class HomeServices: HomeServicesProtocol {
    
    // MARK: - Properties
    
    /// Network service used for performing API requests
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Initialization
    
    /// Initializes the service with a network dependency
    /// - Parameter networkService: Network service to use (defaults to shared instance)
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - API Methods
    
    func homeListAPI(longitude: String, latitude: String, categoryID: String, categoryName: String) -> AnyPublisher<HomeModal, NetworkError> {
        var parameters = ["longitude": longitude, "latitude": latitude]
        
        // Add category ID to parameters if provided
        if categoryID != "" {
            parameters["categoryId"] = categoryID
        }
        
        // Add category name to parameters if provided
        if categoryName != "" {
            parameters["categoryName"] = categoryName
        }
        
        return networkService.request(
            endpoint: .home,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func fetchFilterDataAPI(longitude: String, latitude: String) -> AnyPublisher<FilterGetDataModal, NetworkError> {
        let parameters = ["longitude": longitude, "latitude": latitude]
        return networkService.request(
            endpoint: .applyFilters,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func fetchSearchResults(searchQuery: String, longitude: String, latitude: String) -> AnyPublisher<CategorySearchModal, NetworkError> {
        var param = ["searchTerm": searchQuery, "longitude": longitude, "latitude": latitude]
        var params = "?searchTerm=\(searchQuery)&longitude=\(longitude)&latitude=\(latitude)"

        // Add brand filters if available
        if let brand = Store.fitlerBrand, !brand.isEmpty {
            let brandId = brand.joined(separator: ",")
            params += "&brandId=\(brandId)"
            param["brandId"] = brandId
        }

        // Add store filters if available
        if let store = Store.filterStore, !store.isEmpty {
            let storeId = store.joined(separator: ",")
            params += "&storeId=\(storeId)"
            param["storeId"] = storeId
        }

        // Add category filters if available
        if let categoryFilter = Store.filterdata, !categoryFilter.isEmpty {
            let categoryId = categoryFilter.joined(separator: ",")
            params += "&categoryId=\(categoryId)"
            param["categoryId"] = categoryId
        }

        return networkService.request(
            endpoint: .searchFilter,
            method: .post,
            parameters: param,
            urlAppendData: params,
            headers: nil
        )
    }
    
    func getNotificationList() -> AnyPublisher<GetNotificationModal, NetworkError> {
        return networkService.request(
            endpoint: .getnotification,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func notificationDeleteAPI() -> AnyPublisher<NewCommonString, NetworkError> {
        return networkService.request(
            endpoint: .deleteNotifiction,
            method: .post,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func performSearch(name: String) -> AnyPublisher<CreateModal, NetworkError> {
        let parameters = ["name": name]
        return networkService.request(
            endpoint: .createSearch,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func recentSearchAPI() -> AnyPublisher<RecentSearchModal, NetworkError> {
        return networkService.request(
            endpoint: .searchList,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func historyDeleteAPI(with id: String) -> AnyPublisher<SearchHistoryDeleteModal, NetworkError> {
        let parameters = ["id": id]
        return networkService.request(
            endpoint: .searchDelete,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func fetchCategories(latitude: String, longitude: String) -> AnyPublisher<CategoryListModal, NetworkError> {
        let parameters = ["latitude": latitude, "longitude": longitude]
        return networkService.request(
            endpoint: .categoryFilter,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func getOfferDealsAPI() -> AnyPublisher<GetOfferDealsModal, NetworkError> {
        return networkService.request(
            endpoint: .dealListing,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func shoppingListAPI() -> AnyPublisher<GetShoppingListModal, NetworkError> {
        return networkService.request(
            endpoint: .shoppingList,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func shoppingListDeleteAPI(id: String) -> AnyPublisher<shoppinglistDeleteModal, NetworkError> {
        let parameters = ["id": id]
        return networkService.request(
            endpoint: .shoppingProductDelete,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func shoppingListClearAllAPI() -> AnyPublisher<CommentModal, NetworkError> {
        return networkService.request(
            endpoint: .shoppingListClear,
            method: .post,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
}
