//
//  FavViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//


import XCTest
import Combine
@testable import ARABAH

final class FavViewModelTests: XCTestCase {

    private var viewModel: FavViewModel!
    private var mockService: MockProductService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockProductService()
        viewModel = FavViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func testGetProductfavListSuccessWithNonEmptyData() {
        // Arrange
        
        let response = LikeProductModal(success: true, code: 200, message: "Fetched", body: [])
        
        mockService.getProductfavListPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = expectation(description: "Fetch Fav List with data")
        
        viewModel.$likeListState
            .dropFirst()
            .sink { state in
                if case .success(let modal) = state, modal.message == "Fetched" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.getProductfavList()
        
        // Assert
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(viewModel.likedBody?.count, 1)
        XCTAssertEqual(viewModel.likedBody?.first?.productID?.name, "Sample Product")
        XCTAssertFalse(viewModel.showNoDataMessage)
    }

    func testLikeDislikeStateTransitions_loadingToSuccess() {
        // Arrange
        let likeModal = LikeModal(success: true, code: 200, message: "Liked", body: nil)
        let response = LikeProductModal(success: true, code: 200, message: "Fetched", body: [])

        mockService.likeDislikeAPIPublisher = Just(likeModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        mockService.getProductfavListPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "States: loading → success")
        expectation.expectedFulfillmentCount = 2

        var states: [AppState<LikeModal>] = []

        viewModel.$likeDislikeState
            .dropFirst()
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        viewModel.likeDislikeAPI(productID: "123")

        // Assert
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(states[0], .loading)
        XCTAssertEqual(states[1], .success(likeModal))
    }
    
    func testGetProductfavList_nilBody_shouldSetFailureAndClearData() {
        // Arrange
        let response = LikeProductModal(success: true, code: 200, message: "Nil Body", body: nil)

        mockService.getProductfavListPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Should hit failure on nil body")

        viewModel.$likeListState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state, error == .invalidResponse {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.getProductfavList()

        // Assert
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.likedBody?.isEmpty ?? false)
        XCTAssertTrue(viewModel.showNoDataMessage)
    }

    func testLikeListFailure_shouldClearBodyAndShowNoData() {
        // Arrange
        
        viewModel.showNoDataMessage = false

        mockService.getProductfavListPublisher = Fail(error: .networkError("Offline"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "Fail should reset data and show no data message")

        viewModel.$likeListState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .networkError("Offline"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.getProductfavList()

        // Assert
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(viewModel.likedBody?.isEmpty ?? false)
        XCTAssertTrue(viewModel.showNoDataMessage)
    }

    
    func testLikeDislikeFailure_shouldEmitFailureState() {
        // Arrange
        mockService.likeDislikeAPIPublisher = Fail(error: NetworkError.serverError(message: "Server down"))
            .eraseToAnyPublisher()

        let expectation = expectation(description: "LikeDislike emits failure")

        viewModel.$likeDislikeState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Server down"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.likeDislikeAPI(productID: "999")

        // Assert
        wait(for: [expectation], timeout: 1)
    }


}

