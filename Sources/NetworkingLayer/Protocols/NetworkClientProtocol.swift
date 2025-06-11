import Foundation

public protocol NetworkClientProtocol {
    func request<T: Codable>(
        endpoint: URLRequestBuilder,
        responseType: T.Type
    ) async throws -> T
    
    func request(
        endpoint: URLRequestBuilder
    ) async throws -> Data
    
    func request(
        endpoint: URLRequestBuilder
    ) async throws
} 