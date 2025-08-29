//
//  ProductInfoServices.swift
//  ARABAH
//
//  Created by cqlm2 on 25/06/25.
//

import Foundation
import Combine

/// Protocol defining the product information service methods
protocol ProductInfoServicesProtocol {
    
    /// Fetches product details by product ID
    /// - Parameter id: The product identifier
    /// - Returns: Publisher emitting ProductDetailModal or NetworkError
    func productDetailAPI(id: String) -> AnyPublisher<ProductDetailModal, NetworkError>
    
    /// Fetches product details by scanning a QR/barcode
    /// - Parameter id: The barcode/QR code identifier
    /// - Returns: Publisher emitting ProductDetailModal or NetworkError
    func productDetailByQrCode(id: String) -> AnyPublisher<ProductDetailModal, NetworkError>
    
    /// Updates notification preferences for the product
    /// - Parameter notifyStatus: The notification status to set
    /// - Returns: Publisher emitting LoginModal or NetworkError
    func notifyMeAPI(notifyStatus: Int) -> AnyPublisher<LoginModal, NetworkError>
    
    /// Handles like/dislike action for a product
    /// - Parameter productID: The product identifier
    /// - Returns: Publisher emitting LikeModal or NetworkError
    func likeDislikeAPI(productID: String) -> AnyPublisher<LikeModal, NetworkError>
    
    /// Adds product to shopping list
    /// - Parameter productID: The product identifier to add
    /// - Returns: Publisher emitting AddShoppingModal or NetworkError
    func addToShoppingAPI(productID: String) -> AnyPublisher<AddShoppingModal, NetworkError>
    
}

/// Service class handling product-related API calls
final class ProductInfoServices: ProductInfoServicesProtocol {
    
    /// Network service used for performing API requests.
    private let networkService: NetworkServiceProtocol
    
    /// Initializes the service with a network dependency. Defaults to a shared instance.
    /// - Parameter networkService: The network service to use for API calls
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - Product Detail Methods
    
    func productDetailAPI(id: String) -> AnyPublisher<ProductDetailModal, NetworkError> {
        let param = ["id": id]
        return networkService.request(
            endpoint: .productDetail,
            method: .get,
            parameters: param,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func productDetailByQrCode(id: String) -> AnyPublisher<ProductDetailModal, NetworkError> {
        let param = ["barcode": id]
        return networkService.request(
            endpoint: .barCodeDetail,
            method: .get,
            parameters: param,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    // MARK: - Product Interaction Methods
    
    func notifyMeAPI(notifyStatus: Int) -> AnyPublisher<LoginModal, NetworkError> {
        let param = ["Notifyme": notifyStatus]
        return networkService.request(
            endpoint: .notifyme,
            method: .put,
            parameters: param,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func likeDislikeAPI(productID: String) -> AnyPublisher<LikeModal, NetworkError> {
        let param = ["ProductID": productID]
        return networkService.request(
            endpoint: .productLike,
            method: .post,
            parameters: param,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func addToShoppingAPI(productID: String) -> AnyPublisher<AddShoppingModal, NetworkError> {
        let param = ["productId": productID]
        return networkService.request(
            endpoint: .addtoShoppinglist,
            method: .post,
            parameters: param,
            urlAppendData: nil,
            headers: nil
        )
    }
}
