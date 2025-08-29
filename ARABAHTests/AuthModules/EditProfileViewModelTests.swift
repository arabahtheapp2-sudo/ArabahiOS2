//
//  EditProfileViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class EditProfileViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Profile Update Tests
    
    func testCompleteProfileSuccess() {
        let mockService = MockAuthService()
        let expectedResponse = LoginModal(
            success: true,
            code: 200,
            message: "Success",
            body: nil
        )
        
        mockService.completeProfilePublisher = Just(expectedResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = EditProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Complete profile success")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let response) = state {
                    XCTAssertEqual(response.body?.token, expectedResponse.body?.token)
                    XCTAssertEqual(Store.userDetails?.body?.name, "Test User")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let testImage = UIImage(systemName: "person.circle")!
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCompleteProfileFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.badRequest(message: "Update failed")
        
        mockService.completeProfilePublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()
        
        let viewModel = EditProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Complete profile failure")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let testImage = UIImage(systemName: "person.circle")!
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Input Validation Tests
    
    func testValidateInputsSuccess() {
        let viewModel = EditProfileViewModel()
        let isValid = viewModel.validateInputs(name: "Valid Name", email: "valid@example.com")
        XCTAssertTrue(isValid)
    }
    
    func testValidateInputsEmptyName() {
        let viewModel = EditProfileViewModel()
        let expectation = XCTestExpectation(description: "Validation empty name")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.validationError(RegexMessages.emptyName).localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let isValid = viewModel.validateInputs(name: "", email: "valid@example.com")
        XCTAssertFalse(isValid)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testValidateInputsEmptyEmail() {
        let viewModel = EditProfileViewModel()
        let expectation = XCTestExpectation(description: "Validation empty email")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.validationError(RegexMessages.emptyEmail).localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let isValid = viewModel.validateInputs(name: "Valid Name", email: "")
        XCTAssertFalse(isValid)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testValidateInputsInvalidEmail() {
        let viewModel = EditProfileViewModel()
        let expectation = XCTestExpectation(description: "Validation invalid email")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .validationError(let error) = state {
                    XCTAssertEqual(error.localizedDescription, NetworkError.validationError(RegexMessages.invalidEmail).localizedDescription)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let isValid = viewModel.validateInputs(name: "Valid Name", email: "invalid-email")
        XCTAssertFalse(isValid)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Retry Mechanism Tests
    
    func testRetryEditProfile() {
        let mockService = MockAuthService()
        var callCount = 0
        
        mockService.completeProfilePublisher = Deferred {
            Future<LoginModal, NetworkError> { promise in
                callCount += 1
                if callCount == 1 {
                    promise(.failure(.badRequest(message: "First failure")))
                } else {
                    promise(.success(LoginModal(
                        success: true,
                        code: 200,
                        message: "Success",
                        body: nil
                    )))
                }
            }
        }.eraseToAnyPublisher()
        
        let viewModel = EditProfileViewModel(authServices: mockService)
        let expectation = XCTestExpectation(description: "Retry edit profile")
        expectation.expectedFulfillmentCount = 2
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .failure = state {
                    viewModel.retryEditProfile()
                    expectation.fulfill()
                } else if case .success = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let testImage = UIImage(systemName: "person.circle")!
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRecentInputsCaching() {
        let viewModel = EditProfileViewModel()
        let testImage = UIImage(systemName: "person.circle")!
        
        viewModel.completeProfleAPI(
            name: "Test User",
            email: "test@example.com",
            needImageUpdate: true,
            image: testImage
        )
        
        XCTAssertEqual(viewModel.recentInputs?.name, "Test User")
        XCTAssertEqual(viewModel.recentInputs?.email, "test@example.com")
        XCTAssertEqual(viewModel.recentInputs?.needImageUpdate, true)
        XCTAssertNotNil(viewModel.recentInputs?.image)
    }
    
    func testStateTransitionsOnSuccess() {
        let mockService = MockAuthService()
        
        let expectedResponse = LoginModal(
            success: true,
            code: 200,
            message: "Updated",
            body: nil
        )
        
        mockService.completeProfilePublisher = Just(expectedResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
        
        let viewModel = EditProfileViewModel(authServices: mockService)
        var stateChanges: [AppState<LoginModal>] = []
        let expectation = XCTestExpectation(description: "Expect idle → loading → success")
        expectation.expectedFulfillmentCount = 3

        viewModel.$state
            .sink { state in
                stateChanges.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.completeProfleAPI(
            name: "Test",
            email: "test@example.com",
            needImageUpdate: true,
            image: UIImage(systemName: "person")!
        )
        
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(stateChanges[0], .idle)
        XCTAssertEqual(stateChanges[1], .loading)
        XCTAssertEqual(stateChanges[2], .success(expectedResponse))
    }

    func testStateTransitionsOnFailure() {
        let mockService = MockAuthService()
        let expectedError = NetworkError.serverError(message: "Something went wrong")

        mockService.completeProfilePublisher = Fail(error: expectedError)
            .eraseToAnyPublisher()

        let viewModel = EditProfileViewModel(authServices: mockService)
        var stateChanges: [AppState<LoginModal>] = []
        let expectation = XCTestExpectation(description: "Expect idle → loading → failure")
        expectation.expectedFulfillmentCount = 3

        viewModel.$state
            .sink { state in
                stateChanges.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.completeProfleAPI(
            name: "Test",
            email: "test@example.com",
            needImageUpdate: true,
            image: UIImage(systemName: "person")!
        )

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(stateChanges[0], .idle)
        XCTAssertEqual(stateChanges[1], .loading)
        if case .failure(let err) = stateChanges[2] {
            XCTAssertEqual(err.localizedDescription, expectedError.localizedDescription)
        } else {
            XCTFail("Expected .failure state")
        }
    }

    func testStateRemainsIdleOnInvalidInput() {
        let viewModel = EditProfileViewModel()
        var states: [AppState<LoginModal>] = []
        let expectation = XCTestExpectation(description: "Validation blocks API call")
        expectation.expectedFulfillmentCount = 2

        viewModel.$state
            .sink { state in
                states.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.completeProfleAPI(
            name: "", // invalid
            email: "invalid",
            needImageUpdate: false,
            image: UIImage()
        )

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(states.first, .idle)
        XCTAssert(states.contains { state in
            if case .validationError = state {
                return true
            }
            return false
        })
    }

    
    
    
}
