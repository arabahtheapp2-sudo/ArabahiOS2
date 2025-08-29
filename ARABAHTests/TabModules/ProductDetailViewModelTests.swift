//
//  ProductDetailViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ProductDetailViewModelTests: XCTestCase {
    
    var viewModel: ProductDetailViewModel!
    var mockService: MockProductInfoService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockProductInfoService()
        viewModel = ProductDetailViewModel(networkServices: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Product Detail Success

    func testProductDetailSuccess() {
        let expectation = XCTestExpectation(description: "Product detail fetched successfully")
        
        let dummyModal = ProductDetailModal(success: true, code: 200, message: "Success", body: nil)

        mockService.productDetailAPIPublisher = Just(dummyModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$productDetailState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.productDetailAPI(id: "123")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.modal?.averageRating, 4.0)
        XCTAssertEqual(viewModel.modal?.ratingCount, 10)
    }

    // MARK: - Product Detail Failure

    func testProductDetailFailure() {
        let expectation = XCTestExpectation(description: "Product detail fetch failed")

        mockService.productDetailAPIPublisher = Fail(error: NetworkError.invalidResponse)
            .eraseToAnyPublisher()

        viewModel.$productDetailState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .invalidResponse)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.productDetailAPI(id: "123")
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Like API Success

    func testLikeSuccess() {
        let expectation = XCTestExpectation(description: "Like API success")

        let dummyModal = LikeModal(success: true, code: 200, message: "Liked", body: nil)
        mockService.likeDislikeAPIPublisher = Just(dummyModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$likeState
            .dropFirst()
            .sink { state in
                if case .success(let status) = state {
                    XCTAssertEqual(status, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.likeDislikeAPI(productID: "product_1")
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Notify API Failure

    func testNotifyFailure() {
        let expectation = XCTestExpectation(description: "Notify API failure")

        mockService.notifyMeAPIPublisher = Fail(error: NetworkError.networkError("Failed"))
            .eraseToAnyPublisher()

        viewModel.$notifyState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.notifyMeAPI(notifyStatus: 1)
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Add To Shopping Success

    func testAddToShopSuccess() {
        let expectation = XCTestExpectation(description: "Add to shop success")

        let dummyResponse = AddShoppingModal(success: true, code: 200, message: "Added", body: nil)
        mockService.addToShoppingAPIPublisher = Just(dummyResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$addToShopState
            .dropFirst()
            .sink { state in
                if case .success(let message) = state {
                    XCTAssertEqual(message, "Added")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.addToShopAPI(productID: "product_1")
        wait(for: [expectation], timeout: 1.0)
    }

    func testQRDetailSuccess() {
        let expectation = XCTestExpectation(description: "QR product detail fetched successfully")

        let dummyModal = ProductDetailModal(success: true, code: 200, message: "Success", body: nil)

        mockService.productDetailByQrCodePublisher = Just(dummyModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$QRDetailState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.productDetailAPIByQrCode(id: "qr123")
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.modal?.offerCount, 2)
    }

    func testQRDetailFailure() {
        let expectation = XCTestExpectation(description: "QR product detail failed")

        mockService.productDetailByQrCodePublisher = Fail(error: NetworkError.invalidResponse)
            .eraseToAnyPublisher()

        viewModel.$QRDetailState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .invalidResponse)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.productDetailAPIByQrCode(id: "qr123")
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Retry Tests

    func testRetryProductDetailAPI() {
        let expectation = XCTestExpectation(description: "Retry product detail API")

        let dummyModal = ProductDetailModal(success: true, code: 200, message: "Success", body: nil)

        mockService.productDetailAPIPublisher = Just(dummyModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.productDetailAPI(id: "retry123")

        viewModel.$productDetailState
            .dropFirst(2)
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.retryProductDetailAPI()
        wait(for: [expectation], timeout: 1.0)
    }
}
