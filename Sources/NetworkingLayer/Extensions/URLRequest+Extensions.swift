//
//  URLRequest+Extensions.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

public extension URLRequest {
    
    init(
        url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30.0,
        cachePolicy: CachePolicy = .useProtocolCachePolicy
    ) {
        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        self.httpMethod = method.rawValue
        self.allHTTPHeaderFields = headers
        self.httpBody = body
    }
    
    // MARK: - Header Management
    
    mutating func setHeader(_ value: String, for key: String) {
        setValue(value, forHTTPHeaderField: key)
    }
    
    mutating func setHeaders(_ headers: [String: String]) {
        for (key, value) in headers {
            setHeader(value, for: key)
        }
    }
    
    func header(for key: String) -> String? {
        value(forHTTPHeaderField: key)
    }
    
    // MARK: - JSON Body Helpers
    
    mutating func setJSONBody<T: Encodable>(
        _ object: T,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        httpBody = try encoder.encode(object)
        setHeader("application/json", for: "Content-Type")
    }
    
    // MARK: - Query Parameters
    
    mutating func addQueryItems(_ items: [String: String]) {
        guard let url = self.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        let newItems = items.map { URLQueryItem(name: $0.key, value: $0.value) }
        components.queryItems = (components.queryItems ?? []) + newItems
        self.url = components.url
    }
    
    // MARK: - Authentication
    
    mutating func setBearerToken(_ token: String) {
        setHeader("Bearer \(token)", for: "Authorization")
    }
    
    mutating func setBasicAuth(username: String, password: String) {
        let credentials = "\(username):\(password)"
        if let data = credentials.data(using: .utf8) {
            let base64 = data.base64EncodedString()
            setHeader("Basic \(base64)", for: "Authorization")
        }
    }
    
    // MARK: - Debug Description
    
    var debugDescription: String {
        var description = "\(httpMethod ?? "GET") \(url?.absoluteString ?? "nil")\n"
        
        if let headers = allHTTPHeaderFields, !headers.isEmpty {
            description += "Headers:\n"
            for (key, value) in headers {
                description += "  \(key): \(value)\n"
            }
        }
        
        if let body = httpBody, !body.isEmpty {
            description += "Body: \(body.count) bytes\n"
            if let bodyString = String(data: body, encoding: .utf8) {
                description += "Body Content: \(bodyString)\n"
            }
        }
        
        return description
    }
}

// MARK: - Validation

public extension URLRequest {
    
    var isValid: Bool {
        guard let url = url else { return false }
        guard let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme) else { return false }
        return true
    }
    
    func validate() throws {
        guard isValid else {
            throw ServiceError.badURL
        }
    }
}
