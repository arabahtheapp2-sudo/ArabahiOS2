//
//  NetworkServiceProtocol.swift
//  ARABAH
//
//  Created by cqlm2 on 11/06/25.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: RequestParameters?,
        urlAppendData: urlAppendData?,
        headers: [String: String]?
    ) -> AnyPublisher<T, NetworkError>
}
