import Foundation

public class NetworkClient: NetworkClientProtocol {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    public init(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        
        // Configure JSON decoder with common settings
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - NetworkClientProtocol Implementation
    
    public func request<T: Codable>(
        endpoint: URLRequestBuilder,
        responseType: T.Type
    ) async throws -> T {
        let data: Data = try await request(endpoint: endpoint)
        
        do {
            return try jsonDecoder.decode(responseType, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
    
    public func request(
        endpoint: URLRequestBuilder
    ) async throws -> Data {
        let urlRequest = try endpoint.build()
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
            }
            
            // Check for HTTP errors
            if !(200...299).contains(httpResponse.statusCode) {
                throw NetworkError.from(httpStatusCode: httpResponse.statusCode)
            }
            
            return data
            
        } catch let error as NetworkError {
            throw error
        } catch {
            // Handle specific URLSession errors
            if let urlError = error as? URLError {
                switch urlError.code {
                case .timedOut:
                    throw NetworkError.timeout
                case .notConnectedToInternet, .networkConnectionLost:
                    throw NetworkError.noInternetConnection
                default:
                    throw NetworkError.unknown(urlError)
                }
            }
            
            throw NetworkError.unknown(error)
        }
    }
    
    public func request(
        endpoint: URLRequestBuilder
    ) async throws {
        let _: Data = try await request(endpoint: endpoint)
    }
}

// MARK: - Convenience methods
extension NetworkClient {
    public func request<T: Codable>(
        endpoint: URLRequestBuilder,
        responseType: T.Type,
        decoder: JSONDecoder
    ) async throws -> T {
        let data: Data = try await request(endpoint: endpoint)
        
        do {
            return try decoder.decode(responseType, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
} 