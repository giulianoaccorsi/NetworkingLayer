import Foundation

// MARK: - Network Client Implementation
public final class NetworkClient: NetworkClientProtocol {
    
    // MARK: - Properties
    private let configuration: NetworkConfiguration
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // MARK: - Initialization
    public init(
        configuration: NetworkConfiguration,
        session: URLSession? = nil,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.configuration = configuration
        self.decoder = decoder
        self.encoder = encoder
        
        if let session = session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = configuration.timeoutInterval
            config.allowsCellularAccess = configuration.allowsCellularAccess
            config.waitsForConnectivity = configuration.waitsForConnectivity
            config.requestCachePolicy = configuration.cachePolicy
            
            self.session = URLSession(configuration: config)
        }
    }
    
    // MARK: - NetworkClientProtocol Implementation
    
    public func request<T: Decodable & Sendable>(
        endpoint: any EndpointProtocol,
        responseType: T.Type
    ) async throws -> T {
        let data = try await requestData(endpoint: endpoint)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    public func request<T: Decodable & Sendable>(
        url: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?,
        responseType: T.Type
    ) async throws -> T {
        let endpoint = DirectURLEndpoint(
            url: url,
            method: method,
            headers: headers,
            body: body
        )
        return try await request(endpoint: endpoint, responseType: responseType)
    }
    
    public func requestData(endpoint: any EndpointProtocol) async throws -> Data {
        let (data, _) = try await requestDataWithResponse(endpoint: endpoint)
        return data
    }
    
    public func requestDataWithResponse(endpoint: any EndpointProtocol) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try buildURLRequest(from: endpoint)
        
        do {
            let (data, response): (Data, URLResponse)
            
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                (data, response) = try await session.data(for: urlRequest)
            } else {
                // Fallback para versões anteriores
                (data, response) = try await withCheckedThrowingContinuation { continuation in
                    let task = session.dataTask(with: urlRequest) { data, response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let data = data, let response = response else {
                            continuation.resume(throwing: NetworkError.noData)
                            return
                        }
                        
                        continuation.resume(returning: (data, response))
                    }
                    task.resume()
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.statusCode(httpResponse.statusCode, data)
            }
            
            return (data, httpResponse)
            
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func buildURLRequest(from endpoint: any EndpointProtocol) throws -> URLRequest {
        let fullURL = try buildFullURL(from: endpoint)
        
        var request = URLRequest(
            url: fullURL,
            cachePolicy: endpoint.cachePolicy ?? configuration.cachePolicy,
            timeoutInterval: endpoint.timeoutInterval ?? configuration.timeoutInterval
        )
        
        request.httpMethod = endpoint.method.rawValue
        
        // Merge headers: configuration defaults + endpoint specific
        var allHeaders = configuration.defaultHeaders
        for (key, value) in endpoint.headers {
            allHeaders[key] = value
        }
        
        for (key, value) in allHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body if present
        if let body = endpoint.body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        return request
    }
    
    private func buildFullURL(from endpoint: any EndpointProtocol) throws -> URL {
        // Para DirectURLEndpoint, usa a URL completa
        if let directEndpoint = endpoint as? DirectURLEndpoint {
            guard let url = URL(string: directEndpoint.fullURL) else {
                throw NetworkError.invalidURL
            }
            return url
        }
        
        // Para endpoints normais, combina baseURL + path
        let baseURL = configuration.baseURL.hasSuffix("/") ? 
            String(configuration.baseURL.dropLast()) : configuration.baseURL
        let path = endpoint.path.hasPrefix("/") ? endpoint.path : "/\(endpoint.path)"
        
        guard var components = URLComponents(string: baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        // Adiciona query items se existirem
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems.map { 
                URLQueryItem(name: $0.key, value: $0.value) 
            }
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
    
    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        case .badURL:
            return .invalidURL
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkError(error)
        default:
            return .networkError(error)
        }
    }
}

// MARK: - Helper Types

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    
    init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

private struct DirectURLEndpoint: EndpointProtocol {
    let fullURL: String
    let path: String = ""
    let method: HTTPMethod
    let headers: [String: String]
    let body: (any Encodable & Sendable)?
    
    init(
        url: String,
        method: HTTPMethod,
        headers: [String: String],
        body: (any Encodable & Sendable)?
    ) {
        self.fullURL = url
        self.method = method
        self.headers = headers
        self.body = body
    }
} 