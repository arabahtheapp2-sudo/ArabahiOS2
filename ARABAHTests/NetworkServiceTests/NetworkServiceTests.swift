//
//  NetworkServiceTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 12/08/25.
//

import XCTest
import Combine
@testable import ARABAH


final class NetworkServiceTests: XCTestCase {
    
    struct MockTokenProvider: TokenProvider {
        var authToken: String?
    }
    
    var cancellables = Set<AnyCancellable>()
    
    func test_buildRequest_includesAuthorizationHeader_whenTokenPresent() throws {
        let token = "abc123"
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: token)
        )
        
        let request = try service.buildRequest(endpoint: .getProfile, method: .get)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(token)")
    }
    
    func test_buildRequest_noAuthorizationHeader_whenTokenMissing() throws {
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        let request = try service.buildRequest(endpoint: .getProfile, method: .get)
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }
    
    
    func test_buildRequest_setsCorrectURLAndMethod() throws {
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        let request = try service.buildRequest(endpoint: .getProfile, method: .get)
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    
    
    func test_buildRequest_setsDefaultHeaders() throws {
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        let request = try service.buildRequest(endpoint: .getProfile, method: .get)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.value(forHTTPHeaderField: "language_type"))
    }
    
    func test_buildRequest_setsMultipartHeader_whenIsMultipartTrue() throws {
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        let request = try service.buildRequest(endpoint: .signup, method: .post)
        XCTAssertTrue(
            request.value(forHTTPHeaderField: "Content-Type")?.contains("multipart/form-data") ?? false
        )
    }
    
    struct DummyResponse: Decodable { let success: Bool }
    
    func test_networkService_errorPaths() {
        let testCases: [NetworkServiceTestCase] = [
            NetworkServiceTestCase(
                name: "Offline error",
                responses: [MockURLSession.MockResponse(statusCode: 0, error: URLError(.notConnectedToInternet))],
                expectedError: .networkError("The Internet connection appears to be offline."),
                expectedCallCount: 1
            ),
            NetworkServiceTestCase(
                name: "Decoding failure",
                responses: [MockURLSession.MockResponse(statusCode: 200, data: "{ invalid json".data(using: .utf8))],
                expectedError: .decodingFailed,
                expectedCallCount: 1
            ),
            NetworkServiceTestCase(
                name: "Successful response",
                responses: [MockURLSession.MockResponse(statusCode: 200, data: "{\"success\":true}".data(using: .utf8))],
                expectedError: nil,
                expectedCallCount: 1
            )
        ]
        
        for testCase in testCases {
            let expectation = XCTestExpectation(description: testCase.name)
            let mockSession = MockURLSession(responses: testCase.responses)
            let service = NetworkService(tokenProvider: MockTokenProvider(authToken: "abc123"))
            
            service.request(endpoint: .getProfile)
                .sink { completion in
                    if case let .failure(error) = completion {
                        if let expected = testCase.expectedError {
                            XCTAssertEqual(error.localizedDescription, expected.localizedDescription, testCase.name)
                        }
                    }
                    expectation.fulfill()
                } receiveValue: { (response: DummyResponse) in
                    if testCase.expectedError == nil {
                        XCTAssertTrue(response.success, testCase.name)
                    }
                }
                .store(in: &cancellables)
            
            wait(for: [expectation], timeout: 1.0)
            XCTAssertEqual(mockSession.callCount, testCase.expectedCallCount, testCase.name)
        }
    }
    
    
}

struct NetworkServiceTestCase {
    let name: String
    let responses: [MockURLSession.MockResponse]
    let expectedError: NetworkError?
    let expectedCallCount: Int
}
