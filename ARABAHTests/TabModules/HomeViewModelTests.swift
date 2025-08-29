//
//  HomeViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//


import XCTest
import Combine
import CoreLocation
@testable import ARABAH

final class HomeViewModelTests: XCTestCase {
    
    private var viewModel: HomeViewModel!
    private var mockService: MockHomeService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockHomeService()
        viewModel = HomeViewModel(homeServices: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Success Response
    
    func testFetchHomeDataSuccess() {
        // Given
       
        let modal = HomeModal(success: true, code: 200, message: "Success", body: nil)
        
        mockService.homeListAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Home data success")
        
        // When
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.fetchHomeData(longitude: "77.1", latitude: "28.6")
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.banner.count, 1)
        XCTAssertEqual(viewModel.category.count, 1)
        XCTAssertEqual(viewModel.latProduct.count, 1)
    }
    
    // MARK: - Test Failure Response
    
    func testStateTransitionsFromIdleToLoadingToSuccess() {
        // Given
        let modal = HomeModal(success: true, code: 200, message: "OK", body: nil)

        mockService.homeListAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var receivedStates: [AppState<HomeModal>] = []
        let expectation = self.expectation(description: "State transitions")
        expectation.expectedFulfillmentCount = 2

        viewModel.$state
            .dropFirst()
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchHomeData(longitude: "77.1", latitude: "28.6")

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(receivedStates[0], .loading)
        XCTAssertEqual(receivedStates[1], .success(modal))
    }

    
    // MARK: - Test Retry
    
    func testStateTransitionsFromIdleToLoadingToFailure() {
        // Given
        mockService.homeListAPIPublisher = Fail(error: NetworkError.invalidResponse)
            .eraseToAnyPublisher()

        var states: [AppState<HomeModal>] = []
        let expectation = self.expectation(description: "State failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                states.append(state)
                if case .failure = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchHomeData(longitude: "77.1", latitude: "28.6")

        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(states.first, .loading)
        XCTAssertEqual(states.last, .failure(.invalidResponse))
    }

    
    func testFetchHomeDataNilBodyShouldSetInvalidResponseFailure() {
        // Given
        let modal = HomeModal(success: true, code: 200, message: "Success", body: nil)

        mockService.homeListAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Expect failure due to nil body")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .invalidResponse)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.fetchHomeData(longitude: "77.1", latitude: "28.6")

        // Then
        wait(for: [expectation], timeout: 2)
    }

    
    func testUpdateLocationUpdatesStoredCoordinates() {
        let mockLocation = CLLocationCoordinate2D(latitude: 19.0, longitude: 73.0)

        let modal = HomeModal(success: true, code: 200, message: "OK", body: nil)
        mockService.homeListAPIPublisher = Just(modal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Location + fetch")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.updateLocation(mockLocation)

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.location?.latitude, 19.0)
        XCTAssertEqual(viewModel.location?.longitude, 73.0)
    }

    
    func testReverseGeocodingFailureDoesNotCrash() {
        // Invalid coordinates that can't be geocoded
        let invalidCoord = CLLocationCoordinate2D(latitude: 999.0, longitude: 999.0)

        // Not testing `currentCity` update here, just ensuring no crash
        viewModel.updateLocation(invalidCoord)

        // Delay to allow geocoder to attempt (though it should fail)
        let expectation = self.expectation(description: "Wait for geocode fail")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
        // Ensure app didn't crash, even if address was not updated
        XCTAssertNotNil(viewModel.location)
    }

    
    
    func testRetryAPIWithNoStoredParamsDoesNothing() {
        // Should not crash or emit anything
        viewModel.retryHomeAPI()
        
        // No expectations. Just asserting it doesn't crash.
        XCTAssertTrue(viewModel.banner.isEmpty)
        XCTAssertTrue(viewModel.category.isEmpty)
        XCTAssertTrue(viewModel.latProduct.isEmpty)
    }

    
    // MARK: - Test Update Location

    func testUpdateLocationTriggersFetch() {
        // Given
        
        let successModal = HomeModal(success: true, code: 200, message: "OK", body: nil)
        
        mockService.homeListAPIPublisher = Just(successModal)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Location triggers fetch")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        let location = CLLocationCoordinate2D(latitude: 28.6, longitude: 77.1)
        viewModel.updateLocation(location)
        
        // Then
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(viewModel.location?.latitude, 28.6)
        XCTAssertEqual(viewModel.location?.longitude, 77.1)
    }
}

