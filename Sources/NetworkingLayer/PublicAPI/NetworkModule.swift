import Foundation

public struct NetworkModule: Sendable {
    public static func createClient(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        loggingConfig: NetworkLoggingConfig = NetworkLoggingConfig()
    ) -> NetworkClientProtocol {
        return NetworkClient(
            urlSession: urlSession, 
            jsonDecoder: jsonDecoder,
            loggingConfig: loggingConfig
        )
    }
    
    public static var defaultClient: NetworkClientProtocol {
        return NetworkClient()
    }
    
    public static var debugClient: NetworkClientProtocol {
        return NetworkClient(loggingConfig: NetworkLoggingConfig(isEnabled: true, logLevel: .debug))
    }
}

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