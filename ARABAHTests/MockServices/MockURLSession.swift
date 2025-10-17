//
//  MockURLSession.swift
//  ARABAHTests
//
//  Created by cqlm2 on 17/10/25.
//

import XCTest
import Combine
@testable import ARABAH

// MARK: - Protocols for Mocking

protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

// Extend real URLSession/DataTask to conform
extension URLSession: URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        return (self.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// MARK: - Mock DataTask

class MockDataTask: URLSessionDataTaskProtocol {
    private let closure: () -> Void
    init(closure: @escaping () -> Void) { self.closure = closure }
    func resume() { closure() }
}

// MARK: - Mock URLSession

class MockURLSession: URLSessionProtocol {
    struct MockResponse {
        var statusCode: Int
        var data: Data? = nil
        var error: Error? = nil
    }

    private let responses: [MockResponse]
    private var currentIndex = 0
    var callCount = 0

    init(responses: [MockResponse]) { self.responses = responses }

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTaskProtocol {
        callCount += 1

        let response: MockResponse
        if currentIndex < responses.count {
            response = responses[currentIndex]
            currentIndex += 1
        } else {
            response = responses.last!
        }

        return MockDataTask {
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: response.statusCode,
                httpVersion: nil,
                headerFields: nil
            )
            completionHandler(response.data, httpResponse, response.error)
        }
    }
}
