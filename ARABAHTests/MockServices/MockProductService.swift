//
//  MockProductService.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import Foundation
import Combine
import UIKit
@testable import ARABAH


final class MockProductService: ProductServicesProtocol {
    
    var getProductfavListPublisher: AnyPublisher<LikeProductModal, NetworkError>?
    func getProductfavList() -> AnyPublisher<ARABAH.LikeProductModal, ARABAH.NetworkError> {
        return getProductfavListPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var likeDislikeAPIPublisher: AnyPublisher<LikeModal, NetworkError>?
    func likeDislikeAPI(productID: String) -> AnyPublisher<ARABAH.LikeModal, ARABAH.NetworkError> {
        return likeDislikeAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var raitingListAPIPublisher: AnyPublisher<GetRaitingModal, NetworkError>?
    func raitingListAPI(productId: String) -> AnyPublisher<ARABAH.GetRaitingModal, ARABAH.NetworkError> {
        return raitingListAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var createRatingAPIPublisher: AnyPublisher<AddCommentModal, NetworkError>?
    func createRatingAPI(productId: String, rating: Double, review: String) -> AnyPublisher<ARABAH.AddCommentModal, ARABAH.NetworkError> {
        return createRatingAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var subCatProductPublisher: AnyPublisher<SubCatProductModal, NetworkError>?
    func subCatProduct(cateogyID: String) -> AnyPublisher<ARABAH.SubCatProductModal, ARABAH.NetworkError> {
        return subCatProductPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var getLatestProductAPIPublisher: AnyPublisher<LatestProModal, NetworkError>?
    func getLatestProductAPI() -> AnyPublisher<ARABAH.LatestProModal, ARABAH.NetworkError> {
        return getLatestProductAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var getSimilarProductAPIPublisher: AnyPublisher<SimilarProductModal, NetworkError>?
    func getSimilarProductAPI(id: String) -> AnyPublisher<ARABAH.SimilarProductModal, ARABAH.NetworkError> {
        return getSimilarProductAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var addShoppingAPIPublisher: AnyPublisher<AddShoppingModal, NetworkError>?
    func addShoppingAPI(productID: String) -> AnyPublisher<ARABAH.AddShoppingModal, ARABAH.NetworkError> {
        return addShoppingAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var reportAPIPublisher: AnyPublisher<ReportModal, NetworkError>?
    func reportAPI(productID: String, message: String) -> AnyPublisher<ARABAH.ReportModal, ARABAH.NetworkError> {
        return reportAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
}
