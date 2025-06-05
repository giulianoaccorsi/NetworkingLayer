//
//  RequestComponents.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

public protocol RequestComponent {
    func apply(to request: inout URLRequest)
}

// MARK: - Header Components

public struct HeaderComponent: RequestComponent {
    let key: String
    let value: String
    
    public init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
    
    public func apply(to request: inout URLRequest) {
        request.setValue(value, forHTTPHeaderField: key)
    }
}

public struct HeadersComponent: RequestComponent {
    let headers: [String: String]
    
    public init(_ headers: [String: String]) {
        self.headers = headers
    }
    
    public func apply(to request: inout URLRequest) {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}

// MARK: - Query Components

public struct QueryComponent: RequestComponent {
    let key: String
    let value: String
    
    public init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
    
    public func apply(to request: inout URLRequest) {
        request.addQueryItems([key: value])
    }
}

public struct QueryItemsComponent: RequestComponent {
    let items: [String: String]
    
    public init(_ items: [String: String]) {
        self.items = items
    }
    
    public func apply(to request: inout URLRequest) {
        request.addQueryItems(items)
    }
}

// MARK: - Body Components

public struct JSONBodyComponent<T: Encodable>: RequestComponent {
    let object: T
    let encoder: JSONEncoder
    
    public init(_ object: T, encoder: JSONEncoder = JSONEncoder()) {
        self.object = object
        self.encoder = encoder
    }
    
    public func apply(to request: inout URLRequest) {
        do {
            try request.setJSONBody(object, encoder: encoder)
        } catch {
            print("Failed to encode JSON body: \(error)")
        }
    }
}

public struct DataBodyComponent: RequestComponent {
    let data: Data
    let contentType: String?
    
    public init(_ data: Data, contentType: String? = nil) {
        self.data = data
        self.contentType = contentType
    }
    
    public func apply(to request: inout URLRequest) {
        request.httpBody = data
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
    }
}

public struct FormBodyComponent: RequestComponent {
    let parameters: [String: String]
    
    public init(_ parameters: [String: String]) {
        self.parameters = parameters
    }
    
    public func apply(to request: inout URLRequest) {
        let formString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
        
        request.httpBody = formString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
}

// MARK: - Authentication Components

public struct BearerTokenComponent: RequestComponent {
    let token: String
    
    public init(_ token: String) {
        self.token = token
    }
    
    public func apply(to request: inout URLRequest) {
        request.setBearerToken(token)
    }
}

public struct BasicAuthComponent: RequestComponent {
    let username: String
    let password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    public func apply(to request: inout URLRequest) {
        request.setBasicAuth(username: username, password: password)
    }
}

// MARK: - Configuration Components

public struct TimeoutComponent: RequestComponent {
    let interval: TimeInterval
    
    public init(_ interval: TimeInterval) {
        self.interval = interval
    }
    
    public func apply(to request: inout URLRequest) {
        request.timeoutInterval = interval
    }
}

public struct CachePolicyComponent: RequestComponent {
    let policy: URLRequest.CachePolicy
    
    public init(_ policy: URLRequest.CachePolicy) {
        self.policy = policy
    }
    
    public func apply(to request: inout URLRequest) {
        request.cachePolicy = policy
    }
}

// MARK: - Convenience Functions

public func header(_ key: String, _ value: String) -> HeaderComponent {
    HeaderComponent(key, value)
}

public func headers(_ headers: [String: String]) -> HeadersComponent {
    HeadersComponent(headers)
}

public func query(_ key: String, _ value: String) -> QueryComponent {
    QueryComponent(key, value)
}

public func queryItems(_ items: [String: String]) -> QueryItemsComponent {
    QueryItemsComponent(items)
}

public func jsonBody<T: Encodable>(_ object: T, encoder: JSONEncoder = JSONEncoder()) -> JSONBodyComponent<T> {
    JSONBodyComponent(object, encoder: encoder)
}

public func dataBody(_ data: Data, contentType: String? = nil) -> DataBodyComponent {
    DataBodyComponent(data, contentType: contentType)
}

public func formBody(_ parameters: [String: String]) -> FormBodyComponent {
    FormBodyComponent(parameters)
}

public func bearerToken(_ token: String) -> BearerTokenComponent {
    BearerTokenComponent(token)
}

public func basicAuth(username: String, password: String) -> BasicAuthComponent {
    BasicAuthComponent(username: username, password: password)
}

public func timeout(_ interval: TimeInterval) -> TimeoutComponent {
    TimeoutComponent(interval)
}

public func cachePolicy(_ policy: URLRequest.CachePolicy) -> CachePolicyComponent {
    CachePolicyComponent(policy)
}

// MARK: - Common Header Shortcuts

public func contentType(_ type: String) -> HeaderComponent {
    header("Content-Type", type)
}

public func accept(_ type: String) -> HeaderComponent {
    header("Accept", type)
}

public func userAgent(_ agent: String) -> HeaderComponent {
    header("User-Agent", agent)
}

public func authorization(_ value: String) -> HeaderComponent {
    header("Authorization", value)
}
