import Foundation

// MARK: - Logging Examples

public struct LoggingExamples {
    
    // MARK: - Basic Usage with Logging
    public static func basicExample() async throws {
        // Create client with logging enabled
        let client = NetworkModule.debugClient
        
        // Create request
        let request = URLRequestBuilder()
            .path("https://jsonplaceholder.typicode.com/users/1")
            .method(.get)
            .headers([.json])
            .timeout(30.0)
        
        // This will log:
        // 🚀 [REQUEST] GET https://jsonplaceholder.typicode.com/users/1
        // 📋 Headers: Content-Type: application/json
        // ⏱️ Timeout: 30.0s
        
        struct User: Codable, Sendable {
            let id: Int
            let name: String
            let email: String
        }
        
        let user = try await client.request(
            endpoint: request,
            responseType: User.self
        )
        
        // This will log:
        // ✅ [RESPONSE] 200 https://jsonplaceholder.typicode.com/users/1
        // ⏱️ Duration: 0.234s
        // 📏 Size: 285 bytes
        // 📄 Body: {"id": 1, "name": "Leanne Graham", ...}
        
        print("User: \(user.name)")
    }
    
    // MARK: - Error Logging Example
    public static func errorExample() async {
        let client = NetworkModule.debugClient
        
        let request = URLRequestBuilder()
            .path("https://jsonplaceholder.typicode.com/users/999")
            .method(.get)
        
        do {
            struct User: Codable, Sendable {
                let id: Int
                let name: String
            }
            
            let _ = try await client.request(
                endpoint: request,
                responseType: User.self
            )
        } catch {
            // This will log:
            // ❌ [ERROR] GET https://jsonplaceholder.typicode.com/users/999
            // 🔥 Error: Resource not found.
            // ⏱️ Duration: 0.156s
            // 🏷️ Type: 🔍 Not Found (404)
            
            print("Error occurred: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Custom Logging Configuration
    public static func customLoggingExample() async throws {
        // Create client with custom logging config
        let loggingConfig = NetworkLoggingConfig(
            isEnabled: true,
            logLevel: .debug,
            maxBodySize: 2048
        )
        
        let client = NetworkModule.createClient(loggingConfig: loggingConfig)
        
        let request = URLRequestBuilder()
            .path("https://jsonplaceholder.typicode.com/posts")
            .method(.post)
            .headers([.json])
            .body(.custom([
                "title": "My Post",
                "body": "This is a test post",
                "userId": 1
            ]))
        
        struct Post: Codable, Sendable {
            let id: Int
            let title: String
            let body: String
            let userId: Int
        }
        
        let post = try await client.request(
            endpoint: request,
            responseType: Post.self
        )
        
        print("Created post: \(post.title)")
    }
    
    // MARK: - Debug Description Examples
    public static func debugDescriptionExamples() {
        // URLRequestBuilder debug description
        let request = URLRequestBuilder()
            .path("https://api.example.com/users")
            .method(.post)
            .headers([.json, .custom("X-API-Key", "secret")])
            .body(.custom(["name": "John", "email": "john@example.com"]))
            .authentication(.bearer("token123"))
            .timeout(45.0)
        
        print("Request Debug Info:")
        print(request.debugDescription)
        // Output:
        // 🔧 URLRequestBuilder:
        // 🌐 URL: https://api.example.com/users
        // 📝 Method: POST
        // 📋 Headers:
        //     Content-Type: application/json
        //     X-API-Key: secret
        // 📦 Body: Custom dictionary (2 keys)
        // 🔒 Authentication: 🔑 Bearer Token
        // ⏱️ Timeout: 45.0s
        
        // Network Error debug description
        let errors: [NetworkError] = [
            .badRequest,
            .unauthorized,
            .timeout,
            .decodingFailed,
            .noInternetConnection
        ]
        
        print("\nError Debug Info:")
        for error in errors {
            print(error.debugDescription)
        }
        // Output:
        // 🔴 Bad Request (400)
        // 🔒 Unauthorized (401)
        // ⏰ Request Timeout
        // 📦 JSON Decoding Failed  
        // 📶 No Internet Connection
    }
    
    // MARK: - Logging in Production
    public static func productionExample() -> NetworkClientProtocol {
        // For production, disable logging or use error-only logging
        let productionConfig = NetworkLoggingConfig(
            isEnabled: false, // Disable in production
            logLevel: .error,
            maxBodySize: 512
        )
        
        return NetworkModule.createClient(loggingConfig: productionConfig)
    }
} 