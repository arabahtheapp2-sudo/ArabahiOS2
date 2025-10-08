//
//  MockHomeService.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import Foundation
import Combine
import UIKit
@testable import ARABAH


final class MockHomeService: HomeServicesProtocol {
    
    var homeListAPIPublisher: AnyPublisher<HomeModal, NetworkError>?
    func homeListAPI(longitude: String, latitude: String, categoryID: String, categoryName: String) -> AnyPublisher<ARABAH.HomeModal, ARABAH.NetworkError> {
        return homeListAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var getNotificationListPublisher: AnyPublisher<GetNotificationModal, NetworkError>?
    func getNotificationList() -> AnyPublisher<ARABAH.GetNotificationModal, ARABAH.NetworkError> {
        return getNotificationListPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var notificationDeleteAPIPublisher: AnyPublisher<NewCommonString, NetworkError>?
    func notificationDeleteAPI() -> AnyPublisher<ARABAH.NewCommonString, ARABAH.NetworkError> {
        return notificationDeleteAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var fetchFilterDataAPIPublisher: AnyPublisher<FilterGetDataModal, NetworkError>?
    func fetchFilterDataAPI(longitude: String, latitude: String) -> AnyPublisher<ARABAH.FilterGetDataModal, ARABAH.NetworkError> {
        return fetchFilterDataAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var performSearchPublisher: AnyPublisher<CreateModal, NetworkError>?
    func performSearch(name: String) -> AnyPublisher<ARABAH.CreateModal, ARABAH.NetworkError> {
        return performSearchPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var fetchSearchResultsPublisher: AnyPublisher<CategorySearchModal, NetworkError>?
    func fetchSearchResults(searchQuery: String, longitude: String, latitude: String) -> AnyPublisher<ARABAH.CategorySearchModal, ARABAH.NetworkError> {
        return fetchSearchResultsPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var recentSearchAPIPublisher: AnyPublisher<RecentSearchModal, NetworkError>?
    func recentSearchAPI() -> AnyPublisher<ARABAH.RecentSearchModal, ARABAH.NetworkError> {
        return recentSearchAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var historyDeleteAPIPublisher: AnyPublisher<SearchHistoryDeleteModal, NetworkError>?
    func historyDeleteAPI(with id: String) -> AnyPublisher<ARABAH.SearchHistoryDeleteModal, ARABAH.NetworkError> {
        return historyDeleteAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var fetchCategoriesPublisher: AnyPublisher<CategoryListModal, NetworkError>?
    func fetchCategories(latitude: String, longitude: String) -> AnyPublisher<ARABAH.CategoryListModal, ARABAH.NetworkError> {
        return fetchCategoriesPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var getOfferDealsAPIPublisher: AnyPublisher<GetOfferDealsModal, NetworkError>?
    func getOfferDealsAPI() -> AnyPublisher<ARABAH.GetOfferDealsModal, ARABAH.NetworkError> {
        return getOfferDealsAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var shoppingListAPIPublisher: AnyPublisher<GetShoppingListModal, NetworkError>?
    func shoppingListAPI() -> AnyPublisher<ARABAH.GetShoppingListModal, ARABAH.NetworkError> {
        return shoppingListAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var shoppingListDeleteAPIPublisher: AnyPublisher<ShoppinglistDeleteModal, NetworkError>?
    func shoppingListDeleteAPI(id: String) -> AnyPublisher<ARABAH.ShoppinglistDeleteModal, ARABAH.NetworkError> {
        return shoppingListDeleteAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var shoppingListClearAllAPIPublisher: AnyPublisher<CommentModal, NetworkError>?
    func shoppingListClearAllAPI() -> AnyPublisher<ARABAH.CommentModal, ARABAH.NetworkError> {
        return shoppingListClearAllAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
}
