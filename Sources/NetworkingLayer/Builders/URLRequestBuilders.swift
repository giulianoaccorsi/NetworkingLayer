//
//  URLRequestBuilders.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

public final class URLRequestBuilder {
    private var url: URL?
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var queryItems: [String: String] = [:]
    private var body: Data?
    private var timeoutInterval: TimeInterval = 30.0
    private var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    
    public init() {}
    
    // MARK: - URL Configuration
    
    @discardableResult
    public func url(_ url: URL) -> URLRequestBuilder {
        self.url = url
        return self
    }
    
    @discardableResult
    public func url(_ urlString: String) throws -> URLRequestBuilder {
        guard let url = URL(string: urlString) else {
            throw ServiceError.badURL
        }
        return self.url(url)
    }
    
    // MARK: - Method Configuration
    
    @discardableResult
    public func method(_ method: HTTPMethod) -> URLRequestBuilder {
        self.method = method
        return self
    }
    
    @discardableResult
    public func get() -> URLRequestBuilder {
        return method(.get)
    }
    
    @discardableResult
    public func post() -> URLRequestBuilder {
        return method(.post)
    }
    
    @discardableResult
    public func put() -> URLRequestBuilder {
        return method(.put)
    }
    
    @discardableResult
    public func patch() -> URLRequestBuilder {
        return method(.patch)
    }
    
    @discardableResult
    public func delete() -> URLRequestBuilder {
        return method(.delete)
    }
    
    // MARK: - Headers Configuration
    
    @discardableResult
    public func header(_ key: String, _ value: String) -> URLRequestBuilder {
        headers[key] = value
        return self
    }
    
    @discardableResult
    public func headers(_ headers: [String: String]) -> URLRequestBuilder {
        for (key, value) in headers {
            self.headers[key] = value
        }
        return self
    }
    
    @discardableResult
    public func contentType(_ type: String) -> URLRequestBuilder {
        return header("Content-Type", type)
    }
    
    @discardableResult
    public func accept(_ type: String) -> URLRequestBuilder {
        return header("Accept", type)
    }
    
    @discardableResult
    public func userAgent(_ agent: String) -> URLRequestBuilder {
        return header("User-Agent", agent)
    }
    
    @discardableResult
    public func authorization(_ value: String) -> URLRequestBuilder {
        return header("Authorization", value)
    }
    
    @discardableResult
    public func bearerToken(_ token: String) -> URLRequestBuilder {
        return authorization("Bearer \(token)")
    }
    
    @discardableResult
    public func basicAuth(username: String, password: String) -> URLRequestBuilder {
        let credentials = "\(username):\(password)"
        if let data = credentials.data(using: .utf8) {
            let base64 = data.base64EncodedString()
            return authorization("Basic \(base64)")
        }
        return self
    }
    
    // MARK: - Query Parameters
    
    @discardableResult
    public func query(_ key: String, _ value: String) -> URLRequestBuilder {
        queryItems[key] = value
        return self
    }
    
    @discardableResult
    public func queryItems(_ items: [String: String]) -> URLRequestBuilder {
        for (key, value) in items {
            self.queryItems[key] = value
        }
        return self
    }
    
    // MARK: - Body Configuration
    
    @discardableResult
    public func body(_ data: Data) -> URLRequestBuilder {
        self.body = data
        return self
    }
    
    @discardableResult
    public func jsonBody<T: Encodable>(_ object: T, encoder: JSONEncoder = JSONEncoder()) throws -> URLRequestBuilder {
        let data = try encoder.encode(object)
        return body(data).contentType("application/json")
    }
    
    @discardableResult
    public func formBody(_ parameters: [String: String]) -> URLRequestBuilder {
        let formString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
        
        if let data = formString.data(using: .utf8) {
            return body(data).contentType("application/x-www-form-urlencoded")
        }
        return self
    }
    
    @discardableResult
    public func textBody(_ text: String, encoding: String.Encoding = .utf8) -> URLRequestBuilder {
        if let data = text.data(using: encoding) {
            return body(data).contentType("text/plain")
        }
        return self
    }
    
    // MARK: - Request Configuration
    
    @discardableResult
    public func timeout(_ interval: TimeInterval) -> URLRequestBuilder {
        self.timeoutInterval = interval
        return self
    }
    
    @discardableResult
    public func cachePolicy(_ policy: URLRequest.CachePolicy) -> URLRequestBuilder {
        self.cachePolicy = policy
        return self
    }
    
    // MARK: - Build Method
    
    public func build() throws -> URLRequest {
        guard let url = url else {
            throw ServiceError.badURL
        }
        
        var finalURL = url
        if !queryItems.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
            finalURL = components?.url ?? url
        }
        
        var request = URLRequest(
            url: finalURL,
            cachePolicy: cachePolicy,
            timeoutInterval: timeoutInterval
        )
        
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
}

// MARK: - Static Factory Methods

public extension URLRequestBuilder {
    
    static func get(_ url: URL) -> URLRequestBuilder {
        URLRequestBuilder().url(url).get()
    }
    
    static func get(_ urlString: String) throws -> URLRequestBuilder {
        try URLRequestBuilder().url(urlString).get()
    }
    
    static func post(_ url: URL) -> URLRequestBuilder {
        URLRequestBuilder().url(url).post()
    }
    
    static func post(_ urlString: String) throws -> URLRequestBuilder {
        try URLRequestBuilder().url(urlString).post()
    }
    
    static func put(_ url: URL) -> URLRequestBuilder {
        URLRequestBuilder().url(url).put()
    }
    
    static func put(_ urlString: String) throws -> URLRequestBuilder {
        try URLRequestBuilder().url(urlString).put()
    }
    
    static func patch(_ url: URL) -> URLRequestBuilder {
        URLRequestBuilder().url(url).patch()
    }
    
    static func patch(_ urlString: String) throws -> URLRequestBuilder {
        try URLRequestBuilder().url(urlString).patch()
    }
    
    static func delete(_ url: URL) -> URLRequestBuilder {
        URLRequestBuilder().url(url).delete()
    }
    
    static func delete(_ urlString: String) throws -> URLRequestBuilder {
        try URLRequestBuilder().url(urlString).delete()
    }
}

// MARK: - Exemples

/*
 // Exemplo básico
 let request = try URLRequestBuilder()
     .url("https://api.example.com/users")
     .get()
     .header("Authorization", "Bearer token")
     .query("page", "1")
     .timeout(30)
     .build()

 // Exemplo com POST JSON
 let postRequest = try URLRequestBuilder()
     .url("https://api.example.com/users")
     .post()
     .bearerToken("token123")
     .jsonBody(user)
     .build()

 // Exemplo usando factory methods
 let getRequest = try URLRequestBuilder
     .get("https://api.example.com/users")
     .bearerToken("token123")
     .queryItems(["page": "1", "limit": "10"])
     .build()
 */
