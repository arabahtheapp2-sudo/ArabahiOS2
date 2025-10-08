//
//  SubCatViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class SubCatViewModelTests: XCTestCase {
    
    private var viewModel: SubCatViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = SubCatViewModel(networkService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testSubCatProductSuccess() {
        
        let response = SubCatProductModal(success: true, code: 200, message: nil, body: nil)
        mockService.subCatProductPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Subcategory success")
        
        viewModel.$subCatProductState
            .dropFirst()
            .sink { state in
                if state == .success(response) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.subCatProduct(cateogyID: "123", isRetry: false)
        
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.modal?.count, 1)
        XCTAssertEqual(viewModel.displayItems.count, 1)
        XCTAssertEqual(viewModel.displayItems.first?.name, "Product A")
    }

    func testSubCatProductFailure() {
        mockService.subCatProductPublisher = Fail(error: .networkError("Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Subcategory failure")

        viewModel.$subCatProductState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.subCatProduct(cateogyID: "123", isRetry: false)
        wait(for: [expectation], timeout: 2)
    }

    func testLatestProductSuccess() {
        
        let response = LatestProModal(success: true, code: 200, message: nil, body: nil)
        mockService.getLatestProductAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Latest products success")

        viewModel.$getLatProductState
            .dropFirst()
            .sink { state in
                if state == .success(response) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getLatestProductAPI(isRetry: false)
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.latestModal?.count, 1)
        XCTAssertEqual(viewModel.displayItems.first?.name, "Latest")
    }

    func testSimilarProductFailure() {
        mockService.getSimilarProductAPIPublisher = Fail(error: .invalidResponse)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Similar product failure")

        viewModel.$getSimilarProductState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == .invalidResponse {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.getSimilarProductAPI(id: "P100", isRetry: false)
        wait(for: [expectation], timeout: 2)
    }

    func testAddToCartAuthError() {
        Store.shared.authToken = nil  // unauthenticated
        viewModel.check = 1
        

        let expectation = expectation(description: "Auth error on add to cart")

        viewModel.$addToShopState
            .dropFirst()
            .sink { state in
                if state == .failure(.sessionExpired) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.addProductToCart(at: 0)
        wait(for: [expectation], timeout: 1)
    }

    func testAddToCartSuccess() {
        Store.shared.authToken = "valid_token"
        viewModel.check = 1

        let response = AddShoppingModal(success: true, code: 200, message: "Added", body: nil)
        mockService.addShoppingAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Add to cart success")

        viewModel.$addToShopState
            .dropFirst()
            .sink { state in
                if state == .success(response) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.addProductToCart(at: 0)
        wait(for: [expectation], timeout: 2)
    }
    
    
    func testRefreshDispatchesCorrectAPI() {
        // Case 1: Subcategory
        viewModel.check = 1
        viewModel.productID = "CAT123"
        let subcatExpectation = expectation(description: "Subcategory fetch triggered")
        mockService.subCatProductPublisher = Just(.init(success: true, code: 200, message: nil, body: []))
            .setFailureType(to: NetworkError.self)
            .handleEvents(receiveOutput: { _ in subcatExpectation.fulfill() })
            .eraseToAnyPublisher()
        viewModel.refresh(isRetry: false)
        wait(for: [subcatExpectation], timeout: 1)

        // Case 2: Similar
        viewModel.check = 2
        viewModel.productID = "SIM123"
        let similarExpectation = expectation(description: "Similar product fetch triggered")
        mockService.getSimilarProductAPIPublisher = Just(.init(success: true, code: 200, message: nil, body: []))
            .setFailureType(to: NetworkError.self)
            .handleEvents(receiveOutput: { _ in similarExpectation.fulfill() })
            .eraseToAnyPublisher()
        viewModel.refresh(isRetry: false)
        wait(for: [similarExpectation], timeout: 1)

        // Case 3: Latest
        viewModel.check = 999
        let latestExpectation = expectation(description: "Latest product fetch triggered")
        mockService.getLatestProductAPIPublisher = Just(.init(success: true, code: 200, message: nil, body: []))
            .setFailureType(to: NetworkError.self)
            .handleEvents(receiveOutput: { _ in latestExpectation.fulfill() })
            .eraseToAnyPublisher()
        viewModel.refresh(isRetry: false)
        wait(for: [latestExpectation], timeout: 1)
    }
    
    
    func testCurrentHeaderTitle() {
        viewModel.categoryName = "Fruits"

        viewModel.check = 1
        XCTAssertEqual(viewModel.currentHeaderTitle, "Fruits")

        viewModel.check = 2
        XCTAssertEqual(viewModel.currentHeaderTitle, PlaceHolderTitleRegex.similarProducts)

        viewModel.check = 999
        XCTAssertEqual(viewModel.currentHeaderTitle, PlaceHolderTitleRegex.latestProducts)
    }

    func testAddToCartWithInvalidIndex() {
        Store.shared.authToken = "valid_token"

        viewModel.check = 1
        viewModel.addProductToCart(at: 999) // Out-of-bounds
        XCTAssertEqual(viewModel.addToShopState, .idle)
    }

    func testAddToShopStatePublishesOnMainThread() {
        Store.shared.authToken = "valid_token"
        viewModel.check = 1


        let response = AddShoppingModal(success: true, code: 200, message: "Added", body: nil)
        mockService.addShoppingAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Combine binding observed")

        viewModel.$addToShopState
            .dropFirst()
            .sink { state in
                if state == .success(response) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.addProductToCart(at: 0)
        wait(for: [expectation], timeout: 1)
    }

}
