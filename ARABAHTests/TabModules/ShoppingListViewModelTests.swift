//
//  ShoppingListViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class ShoppingListViewModelTests: XCTestCase {

    private var viewModel: ShoppingListViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = ShoppingListViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testShoppingListDeleteAPISuccess() {
        let deleteModal = ShoppinglistDeleteModal(success: true, code: 200, message: "Deleted", body: nil)
        mockService.shoppingListDeleteAPIPublisher = Just(deleteModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Delete API call succeeds")

        viewModel.$listDeleteState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListDeleteAPI(id: "123")

        wait(for: [expectation], timeout: 1.0)
    }

    func testShoppingListDeleteAPIFailure() {
        mockService.shoppingListDeleteAPIPublisher = Fail(error: .serverError(message: "Delete Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Delete API call fails")

        viewModel.$listDeleteState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Delete Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListDeleteAPI(id: "456")

        wait(for: [expectation], timeout: 1.0)
    }

    func testRetryListDeleteAPI() {
        let deleteModal = ShoppinglistDeleteModal(success: true, code: 200, message: "Deleted", body: nil)
        mockService.shoppingListDeleteAPIPublisher = Just(deleteModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Retry Delete API call succeeds")

        viewModel.$listDeleteState
            .dropFirst(2)
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListDeleteAPI(id: "789")
        viewModel.retryListDeleteAPI()

        wait(for: [expectation], timeout: 1.0)
    }

    func testShoppingListClearAllAPISuccess() {
        let clearModal = CommentModal(productID: "", comment: "", userID: "", deleted: false, id: "", createdAt: "", updatedAt: "")
        mockService.shoppingListClearAllAPIPublisher = Just(clearModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Clear All API call succeeds")

        viewModel.$listClearState
            .dropFirst()
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListClearAllAPI()

        wait(for: [expectation], timeout: 1.0)
    }

    func testShoppingListClearAllAPIFailure() {
        mockService.shoppingListClearAllAPIPublisher = Fail(error: .serverError(message: "Clear Failed"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Clear All API call fails")

        viewModel.$listClearState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Clear Failed"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListClearAllAPI()

        wait(for: [expectation], timeout: 1.0)
    }

    func testRetryShoppingListClearAllAPI() {
        let clearModal = CommentModal(productID: "", comment: "", userID: "", deleted: false, id: "", createdAt: "", updatedAt: "")
        mockService.shoppingListClearAllAPIPublisher = Just(clearModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Retry Clear All API call succeeds")

        viewModel.$listClearState
            .dropFirst(2)
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListClearAllAPI()
        viewModel.retryShoppingListClearAllAPI()

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testShoppingListAPISuccessWithCleaning() {
        
        let response = GetShoppingListModal(success: true, code: 200, message: "Fetched", body: nil)

        mockService.shoppingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "ShoppingList API success and cleaning")
        
        viewModel.$getListState
            .dropFirst()
            .sink { state in
                if case .success(let value) = state {
                    XCTAssertEqual(value.shoppingList?.count, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListAPI()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.totalPrice, [10.0])
    }

    func testShoppingListAPIFailure() {
        mockService.shoppingListAPIPublisher = Fail(error: .invalidEncoding)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "ShoppingList API failure")

        viewModel.$getListState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .invalidEncoding)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListAPI()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRetryShoppingListAPICallsAPI() {
        let response = GetShoppingListModal(success: true, code: 200, message: "Fetched", body: nil)
        mockService.shoppingListAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Retry ShoppingList API success")

        viewModel.$getListState
            .dropFirst(2) // .loading and then .success
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.shoppingListAPI()
        viewModel.retryShoppingListAPI()

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteProductInvalidIndexReturnsNil() {
        let id = viewModel.deleteProduct(at: 5)
        XCTAssertNil(id)
    }
    
    func testListDeleteStateTransitions() {
        let deleteModal = ShoppinglistDeleteModal(success: true, code: 200, message: "Deleted", body: nil)
        mockService.shoppingListDeleteAPIPublisher = Just(deleteModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var states: [AppState<ShoppinglistDeleteModal>] = []
        let expectation = expectation(description: "Delete state transitions")
        expectation.expectedFulfillmentCount = 2 // loading → success

        viewModel.$listDeleteState
            .dropFirst()
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.shoppingListDeleteAPI(id: "test")

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(states.first, .loading)
        XCTAssertTrue(states.contains { if case .success = $0 { return true } else { return false } })
    }




}
