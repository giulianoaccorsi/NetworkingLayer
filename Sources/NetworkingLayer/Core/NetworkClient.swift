import Foundation

public actor NetworkClient: NetworkClientProtocol {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let loggingConfig: NetworkLoggingConfig
    
    public init(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        loggingConfig: NetworkLoggingConfig = NetworkLoggingConfig()
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.loggingConfig = loggingConfig
        
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        if loggingConfig.isEnabled {
            NetworkLogger.shared.logConfiguration("NetworkClient initialized with logging enabled")
        }
    }
    
    public func request<T: Codable & Sendable>(
        endpoint: URLRequestBuilder,
        responseType: T.Type
    ) async throws -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let data: Data = try await request(endpoint: endpoint)
        
        do {
            return try jsonDecoder.decode(responseType, from: data)
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            if loggingConfig.isEnabled {
                NetworkLogger.shared.logDecodingError(
                    error,
                    for: try? endpoint.build(),
                    targetType: responseType,
                    responseData: data,
                    duration: duration
                )
            }
            throw NetworkError.decodingFailed
        }
    }
    
    public func request(
        endpoint: URLRequestBuilder
    ) async throws -> Data {
        let urlRequest = try endpoint.build()
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Log request
        if loggingConfig.isEnabled {
            NetworkLogger.shared.logRequest(urlRequest)
        }
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NetworkError.unknown(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
                if loggingConfig.isEnabled {
                    NetworkLogger.shared.logError(error, for: urlRequest, duration: duration)
                }
                throw error
            }
            
            // Log response
            if loggingConfig.isEnabled {
                NetworkLogger.shared.logResponse(httpResponse, data: data, duration: duration)
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                let error = NetworkError.from(
                    httpStatusCode: httpResponse.statusCode,
                    data: data
                )
                if loggingConfig.isEnabled {
                    NetworkLogger.shared.logError(error, for: urlRequest, duration: duration)
                }
                throw error
            }
            
            return data
            
        } catch let error as NetworkError {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            if loggingConfig.isEnabled {
                NetworkLogger.shared.logError(error, for: urlRequest, duration: duration)
            }
            throw error
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            let networkError: NetworkError
            
            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    networkError = .timeout
                case .notConnectedToInternet, .networkConnectionLost:
                    networkError = .noInternetConnection
                default:
                    networkError = .unknown(urlError)
                }
            } else {
                networkError = .unknown(error)
            }
            
            if loggingConfig.isEnabled {
                NetworkLogger.shared.logError(networkError, for: urlRequest, duration: duration)
            }
            
            throw networkError
        }
    }
}

extension NetworkClient {
    public func request<T: Codable & Sendable>(
        endpoint: URLRequestBuilder,
        responseType: T.Type,
        decoder: JSONDecoder
    ) async throws -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let data: Data = try await request(endpoint: endpoint)
        
        do {
            return try decoder.decode(responseType, from: data)
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            if loggingConfig.isEnabled {
                NetworkLogger.shared.logDecodingError(
                    error,
                    for: try? endpoint.build(),
                    targetType: responseType,
                    responseData: data,
                    duration: duration
                )
            }
            throw NetworkError.decodingFailed
        }
    }
} 
