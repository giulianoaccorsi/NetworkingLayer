import Foundation

// MARK: - Network Client Protocol
public protocol NetworkClientProtocol: Sendable {
    /// Executa uma requisição com endpoint e tipo de resposta
    func request<T: Decodable & Sendable>(
        endpoint: any EndpointProtocol,
        responseType: T.Type
    ) async throws -> T
    
    /// Executa uma requisição simples com URL completa
    func request<T: Decodable & Sendable>(
        url: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?,
        responseType: T.Type
    ) async throws -> T
    
    /// Executa uma requisição e retorna dados brutos
    func requestData(endpoint: any EndpointProtocol) async throws -> Data
    
    /// Executa uma requisição e retorna dados brutos + response
    func requestDataWithResponse(endpoint: any EndpointProtocol) async throws -> (Data, HTTPURLResponse)
}

// MARK: - Network Client Protocol Extensions
public extension NetworkClientProtocol {
    
    /// Conveniência para GET simples
    func get<T: Decodable & Sendable>(
        path: String,
        responseType: T.Type,
        queryItems: [String: String] = [:],
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = SimpleEndpoint(
            path: path,
            method: .get,
            headers: headers,
            queryItems: queryItems
        )
        return try await request(endpoint: endpoint, responseType: responseType)
    }
    
    /// Conveniência para POST com body
    func post<T: Decodable & Sendable, Body: Encodable & Sendable>(
        path: String,
        body: Body,
        responseType: T.Type,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = SimpleEndpoint(
            path: path,
            method: .post,
            headers: headers,
            body: body
        )
        return try await request(endpoint: endpoint, responseType: responseType)
    }
    
    /// Conveniência para PUT com body
    func put<T: Decodable & Sendable, Body: Encodable & Sendable>(
        path: String,
        body: Body,
        responseType: T.Type,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = SimpleEndpoint(
            path: path,
            method: .put,
            headers: headers,
            body: body
        )
        return try await request(endpoint: endpoint, responseType: responseType)
    }
    
    /// Conveniência para DELETE
    func delete<T: Decodable & Sendable>(
        path: String,
        responseType: T.Type,
        headers: [String: String] = [:]
    ) async throws -> T {
        let endpoint = SimpleEndpoint(
            path: path,
            method: .delete,
            headers: headers
        )
        return try await request(endpoint: endpoint, responseType: responseType)
    }
}

// MARK: - Simple Endpoint Implementation
private struct SimpleEndpoint: EndpointProtocol {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [String: String]
    let body: (any Encodable & Sendable)?
    
    init(
        path: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        queryItems: [String: String] = [:],
        body: (any Encodable & Sendable)? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
} 