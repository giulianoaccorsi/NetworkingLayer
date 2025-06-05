import Foundation
import NetworkingLayer

// MARK: - Advanced Demo Functions

/// Demonstrates advanced request patterns with query parameters, headers, and different HTTP methods
func demonstrateAdvancedRequests(service: NetworkService) async {
    print("\n🚀 Advanced Requests Demo")
    print("-" * 40)
    
    do {
        // GET request with query parameters (pagination)
        print("1️⃣ Fetching posts with pagination...")
        let paginatedPosts = try await service.request(
            PostsWithPaginationRequest(page: 1, limit: 5)
        )
        print("   ✅ Fetched \(paginatedPosts.count) posts (page 1, limit 5)")
        
        // GET request with multiple query parameters and custom headers
        print("2️⃣ Searching posts with custom headers...")
        let searchRequest = SearchPostsRequest(query: "qui", userId: 1)
        let searchResults = try await service.request(searchRequest)
        print("   ✅ Found \(searchResults.count) posts matching 'qui' for user 1")
        
        // POST request with JSON body
        print("3️⃣ Creating a new post...")
        let newPostData = CreatePostData(
            userId: 1,
            title: "Advanced NetworkingLayer Example",
            body: "This demonstrates advanced request building with headers, query params, and JSON bodies!"
        )
        let newPost = try await service.request(CreatePostRequest(postData: newPostData))
        print("   ✅ Created post #\(newPost.id): '\(newPost.title)'")
        
        // PUT request with JSON body
        print("4️⃣ Updating user information...")
        let updateData = UpdateUserData(
            name: "John Doe Updated",
            email: "john.updated@example.com",
            website: "https://johndoe-updated.com"
        )
        let updatedUser = try await service.request(
            UpdateUserRequest(userId: 1, userData: updateData)
        )
        print("   ✅ Updated user: \(updatedUser.name)")
        
    } catch {
        print("❌ Error in advanced requests: \(error)")
    }
}

/// Demonstrates RequestConfigurator (Fluent API) for building complex requests
func demonstrateRequestBuilder(service: NetworkService) async {
    print("\n🔧 RequestConfigurator (Fluent API) Demo")
    print("-" * 50)
    
    do {
        // Using RequestConfigurator to build a complex request
        print("1️⃣ Building request with Fluent API...")
        
        let baseURL = URL(string: "https://jsonplaceholder.typicode.com/comments")!
        
        let complexRequest = RequestConfigurator(url: baseURL, method: .get)
            .header("Accept", "application/json")
            .header("User-Agent", "NetworkingLayer-FluentAPI/1.0")
            .query("postId", "1")
            .query("_limit", "3")
            .timeout(30.0)
            .cachePolicy(.reloadIgnoringLocalCacheData)
            .build()
        
        print("   📋 Request URL: \(complexRequest.url?.absoluteString ?? "unknown")")
        print("   📋 Method: \(complexRequest.httpMethod ?? "unknown")")
        print("   📋 Headers: \(complexRequest.allHTTPHeaderFields ?? [:])")
        print("   📋 Timeout: \(complexRequest.timeoutInterval)s")
        
        // Custom request using URLSession directly to show the built request works
        let (data, response) = try await URLSession.shared.data(for: complexRequest)
        
        if let httpResponse = response as? HTTPURLResponse,
           200..<300 ~= httpResponse.statusCode {
            let comments = try JSONDecoder().decode([Comment].self, from: data)
            print("   ✅ Fetched \(comments.count) comments using fluent API")
            for comment in comments.prefix(2) {
                print("     💬 \(comment.name): \(comment.email)")
            }
        }
        
    } catch {
        print("❌ Error with RequestConfigurator: \(error)")
    }
}

/// Demonstrates different request building patterns available in the framework
func demonstrateMultipleRequestPatterns() async {
    print("\n🎯 Multiple Request Building Patterns")
    print("-" * 50)
    
    let baseURL = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
    
    // Pattern 1: RequestConfigurator (Fluent API)
    print("1️⃣ Pattern: RequestConfigurator (Fluent API)")
    let fluentRequest = RequestConfigurator(url: baseURL, method: .get)
        .header("Accept", "application/json")
        .bearerToken("demo-token-123")
        .timeout(15.0)
        .build()
    
    print("   🔗 URL: \(fluentRequest.url?.absoluteString ?? "unknown")")
    print("   🔑 Auth: \(fluentRequest.value(forHTTPHeaderField: "Authorization") ?? "none")")
    
    // Pattern 2: Direct URLRequest with configure
    print("2️⃣ Pattern: URLRequest.configure")
    var directRequest = URLRequest(url: baseURL)
    directRequest.httpMethod = "GET"
    // Note: This would use the configure method if implemented
    print("   🔗 URL: \(directRequest.url?.absoluteString ?? "unknown")")
    
    // Pattern 3: DataRequestProtocol (what we've been using)
    print("3️⃣ Pattern: DataRequestProtocol (Recommended)")
    let protocolRequest = GetUserRequest(userId: 1)
    do {
        let urlRequest = try protocolRequest.makeURLRequest()
        print("   🔗 URL: \(urlRequest.url?.absoluteString ?? "unknown")")
        print("   ⚡ Clean, type-safe, and testable!")
    } catch {
        print("   ❌ Error: \(error)")
    }
} 