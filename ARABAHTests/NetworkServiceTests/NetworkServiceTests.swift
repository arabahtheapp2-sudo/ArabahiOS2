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
    
    func test_buildRequest_includesAuthorizationHeader_whenTokenPresent() throws {
        // Given
        let token = "abc123"
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: token)
        )
        
        // When
        let request = try service.buildRequest(
            endpoint: .getProfile,
            method: .get
        )
        
        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(token)")
    }
    
    func test_buildRequest_noAuthorizationHeader_whenTokenMissing() throws {
        // Given
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        // When
        let request = try service.buildRequest(
            endpoint: .getProfile,
            method: .get
        )
        
        // Then
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    
    func test_buildRequest_setsCorrectURLAndMethod() throws {
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        let request = try service.buildRequest(
            endpoint: .getProfile,
            method: .get
        )
        
        XCTAssertEqual(request.httpMethod, "GET")
    }

    
    
    func test_buildRequest_setsDefaultHeaders() throws {
        // Given
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        // When
        let request = try service.buildRequest(
            endpoint: .getProfile,
            method: .get
        )
        
        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.value(forHTTPHeaderField: "language_type"))
    }
    
    func test_buildRequest_setsMultipartHeader_whenIsMultipartTrue() throws {
        // Given
        let service = NetworkService(
            configuration: .default,
            tokenProvider: MockTokenProvider(authToken: nil)
        )
        
        // When
        let request = try service.buildRequest(
            endpoint: .signup, // signup isMultipart = true
            method: .post
        )
        
        // Then
        XCTAssertTrue(
            request.value(forHTTPHeaderField: "Content-Type")?.contains("multipart/form-data") ?? false
        )
    }
}
