import Foundation

// MARK: - Public API Re-exports
// All the types are already public, so they'll be available when importing NetworkingLayer

// MARK: - Convenience Factory

public struct NetworkModule: Sendable {
    public static func createClient(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> NetworkClientProtocol {
        return NetworkClient(urlSession: urlSession, jsonDecoder: jsonDecoder)
    }
    
    public static var defaultClient: NetworkClientProtocol {
        return NetworkClient()
    }
}

// MARK: - Global Convenience Functions

public func createRequest() -> URLRequestBuilder {
    return URLRequestBuilder()
}

public func get(_ path: String) -> URLRequestBuilder {
    return URLRequestBuilder.get(path)
}

public func post(_ path: String) -> URLRequestBuilder {
    return URLRequestBuilder.post(path)
}

public func put(_ path: String) -> URLRequestBuilder {
    return URLRequestBuilder.put(path)
}

public func delete(_ path: String) -> URLRequestBuilder {
    return URLRequestBuilder.delete(path)
}

public func patch(_ path: String) -> URLRequestBuilder {
    return URLRequestBuilder.patch(path)
} 