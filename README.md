# NetworkingLayer

A modern, type-safe networking layer for Swift with multiple builder patterns, comprehensive error handling, and powerful retry mechanisms.

[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%2B%20|%20macOS%2012%2B%20|%20tvOS%2015%2B%20|%20watchOS%208%2B-blue.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Features

- 🏗️ **Multiple Builder Patterns** - Choose the style that fits your needs
- 🔄 **Intelligent Retry Policies** - Exponential backoff, linear retry, or custom strategies
- ❌ **Comprehensive Error Handling** - Localized error messages with recovery suggestions
- 🛡️ **Type Safety** - Protocol-based design with compile-time guarantees
- 📝 **Extensive Logging** - Configurable network request/response logging
- ⚡ **Swift 6 Ready** - Full concurrency support with async/await
- 🧪 **Thoroughly Tested** - Comprehensive test suite with 100% coverage
- 📱 **Cross-Platform** - iOS, macOS, tvOS, and watchOS support

## 🚀 Quick Start

### Installation

Add NetworkingLayer to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/NetworkingLayer.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import NetworkingLayer

// Create a service
let service = DefaultNetworkService()

// Define a request
struct GetPostsRequest: DataRequestProtocol {
    typealias Response = [Post]
    
    let domain = "https://jsonplaceholder.typicode.com"
    let path = "/posts"
    let method = HTTPMethod.get
}

// Make the request
let posts = try await service.request(GetPostsRequest())
```

## 🏗️ Builder Patterns

NetworkingLayer offers four different builder patterns to suit different coding styles and use cases:

### 1. DataRequestProtocol (Recommended)

**Best for:** Type-safe, reusable request definitions

```swift
struct CreatePostRequest: DataRequestProtocol {
    typealias Response = Post
    
    let postData: CreatePostData
    
    let domain = "https://api.example.com"
    let path = "/posts"
    let method = HTTPMethod.post
    
    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        try? JSONEncoder().encode(postData)
    }
}

// Usage
let postData = CreatePostData(title: "Hello", body: "World", userId: 1)
let post = try await service.request(CreatePostRequest(postData: postData))
```

### 2. URLRequestBuilder

**Best for:** Imperative, step-by-step request building

```swift
let request = try URLRequestBuilder
    .post("https://api.example.com/posts")
    .contentType("application/json")
    .bearerToken("your-token")
    .jsonBody(postData)
    .timeout(30)
    .build()

let (data, _) = try await URLSession.shared.data(for: request)
```

**Available Methods:**
- `.get()`, `.post()`, `.put()`, `.patch()`, `.delete()`
- `.header(key, value)`, `.headers([String: String])`
- `.query(key, value)`, `.queryItems([String: String])`
- `.bearerToken(token)`, `.basicAuth(username, password)`
- `.jsonBody(object)`, `.formBody(params)`, `.body(data)`
- `.timeout(interval)`, `.cachePolicy(policy)`

### 3. RequestConfigurator

**Best for:** Functional programming style with immutable fluent API

```swift
let request = try RequestConfigurator(
    url: URL(string: "https://api.example.com/posts")!,
    method: .post
)
.headers([
    "Content-Type": "application/json",
    "Accept": "application/json"
])
.bearerToken("your-token")
.jsonBody(postData)
.timeout(30)
.build()
```

### 4. @resultBuilder (DSL)

**Best for:** Declarative, SwiftUI-like syntax

```swift
let request = URLRequest(
    url: URL(string: "https://api.example.com/posts")!,
    method: .post
) {
    contentType("application/json")
    accept("application/json")
    bearerToken("your-token")
    jsonBody(postData)
    timeout(30)
    
    if needsAuthentication {
        header("X-Auth-Required", "true")
    }
}
```

## 🔄 Retry Strategies

NetworkingLayer includes intelligent retry mechanisms:

### No Retry
```swift
let service = NetworkServiceWithRetry.withoutRetry()
```

### Linear Retry
```swift
let service = NetworkServiceWithRetry.withLinearRetry(
    maxRetries: 3,
    delay: 1.0
)
```

### Exponential Backoff (Recommended)
```swift
let service = NetworkServiceWithRetry.withExponentialBackoff(
    maxRetries: 3,
    baseDelay: 1.0,
    maxDelay: 30.0
)
```

### Custom Retry Policy
```swift
struct CustomRetryPolicy: RetryPolicy {
    let maxRetries = 5
    
