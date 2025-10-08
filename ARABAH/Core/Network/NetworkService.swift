//
//  NetworkService.swift
//  ARABAH
//
//  Created by cqlm2 on 11/06/25.
//

import Foundation
import Combine
import UIKit

/// Centralized network service handling all API requests
final class NetworkService: NetworkServiceProtocol {
    static let  shared = NetworkService()
    private let session: URLSession
    private let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    private let tokenProvider: TokenProvider
    
     init(configuration: URLSessionConfiguration = .default, tokenProvider: TokenProvider = Store.shared) {
        session = URLSession(configuration: configuration)
        self.tokenProvider = tokenProvider
    }
    
    // MARK: - Request Builder
    
    func buildRequest(
        endpoint: APIEndpoint,
        method: HTTPMethod,
        parameters: RequestParameters? = nil,
        urlAppendData: UrlAppendData? = nil,
        headers: [String: String]? = nil
    ) throws -> URLRequest {
        var urlString = endpoint.baseURL + endpoint.path
        
        // Handle GET parameters
        if method == .get, let params = parameters {
            urlString += buildURLWithQuery(parameters: params)
        }
        
        if let idApend = urlAppendData {
            urlString += "/\(idApend)"
        }
        
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 300
        )
        request.httpMethod = method.rawValue
        
        // Set common headers
        var allHeaders = defaultHeaders(isMultipart: endpoint.isMultipart)
        headers?.forEach { allHeaders[$0.key] = $0.value }
        allHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Set request body for non-GET methods
        if method != .get, let parameters = parameters {
            if endpoint.isMultipart {
                request.httpBody = buildMultipartBody(parameters: parameters)
            } else {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            }
        }
        
        return request
    }
    
    // MARK: - Helpers
    
    private func defaultHeaders(isMultipart: Bool) -> [String: String] {
        var headers = [
            "Accept": "application/json",
            "language_type": Store.isArabicLang ? "ar" : "en",
            "Content-Type": isMultipart
                        ? "multipart/form-data; boundary=\(boundary)"
                        : "application/json"
        ]
        
        
        if let secretKey = Bundle.main.object(forInfoDictionaryKey: "SecretKey") as? String, !secretKey.isEmpty {
            headers["secret_key"] = secretKey
        }
        
        if let publishKey = Bundle.main.object(forInfoDictionaryKey: "PublishKey") as? String, !publishKey.isEmpty {
            headers["publish_key"] = publishKey
        }
        
        if let authToken = tokenProvider.authToken, !authToken.isEmpty {
            headers["Authorization"] = "Bearer \(authToken)"
        }
      
        
        return headers
    }
    
    private func buildURLWithQuery(parameters: [String: Any]) -> String {
        var urlString = ""
        let queryString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        if !parameters.isEmpty {
            urlString += "?" + queryString
        }
        
        return urlString
    }
    
    private func buildMultipartBody(parameters: RequestParameters) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            if let imageInfo = value as? ImageData {
                appendImageData(&body, key: key, imageInfo: imageInfo)
            } else if let images = value as? [ImageData] {
                images.forEach { appendImageData(&body, key: key, imageInfo: $0) }
            } else {
                appendFormField(&body, key: key, value: "\(value)")
            }
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func appendFormField(_ body: inout Data, key: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }
    
    private func appendImageData(_ body: inout Data, key: String, imageInfo: ImageData) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(imageInfo.fileName)\"\r\n")
        body.append("Content-Type: \(imageInfo.mimeType)\r\n\r\n")
        body.append(imageInfo.data)
        body.append("\r\n")
    }
    
    // MARK: - Request Execution
    
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: RequestParameters? = nil,
        urlAppendData: UrlAppendData? = nil,
        headers: [String: String]? = nil
    ) -> AnyPublisher<T, NetworkError> {
        
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(.sessionExpired))
                return
            }
            
            guard Reachability.isConnectedToNetwork() else {
                promise(.failure(.noInternetConnection))
                return
            }
            
            let request: URLRequest
            do {
                request = try self.buildRequest(
                    endpoint: endpoint,
                    method: method,
                    parameters: parameters,
                    urlAppendData: urlAppendData,
                    headers: headers
                )
            } catch {
                promise(.failure(error as? NetworkError ?? .requestBuildFailed))
                return
            }
            
            self.executeRequest(request, promise: promise)
            
        }.eraseToAnyPublisher()
    }

    
    private func executeRequest<T: Decodable>(
        _ request: URLRequest,
        promise: @escaping (Result<T, NetworkError>) -> Void
    ) {
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let error = error {
                    promise(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    promise(.failure(.invalidResponse))
                    return
                }
                
                guard let data = data else {
                    promise(.failure(.noData))
                    return
                }
                
                self.handleHTTPResponse(httpResponse, data: data, promise: promise)
            }
        }.resume()
    }

    
    private func handleHTTPResponse<T: Decodable>(
        _ response: HTTPURLResponse,
        data: Data,
        promise: @escaping (Result<T, NetworkError>) -> Void
    ) {
        switch response.statusCode {
        case 200...299:
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                promise(.success(decoded))
            } catch {
                promise(.failure(.decodingFailed))
            }
        case 401:
            handleUnauthorized()
            promise(.failure(.unauthorized))
        case 403:
            promise(.failure(.forbidden))
        case 400:
            let message = parseErrorMessage(from: data)
            promise(.failure(.badRequest(message: message)))
        default:
            let message = parseErrorMessage(from: data)
            promise(.failure(.serverError(message: message)))
        }
    }

    
    
    private func parseErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json["message"] as? String ?? json["msg"] as? String
    }
    
    private func parseErrorCode(from data: Data) -> Int? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json["code"] as? Int
    }
    
    
    private func handleUnauthorized() {
        DispatchQueue.main.async {
            // Clear user session
            Store.shared.clearSession()
            // Navigate to login
           guard let loginVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            else { return }
            let navController = UINavigationController(rootViewController: loginVC)
            navController.isNavigationBarHidden = true
            UIApplication.setRootViewController(navController)
        }
    }
    
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

typealias RequestParameters = [String: Any]
typealias UrlAppendData = Any

struct ImageData {
    let data: Data
    let fileName: String
    let mimeType: String
    let fieldName: String
    
    init?(image: UIImage, fieldName: String, compressionQuality: CGFloat = 0.8) {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else { return nil }
        self.data = data
        self.fileName = "\(Date().timeIntervalSince1970).jpg"
        self.mimeType = "image/jpeg"
        self.fieldName = fieldName
    }
}

enum NetworkError: Error, Equatable {
    case invalidURL
    case requestBuildFailed
    case noInternetConnection
    case invalidResponse
    case noData
    case decodingFailed
    case unauthorized
    case forbidden
    case badRequest(message: String?)
    case serverError(message: String?)
    case networkError(String)
    case validationError(String)
    case sessionExpired
    case invalidEncoding
    
    var localizedDescription: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection"
        case .unauthorized:
            return "Session expired. Please login again."
        case .forbidden:
            return "Access forbidden"
        case .badRequest(let message):
            return message ?? "Invalid request"
        case .serverError(let message):
            return message ?? "Server error occurred"
        case .decodingFailed:
            return "Failed to parse response"
        case .networkError(let message):
            return message
        case .validationError(let message):
            return message
        case .invalidEncoding:
            return "Invalid Encoding"
        default:
            return "Network error occurred"
        }
    }
}
