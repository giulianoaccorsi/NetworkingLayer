import Foundation

public protocol NetworkClientProtocol: Sendable {
    func request<T: Codable & Sendable>(
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