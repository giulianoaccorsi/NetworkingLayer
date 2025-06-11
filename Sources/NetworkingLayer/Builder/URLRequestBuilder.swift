import Foundation

public class URLRequestBuilder {
    private var urlString: String = ""
    private var httpMethod: HTTPMethod = .get
    private var httpHeaders: [HTTPHeader] = []
    private var httpBody: HTTPBody = .none
    private var authentication: Authentication = .none
    private var timeoutInterval: TimeInterval = 60.0
    private var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    
    public init() {}
    
    @discardableResult
    public func path(_ path: String) -> URLRequestBuilder {
        self.urlString = path
        return self
    }
    
    @discardableResult
    public func method(_ method: HTTPMethod) -> URLRequestBuilder {
        self.httpMethod = method
        return self
    }
    
    @discardableResult
    public func headers(_ headers: [HTTPHeader]) -> URLRequestBuilder {
        self.httpHeaders = headers
        return self
    }
    
    @discardableResult
    public func header(_ header: HTTPHeader) -> URLRequestBuilder {
        self.httpHeaders.append(header)
        return self
    }
    
    @discardableResult
    public func body(_ body: HTTPBody) -> URLRequestBuilder {
        self.httpBody = body
        return self
    }
    
    @discardableResult
    public func authentication(_ auth: Authentication) -> URLRequestBuilder {
        self.authentication = auth
        return self
    }
    
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
    
    public func build() throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.timeoutInterval = timeoutInterval
        request.cachePolicy = cachePolicy
        
        // Add headers
        for header in httpHeaders {
            let (key, value) = header.keyValuePair
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add authentication header if present
        if let authHeader = authentication.toHeader() {
            let (key, value) = authHeader.keyValuePair
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body
        do {
            request.httpBody = try httpBody.toData()
        } catch {
            throw NetworkError.encodingFailed
        }
        
        return request
    }
}

// MARK: - Convenience methods for common patterns
extension URLRequestBuilder {
    public static func get(_ path: String) -> URLRequestBuilder {
        return URLRequestBuilder().path(path).method(.get)
    }
    
    public static func post(_ path: String) -> URLRequestBuilder {
        return URLRequestBuilder().path(path).method(.post)
    }
    
    public static func put(_ path: String) -> URLRequestBuilder {
        return URLRequestBuilder().path(path).method(.put)
    }
    
    public static func delete(_ path: String) -> URLRequestBuilder {
        return URLRequestBuilder().path(path).method(.delete)
    }
    
    public static func patch(_ path: String) -> URLRequestBuilder {
        return URLRequestBuilder().path(path).method(.patch)
    }
} 