    func shouldRetry(for error: Error, attempt: Int) -> Bool {
        // Custom retry logic
        return attempt < maxRetries && isRetryableError(error)
    }
    
    func delay(for attempt: Int) -> TimeInterval {
        // Custom delay calculation
        return TimeInterval(attempt * 2)
    }
}
```

## ❌ Error Handling

Comprehensive error handling with localized messages:

```swift
do {
    let posts = try await service.request(GetPostsRequest())
} catch let error as ServiceError {
    switch error {
    case .invalidStatusCode(let code):
        print("HTTP Error \(code): \(error.localizedDescription)")
        print("Recovery: \(error.recoverySuggestion ?? "")")
        
    case .networkError(let underlying):
        print("Network Error: \(underlying.localizedDescription)")
        
    case .decodingError(let underlying):
        print("Parsing Error: \(underlying.localizedDescription)")
        
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## 📝 Logging

Configurable network logging for debugging:

```swift
// Enable detailed logging
let logger = NetworkLogger(isEnabled: true)
let service = DefaultNetworkService(logger: logger)

// Silent logging for production
let silentLogger = SilentNetworkLogger()
let service = DefaultNetworkService(logger: silentLogger)
```

## 🛡️ Response Validation

Flexible response validation:

```swift
// JSON validation
let validator = JSONResponseValidator()

// Custom status codes
let validator = CustomStatusCodeValidator(acceptableStatusCodes: [200, 201, 204])

// Content type validation
let validator = DefaultResponseValidator(
    acceptableStatusCodes: 200..<300,
    acceptableContentTypes: ["application/json"]
)

// Composite validation
let validator = CompositeResponseValidator([
    JSONResponseValidator(),
    CustomStatusCodeValidator(acceptableStatusCodes: [200, 201])
])
```

## 🧪 Testing

NetworkingLayer includes comprehensive testing utilities:

```swift
// Mock network service for testing
class MockNetworkService: NetworkService {
    var mockResponse: Any?
    var mockError: Error?
    
    func request<Request: DataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response {
        if let error = mockError {
            throw error
        }
        return mockResponse as! Request.Response
    }
}
```

## 📱 Advanced Examples

### Pagination
```swift
struct PostsWithPaginationRequest: DataRequestProtocol {
    typealias Response = [Post]
    
    let page: Int
    let limit: Int
    
    let domain = "https://jsonplaceholder.typicode.com"
    let path = "/posts"
    let method = HTTPMethod.get
    
    var queryItems: [String: String] {
        [
            "_page": String(page),
            "_limit": String(limit)
        ]
    }
}
```

### File Upload
```swift
let uploadRequest = try URLRequestBuilder
    .post("https://api.example.com/upload")
    .bearerToken("your-token")
    .body(imageData)
    .header("Content-Type", "image/jpeg")
    .build()
```

### Custom Headers & Authentication
```swift
struct AuthenticatedRequest: DataRequestProtocol {
    typealias Response = UserProfile
    
    let domain = "https://api.example.com"
    let path = "/profile"
    let method = HTTPMethod.get
    
    var headers: [String: String] {
        [
            "Authorization": "Bearer \(AuthManager.shared.token)",
            "Accept": "application/json",
            "User-Agent": "MyApp/1.0",
            "X-API-Version": "v2"
        ]
    }
}
```

## 🔧 Configuration

### Network Configuration
```swift
let config = NetworkConfiguration(
    baseURL: "https://api.example.com",
    defaultHeaders: [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ],
    timeoutInterval: 30.0,
    cachePolicy: .useProtocolCachePolicy
)
```

### Custom Decoders
```swift
struct CustomRequest: DataRequestProtocol {
    typealias Response = [Post]
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    // ... other properties
}
```

## 🎯 Best Practices

1. **Use DataRequestProtocol** for reusable, type-safe requests
2. **Implement retry policies** for production applications
3. **Handle errors appropriately** with proper user feedback
4. **Use silent logging** in production builds
5. **Validate responses** based on your API requirements
6. **Test network code** using dependency injection
7. **Configure timeouts** appropriately for your use case

## 📋 Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 6.0+
- Xcode 16.0+

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

NetworkingLayer is available under the MIT license. See the LICENSE file for more info.

## 🙏 Acknowledgments

- Built with ❤️ using modern Swift concurrency
- Inspired by the best practices from the Swift community
- Designed for real-world iOS applications

---
