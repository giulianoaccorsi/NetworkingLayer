import Foundation

// MARK: - Network Configuration
public struct NetworkConfiguration: Sendable {
    public let baseURL: String
    public let defaultHeaders: [String: String]
    public let timeoutInterval: TimeInterval
    public let cachePolicy: URLRequest.CachePolicy
    public let allowsCellularAccess: Bool
    public let waitsForConnectivity: Bool
    
    public init(
        baseURL: String,
        defaultHeaders: [String: String] = [:],
        timeoutInterval: TimeInterval = 30.0,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        allowsCellularAccess: Bool = true,
        waitsForConnectivity: Bool = true
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.allowsCellularAccess = allowsCellularAccess
        self.waitsForConnectivity = waitsForConnectivity
    }
    
    // MARK: - Factory Methods
    
    public static func standard(baseURL: String) -> NetworkConfiguration {
        NetworkConfiguration(
            baseURL: baseURL,
            defaultHeaders: [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        )
    }
    
    public static func api(
        baseURL: String,
        apiKey: String? = nil,
        bearerToken: String? = nil
    ) -> NetworkConfiguration {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let apiKey = apiKey {
            headers["X-API-Key"] = apiKey
        }
        
        if let bearerToken = bearerToken {
            headers["Authorization"] = "Bearer \(bearerToken)"
        }
        
        return NetworkConfiguration(
            baseURL: baseURL,
            defaultHeaders: headers
        )
    }
    
    public static func debug(baseURL: String) -> NetworkConfiguration {
        NetworkConfiguration(
            baseURL: baseURL,
            defaultHeaders: [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "User-Agent": "NetworkModule-Debug/1.0"
            ],
            timeoutInterval: 60.0
        )
    }
} 