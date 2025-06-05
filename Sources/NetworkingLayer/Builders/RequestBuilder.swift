//
//  RequestBuilder.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

@resultBuilder
public struct RequestBuilder {
    public static func buildBlock(_ components: RequestComponent...) -> [RequestComponent] {
        components
    }
    
    public static func buildArray(_ components: [[RequestComponent]]) -> [RequestComponent] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [RequestComponent]?) -> [RequestComponent] {
        component ?? []
    }
    
    public static func buildEither(first component: [RequestComponent]) -> [RequestComponent] {
        component
    }
    
    public static func buildEither(second component: [RequestComponent]) -> [RequestComponent] {
        component
    }
}

// MARK: - Extension

public extension URLRequest {
    
    init(
        url: URL,
        method: HTTPMethod = .get,
        @RequestBuilder components: () -> [RequestComponent]
    ) {
        self.init(url: url)
        self.httpMethod = method.rawValue
        
        for component in components() {
            component.apply(to: &self)
        }
    }
    
    mutating func configure(@RequestBuilder components: () -> [RequestComponent]) {
        for component in components() {
            component.apply(to: &self)
        }
    }
}

// MARK: - RequestConfigurator

public struct RequestConfigurator {
    private var request: URLRequest
    
    public init(url: URL, method: HTTPMethod = .get) {
        self.request = URLRequest(url: url)
        self.request.httpMethod = method.rawValue
    }
    
    public func header(_ key: String, _ value: String) -> RequestConfigurator {
        var newRequest = request
        newRequest.setValue(value, forHTTPHeaderField: key)
        return RequestConfigurator(request: newRequest)
    }
    
    public func headers(_ headers: [String: String]) -> RequestConfigurator {
        var newRequest = request
        for (key, value) in headers {
            newRequest.setValue(value, forHTTPHeaderField: key)
        }
        return RequestConfigurator(request: newRequest)
    }
    
    public func query(_ key: String, _ value: String) -> RequestConfigurator {
        var newRequest = request
        newRequest.addQueryItems([key: value])
        return RequestConfigurator(request: newRequest)
    }
    
    public func queryItems(_ items: [String: String]) -> RequestConfigurator {
        var newRequest = request
        newRequest.addQueryItems(items)
        return RequestConfigurator(request: newRequest)
    }
    
    public func jsonBody<T: Encodable>(_ object: T, encoder: JSONEncoder = JSONEncoder()) throws -> RequestConfigurator {
        var newRequest = request
        try newRequest.setJSONBody(object, encoder: encoder)
        return RequestConfigurator(request: newRequest)
    }
    
    public func body(_ data: Data) -> RequestConfigurator {
        var newRequest = request
        newRequest.httpBody = data
        return RequestConfigurator(request: newRequest)
    }
    
    public func timeout(_ interval: TimeInterval) -> RequestConfigurator {
        var newRequest = request
        newRequest.timeoutInterval = interval
        return RequestConfigurator(request: newRequest)
    }
    
    public func cachePolicy(_ policy: URLRequest.CachePolicy) -> RequestConfigurator {
        var newRequest = request
        newRequest.cachePolicy = policy
        return RequestConfigurator(request: newRequest)
    }
    
    public func bearerToken(_ token: String) -> RequestConfigurator {
        var newRequest = request
        newRequest.setBearerToken(token)
        return RequestConfigurator(request: newRequest)
    }
    
    public func basicAuth(username: String, password: String) -> RequestConfigurator {
        var newRequest = request
        newRequest.setBasicAuth(username: username, password: password)
        return RequestConfigurator(request: newRequest)
    }
    
    public func build() -> URLRequest {
        request
    }
    
    private init(request: URLRequest) {
        self.request = request
    }
}

// MARK: - Convenience Functions

public func buildRequest(
    url: URL,
    method: HTTPMethod = .get,
    @RequestBuilder components: () -> [RequestComponent]
) -> URLRequest {
    URLRequest(url: url, method: method, components: components)
}

public func configure(
    _ request: inout URLRequest,
    @RequestBuilder components: () -> [RequestComponent]
) {
    request.configure(components: components)
}
