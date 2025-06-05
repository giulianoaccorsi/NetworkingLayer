//
//  DataRequestProtocol.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

// MARK: - DataRequestProtocol
public protocol DataRequestProtocol: Sendable {
    associatedtype Response: Decodable & Sendable
    
    var domain: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [String: String] { get }
    var decoder: JSONDecoder { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    
    func makeURLRequest() throws -> URLRequest
    func decode(_ data: Data) throws -> Response
}

// MARK: - Extension
public extension DataRequestProtocol {
    var headers: [String: String] { [:] }
    var queryItems: [String: String] { [:] }
    var body: Data? { nil }
    var timeoutInterval: TimeInterval { 60.0 }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var decoder: JSONDecoder { JSONDecoder() }
    
    func decode(_ data: Data) throws -> Response {
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw ServiceError.decodingError(error)
        }
    }
    
    func makeURLRequest() throws -> URLRequest {
        guard let url = buildURL() else {
            throw ServiceError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy
        request.httpBody = body
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    private func buildURL() -> URL? {
        guard var components = URLComponents(string: domain) else { return nil }
        
        components.path += path
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components.url
    }
}
