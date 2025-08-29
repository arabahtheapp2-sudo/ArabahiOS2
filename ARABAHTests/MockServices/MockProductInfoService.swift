//
//  MockProductInfoService.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import Foundation
import Combine
import UIKit
@testable import ARABAH

final class MockProductInfoService: ProductInfoServicesProtocol {
    
    var productDetailAPIPublisher: AnyPublisher<ProductDetailModal, NetworkError>?
    func productDetailAPI(id: String) -> AnyPublisher<ARABAH.ProductDetailModal, ARABAH.NetworkError> {
        return productDetailAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var productDetailByQrCodePublisher: AnyPublisher<ProductDetailModal, NetworkError>?
    func productDetailByQrCode(id: String) -> AnyPublisher<ARABAH.ProductDetailModal, ARABAH.NetworkError> {
        return productDetailByQrCodePublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var notifyMeAPIPublisher: AnyPublisher<LoginModal, NetworkError>?
    func notifyMeAPI(notifyStatus: Int) -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return notifyMeAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var likeDislikeAPIPublisher: AnyPublisher<LikeModal, NetworkError>?
    func likeDislikeAPI(productID: String) -> AnyPublisher<ARABAH.LikeModal, ARABAH.NetworkError> {
        return likeDislikeAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var addToShoppingAPIPublisher: AnyPublisher<AddShoppingModal, NetworkError>?
    func addToShoppingAPI(productID: String) -> AnyPublisher<ARABAH.AddShoppingModal, ARABAH.NetworkError> {
        return addToShoppingAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
}
