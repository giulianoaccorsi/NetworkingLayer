import Foundation

// MARK: - Endpoint Protocol
public protocol EndpointProtocol: Sendable {
    /// O caminho do endpoint (ex: "/users", "/posts/123")
    var path: String { get }
    
    /// O método HTTP (GET, POST, etc.)
    var method: HTTPMethod { get }
    
    /// Headers específicos do endpoint (opcional)
    var headers: [String: String] { get }
    
    /// Query parameters (opcional)
    var queryItems: [String: String] { get }
    
    /// Body da requisição (opcional)
    var body: (any Encodable & Sendable)? { get }
    
    /// Timeout específico do endpoint (opcional - usa o da configuração se nil)
    var timeoutInterval: TimeInterval? { get }
    
    /// Cache policy específico do endpoint (opcional - usa o da configuração se nil)
    var cachePolicy: URLRequest.CachePolicy? { get }
}

// MARK: - Default Implementation
public extension EndpointProtocol {
    var headers: [String: String] { [:] }
    var queryItems: [String: String] { [:] }
    var body: (any Encodable & Sendable)? { nil }
    var timeoutInterval: TimeInterval? { nil }
    var cachePolicy: URLRequest.CachePolicy? { nil }
}

// MARK: - Convenience Protocols

/// Protocolo para endpoints que apenas fazem GET sem parâmetros
public protocol SimpleGetEndpoint: EndpointProtocol {
    var path: String { get }
}

public extension SimpleGetEndpoint {
    var method: HTTPMethod { .get }
}

/// Protocolo para endpoints que fazem POST com body
public protocol PostEndpoint: EndpointProtocol {
    associatedtype Body: Encodable & Sendable
    
    var path: String { get }
    var requestBody: Body { get }
}

public extension PostEndpoint {
    var method: HTTPMethod { .post }
    var body: (any Encodable & Sendable)? { requestBody }
}

/// Protocolo para endpoints que fazem PUT com body
public protocol PutEndpoint: EndpointProtocol {
    associatedtype Body: Encodable & Sendable
    
    var path: String { get }
    var requestBody: Body { get }
}

public extension PutEndpoint {
    var method: HTTPMethod { .put }
    var body: (any Encodable & Sendable)? { requestBody }
}

/// Protocolo para endpoints que fazem DELETE
public protocol DeleteEndpoint: EndpointProtocol {
    var path: String { get }
}

public extension DeleteEndpoint {
    var method: HTTPMethod { .delete }
} 