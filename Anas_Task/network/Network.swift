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
final class NetworkClient {
    private let session: URLSession
    private let baseURL: URL
    private let jsonDecoder: JSONDecoder
    
    init(baseURL: URL, session: URLSession = .shared, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.baseURL = baseURL
        self.session = session
        self.jsonDecoder = jsonDecoder
//        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func execute<T: NetworkRequest>(_ request: T) -> AnyPublisher<T.Response, NetworkError> {
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(request.endpoint), resolvingAgainstBaseURL: true) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        // Add query parameters if needed
        if let parameters = request.parameters, !parameters.isEmpty {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        guard let url = urlComponents.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = request.timeoutInterval
        
        // Add headers
        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        // Default headers
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
//                print(String(data: data, encoding: .utf8))
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    if httpResponse.statusCode == 500 {
                        let errorMessage = String(data: data, encoding: .utf8) ?? "Internal server error"
                        throw NetworkError.serverError(message: errorMessage)
                    }
                    throw NetworkError.statusCode(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.Response.self, decoder: jsonDecoder)
            .mapError { error in
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost:
                        return NetworkError.noInternetConnection
                    case .timedOut:
                        return NetworkError.timeout
                    default:
                        return NetworkError.unknown(urlError)
                    }
                } else if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return NetworkError.parsingError
                } else {
                    return NetworkError.unknown(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Example Usage

// Define your API endpoints
enum SampleAPI {
    struct GetMedia: NetworkRequest {
        typealias Response = APIResponse
        
        let page: Int
        var endpoint: String { "home_sections" }
        var method: HTTPMethod { .get }
        var parameters: [String: Any]? { ["page": page] }    }
    
    struct SearchMedia: NetworkRequest {
        typealias Response = SearchResponse
        
//        let query: String
        var endpoint: String { "search" }
//        var parameters: [String: Any]? { ["query": query] }
    }
    
}


