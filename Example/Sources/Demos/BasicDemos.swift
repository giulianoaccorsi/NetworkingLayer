import Foundation
import NetworkingLayer

// MARK: - Basic Demo Functions

/// Demonstrates basic GET requests with simple DataRequestProtocol usage
func demonstrateBasicRequests(service: NetworkService) async {
    print("\n📋 Basic Requests Demo")
    print("-" * 40)
    
    do {
        // Simple GET request
        print("1️⃣ Fetching all posts...")
        let posts = try await service.request(GetPostsRequest())
        print("   ✅ Fetched \(posts.count) posts")
        
        // GET request with path parameter
        if let firstPost = posts.first {
            print("2️⃣ Fetching user #\(firstPost.userId)...")
            let user = try await service.request(GetUserRequest(userId: firstPost.userId))
            print("   ✅ User: \(user.name) (\(user.email))")
            if let website = user.website {
                print("   🌐 Website: \(website)")
            }
        }
        
    } catch {
        print("❌ Error in basic requests: \(error)")
    }
}

/// Demonstrates different retry strategies and policies
func demonstrateRetryStrategies() async {
    print("\n🔄 Retry Strategies Demo")
    print("-" * 40)
    
    // Different retry strategies
    let services = [
        ("No Retry", NetworkServiceWithRetry.withoutRetry()),
        ("Linear Retry", NetworkServiceWithRetry.withLinearRetry(maxRetries: 2, delay: 1.0)),
        ("Exponential Backoff", NetworkServiceWithRetry.withExponentialBackoff(maxRetries: 3))
    ]
    
    for (name, service) in services {
        print("🔄 Testing \(name)...")
        do {
            let posts = try await service.request(GetPostsRequest())
            print("   ✅ Success: \(posts.count) posts fetched")
        } catch {
            print("   ❌ Failed: \(error.localizedDescription)")
        }
    }
}

/// Demonstrates comprehensive error handling for different error scenarios
func demonstrateErrorHandling(service: NetworkService) async {
    print("\n🚨 Error Handling Showcase")
    print("-" * 40)
    
    // Test different error scenarios
    let errorTests = [
        ("404 Not Found", GetUserRequest(userId: 99999)),
        ("Invalid Endpoint", GetUserRequest(userId: 999999))  // This might also return 404
    ]
    
    for (testName, request) in errorTests {
        print("🧪 Testing: \(testName)")
        do {
            let _ = try await service.request(request)
            print("   😮 Unexpected success!")
        } catch let error as ServiceError {
            switch error {
            case .invalidStatusCode(let code):
                print("   ✅ HTTP Error \(code): \(error.localizedDescription)")
                if let recovery = error.recoverySuggestion {
                    print("   💡 Suggestion: \(recovery)")
                }
            case .networkError(let underlyingError):
                print("   ✅ Network Error: \(underlyingError.localizedDescription)")
            case .decodingError:
                print("   ✅ Decoding Error: \(error.localizedDescription)")
            default:
                print("   ✅ Other Service Error: \(error.localizedDescription)")
            }
        } catch {
            print("   ❌ Unexpected error type: \(error)")
        }
    }
} 