//
//  ProductServices.swift
//  ARABAH
//
//  Created by cqlm2 on 23/06/25.
//

import Foundation
import Combine

/// Protocol defining all product-related network operations
protocol ProductServicesProtocol {
    
    /// Fetches the user's favorite products list
    func getProductfavList() -> AnyPublisher<LikeProductModal, NetworkError>
    
    /// Toggles like/dislike status for a product
    /// - Parameter productID: The ID of the product to like/dislike
    func likeDislikeAPI(productID: String) -> AnyPublisher<LikeModal, NetworkError>
    
    /// Fetches rating list for a specific product
    /// - Parameter productId: The ID of the product to get ratings for
    func raitingListAPI(productId: String) -> AnyPublisher<GetRaitingModal, NetworkError>
    
    /// Creates a new rating for a product
    /// - Parameters:
    ///   - productId: The ID of the product being rated
    ///   - rating: The rating value (0-5)
    ///   - review: The text review
    func createRatingAPI(productId: String, rating: Double, review: String) -> AnyPublisher<AddCommentModal, NetworkError>
    
    /// Fetches products belonging to a subcategory
    /// - Parameter cateogyID: The ID of the subcategory
    func subCatProduct(cateogyID: String) -> AnyPublisher<SubCatProductModal, NetworkError>
    
    /// Fetches the latest products
    func getLatestProductAPI() -> AnyPublisher<LatestProModal, NetworkError>
    
    /// Fetches products similar to the specified product
    /// - Parameter id: The ID of the product to find similar items for
    func getSimilarProductAPI(id: String) -> AnyPublisher<SimilarProductModal, NetworkError>
    
    /// Adds a product to the shopping list
    /// - Parameter productID: The ID of the product to add
    func addShoppingAPI(productID: String) -> AnyPublisher<AddShoppingModal, NetworkError>
    
    /// Reports a product
    /// - Parameters:
    ///   - productID: The ID of the product being reported
    ///   - message: The reason for reporting
    func reportAPI(productID: String, message: String) -> AnyPublisher<ReportModal, NetworkError>
}

/// Service class handling all product-related network operations
final class ProductServices: ProductServicesProtocol {
    
    /// Network service used for performing API requests.
    private let networkService: NetworkServiceProtocol
    
    /// Initializes the service with a network dependency.
    /// - Parameter networkService: The network service to use (defaults to shared instance)
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Favorite Products
    
    func getProductfavList() -> AnyPublisher<LikeProductModal, NetworkError> {
        return networkService.request(
            endpoint: .productLikeList,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func likeDislikeAPI(productID: String) -> AnyPublisher<LikeModal, NetworkError> {
        let parameters = ["ProductID": productID]
        return networkService.request(
            endpoint: .productLike,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    // MARK: - Ratings
    
    func raitingListAPI(productId: String) -> AnyPublisher<GetRaitingModal, NetworkError> {
        let parameters = ["productId": productId]
        return networkService.request(
            endpoint: .ratingList,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func createRatingAPI(productId: String, rating: Double, review: String) -> AnyPublisher<AddCommentModal, NetworkError> {
        let parameters = [
            "ProductID": productId,
            "rating": rating,
            "review": review
        ] as [String: Any]
        
        return networkService.request(
            endpoint: .createRating,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    // MARK: - Product Listing
    
    func subCatProduct(cateogyID: String) -> AnyPublisher<SubCatProductModal, NetworkError> {
        let parameters = ["categoryId": cateogyID]
        return networkService.request(
            endpoint: .subCategoryProduct,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func getLatestProductAPI() -> AnyPublisher<LatestProModal, NetworkError> {
        return networkService.request(
            endpoint: .latestProduct,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func getSimilarProductAPI(id: String) -> AnyPublisher<SimilarProductModal, NetworkError> {
        let parameters = ["id": id]
        return networkService.request(
            endpoint: .similarProducts,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    // MARK: - Shopping List
    
    func addShoppingAPI(productID: String) -> AnyPublisher<AddShoppingModal, NetworkError> {
        let parameters = ["productId": productID]
        return networkService.request(
            endpoint: .addtoShoppinglist,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    // MARK: - Reporting
    
    func reportAPI(productID: String, message: String) -> AnyPublisher<ReportModal, NetworkError> {
        let parameters = [
            "ProductID": productID,
            "message": message
        ]
        
        return networkService.request(
            endpoint: .reportCreate,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
}
