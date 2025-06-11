import Foundation

// MARK: - Network Module
/// Ponto de entrada principal para o NetworkModule
/// Expõe apenas as interfaces públicas necessárias
public struct NetworkModule {
    
    // MARK: - Factory Methods
    
    /// Cria um cliente de rede padrão com configuração simples
    public static func createClient(baseURL: String) -> NetworkClientProtocol {
        let configuration = NetworkConfiguration.standard(baseURL: baseURL)
        return NetworkClient(configuration: configuration)
    }
    
    /// Cria um cliente de rede para APIs com autenticação
    public static func createAPIClient(
        baseURL: String,
        apiKey: String? = nil,
        bearerToken: String? = nil
    ) -> NetworkClientProtocol {
        let configuration = NetworkConfiguration.api(
            baseURL: baseURL,
            apiKey: apiKey,
            bearerToken: bearerToken
        )
        return NetworkClient(configuration: configuration)
    }
    
    /// Cria um cliente de rede com configuração personalizada
    public static func createClient(configuration: NetworkConfiguration) -> NetworkClientProtocol {
        return NetworkClient(configuration: configuration)
    }
    
    /// Cria um cliente de rede para debug com timeout estendido
    public static func createDebugClient(baseURL: String) -> NetworkClientProtocol {
        let configuration = NetworkConfiguration.debug(baseURL: baseURL)
        return NetworkClient(configuration: configuration)
    }
    
    /// Cria um cliente de rede com URLSession personalizada
    public static func createClient(
        configuration: NetworkConfiguration,
        session: URLSession
    ) -> NetworkClientProtocol {
        return NetworkClient(
            configuration: configuration,
            session: session
        )
    }
    
    /// Cria um cliente de rede com decodificadores personalizados
    public static func createClient(
        configuration: NetworkConfiguration,
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) -> NetworkClientProtocol {
        return NetworkClient(
            configuration: configuration,
            decoder: decoder,
            encoder: encoder
        )
    }
}

// MARK: - Mock Client Factory
#if DEBUG
public extension NetworkModule {
    
    /// Cria um cliente mock para testes
    static func createMockClient() -> NetworkClientProtocol {
        return MockNetworkClient()
    }
}

// MARK: - Mock Network Client
public final class MockNetworkClient: NetworkClientProtocol, @unchecked Sendable {
    
    public var mockData: Data?
    public var mockResponse: HTTPURLResponse?
    public var mockError: Error?
    public var requestDelay: TimeInterval = 0
    
    public init() {}
    
    public func request<T: Decodable & Sendable>(
        endpoint: any EndpointProtocol,
        responseType: T.Type
    ) async throws -> T {
        try await simulateRequest()
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw NetworkError.noData
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
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
        try await simulateRequest()
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw NetworkError.noData
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    public func requestData(endpoint: any EndpointProtocol) async throws -> Data {
        try await simulateRequest()
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw NetworkError.noData
        }
        
        return data
    }
    
    public func requestDataWithResponse(endpoint: any EndpointProtocol) async throws -> (Data, HTTPURLResponse) {
        try await simulateRequest()
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw NetworkError.noData
        }
        
        let response = mockResponse ?? HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data, response)
    }
    
    private func simulateRequest() async throws {
        if requestDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
        }
    }
    
    // MARK: - Helper Methods for Testing
    
    public func setMockData<T: Encodable>(_ object: T) throws {
        mockData = try JSONEncoder().encode(object)
    }
    
    public func setMockResponse(statusCode: Int, headers: [String: String]? = nil) {
        mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headers
        )
    }
    
    public func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
        requestDelay = 0
    }
}
#endif 