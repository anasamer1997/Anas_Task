//
//  Network.swift
//  AnasTask
//
//  Created by Anas Amer on 27/01/1447 AH.
//

import Foundation
import Combine

// MARK: - Network Error Enumeration
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case parsingError
    case unknown(Error)
    case noInternetConnection
    case timeout
    case serverError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidResponse:
            return "Invalid response from server"
        case .statusCode(let code):
            return "Server returned status code \(code)"
        case .parsingError:
            return "Failed to parse response data"
        case .unknown(let error):
            return "Unknown error occurred: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection available"
        case .timeout:
            return "Request timed out"
        case .serverError(let message):
            return message
        }
    }
}

// MARK: - Request Protocol
protocol NetworkRequest {
    associatedtype Response: Decodable
    
    var endpoint: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
}

extension NetworkRequest {
    var method: HTTPMethod { .get }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
    var body: Data? { nil }
    var timeoutInterval: TimeInterval { 30.0 }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Network Client
// MARK: - Network Client
actor NetworkClient {
    private let session: URLSession
    private let baseURL: URL
    private let jsonDecoder: JSONDecoder
    
    init(baseURL: URL,
         session: URLSession = .shared,
         jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.jsonDecoder = jsonDecoder
        // Uncomment if you need snake case conversion
        // self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func execute<T: NetworkRequest>(_ request: T) async throws -> T.Response {
        // 1. Prepare URL Components
        guard var urlComponents = URLComponents(
            url: baseURL.appendingPathComponent(request.endpoint),
            resolvingAgainstBaseURL: true
        ) else {
            throw NetworkError.invalidURL
        }
        
        // 2. Add Query Parameters
        if let parameters = request.parameters, !parameters.isEmpty {
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // 3. Configure URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = request.timeoutInterval
        
        // 4. Add Headers
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // 5. Set Default Headers
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // 6. Execute Request
        let (data, response) = try await session.data(for: urlRequest)
        
        // 7. Validate Response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 8. Handle Status Codes
        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try jsonDecoder.decode(T.Response.self, from: data)
            } catch let decodingError as DecodingError {
                debugPrint("Decoding error: \(decodingError)")
                throw NetworkError.parsingError
            } catch {
                throw NetworkError.unknown(error)
            }
            
        case 500:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Internal server error"
            throw NetworkError.serverError(message: errorMessage)
            
        default:
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
    }
    
    // Helper for URLError mapping
    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
}
// MARK: - Example Usage

// Define your API endpoints
enum SampleAPI {
    struct GetMedia: NetworkRequest {
        typealias Response = APIResponse
        
        let page: Int
        let contentType: String?
        var endpoint: String { "home_sections" }
        var method: HTTPMethod { .get }
        var parameters: [String: Any]? {
            var params: [String: Any] = ["page": page]
            if let contentType = contentType {
                params["content_type"] = contentType
            }
            return params
        }
    }
    
    struct SearchMedia: NetworkRequest {
        typealias Response = SearchResponse
        
        let query: String
        var endpoint: String { "search" }
        var parameters: [String: Any]? { ["query": query] }
    }
    
}


