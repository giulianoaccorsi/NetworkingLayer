//
//  main.swift
//  NetworkingExample
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation
import NetworkingLayer

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}

struct BuilderPatternsDemo {
    static func runDemo() async {
        print("🚀 NetworkingLayer Builder Patterns Demo")
        print("=" * 50)
        
        let service = DefaultNetworkService()
        
        await demoDataRequestProtocol(service: service)
        await demoURLRequestBuilder()
        await demoRequestConfigurator()
        await demoResultBuilder()
        await demoRetryPolicies()
        await demoErrorHandling()
        
        print("\n✅ All builder patterns demonstrated successfully!")
    }
}

func demoDataRequestProtocol(service: NetworkService) async {
    print("\n🎯 DataRequestProtocol Pattern")
    print("-" * 40)
    
    do {
        print("📥 Fetching posts...")
        let posts = try await service.request(GetPostsRequest())
        print("✅ Fetched \(posts.count) posts")
        
        print("📄 Fetching paginated posts...")
        let paginatedPosts = try await service.request(PostsWithPaginationRequest(page: 1, limit: 3))
        print("✅ Fetched \(paginatedPosts.count) posts (page 1)")
        
        print("📝 Creating new post...")
        let postData = CreatePostData(userId: 1, title: "New Post", body: "Post content")
        let newPost = try await service.request(CreatePostRequest(postData: postData))
        print("✅ Created post with ID: \(newPost.id)")
        
    } catch {
        print("❌ Error: \(error.localizedDescription)")
    }
}

func demoURLRequestBuilder() async {
    print("\n🔧 URLRequestBuilder Pattern")
    print("-" * 40)
    
    do {
        print("🌐 Building GET request...")
        let getRequest = try URLRequestBuilder
            .get("https://jsonplaceholder.typicode.com/posts")
            .accept("application/json")
            .userAgent("NetworkingLayer-Demo/1.0")
            .queryItems(["_limit": "2"])
            .timeout(15)
            .build()
        
        let (data, _) = try await URLSession.shared.data(for: getRequest)
        let posts = try JSONDecoder().decode([Post].self, from: data)
        print("✅ Fetched \(posts.count) posts using URLRequestBuilder")
        
        print("📤 Building POST request...")
        let postData = CreatePostData(userId: 1, title: "Builder Post", body: "Created with URLRequestBuilder")
        
        let postRequest = try URLRequestBuilder()
            .url("https://jsonplaceholder.typicode.com/posts")
            .post()
            .contentType("application/json")
            .bearerToken("demo-token-123")
            .jsonBody(postData)
            .build()
        
        let (responseData, _) = try await URLSession.shared.data(for: postRequest)
        let createdPost = try JSONDecoder().decode(Post.self, from: responseData)
        print("✅ Created post with ID: \(createdPost.id)")

        print("📋 Building form data request...")
        let formRequest = try URLRequestBuilder()
            .url("https://jsonplaceholder.typicode.com/posts")
            .post()
            .formBody([
                "title": "Form Post",
                "body": "Created using form data",
                "userId": "1"
            ])
            .header("X-Form-Type", "demo")
            .build()
        
        let (formData, _) = try await URLSession.shared.data(for: formRequest)
        let formPost = try JSONDecoder().decode(Post.self, from: formData)
        print("✅ Created form post with ID: \(formPost.id)")
        
    } catch {
        print("❌ URLRequestBuilder Error: \(error.localizedDescription)")
    }
}

func demoRequestConfigurator() async {
    print("\n⚙️ RequestConfigurator Pattern")
    print("-" * 40)
    
    do {
        print("🔗 Using fluent API...")
        let request = RequestConfigurator(
            url: URL(string: "https://jsonplaceholder.typicode.com/users/1")!
        )
        .header("Accept", "application/json")
        .header("User-Agent", "RequestConfigurator-Demo/1.0")
        .bearerToken("auth-token-456")
        .timeout(20)
        .build()
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let user = try JSONDecoder().decode(User.self, from: data)
        print("✅ Fetched user: \(user.name) (\(user.email))")
        
        print("📝 Complex POST configuration...")
        let postData = CreatePostData(
            userId: 2,
            title: "Configurator Post",
            body: "Created with RequestConfigurator"
        )
        
        let complexRequest = try RequestConfigurator(
            url: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
            method: .post
        )
        .headers([
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-API-Version": "v1"
        ])
        .jsonBody(postData)
        .build()
        
        let (postResponseData, _) = try await URLSession.shared.data(for: complexRequest)
        let createdPost = try JSONDecoder().decode(Post.self, from: postResponseData)
        print("✅ Created post with ID: \(createdPost.id)")
        
    } catch {
        print("❌ RequestConfigurator Error: \(error.localizedDescription)")
    }
}

func demoResultBuilder() async {
    print("\n🏗️ @resultBuilder Pattern")
    print("-" * 40)
    
    do {
        print("🔨 Using result builder syntax...")
        let builderRequest = URLRequest(
            url: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
            method: .get
        ) {
            header("Accept", "application/json")
            header("User-Agent", "ResultBuilder-Demo/1.0")
            query("_limit", "2")
            timeout(15)
        }
        
        let (data, _) = try await URLSession.shared.data(for: builderRequest)
        let posts = try JSONDecoder().decode([Post].self, from: data)
        print("✅ Fetched \(posts.count) posts using @resultBuilder")
        
        print("📤 POST with result builder...")
        let postData = CreatePostData(
            userId: 3,
            title: "Result Builder Post",
            body: "Created using @resultBuilder syntax"
        )
        
        let postRequest = URLRequest(
            url: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
            method: .post
        ) {
            contentType("application/json")
            accept("application/json")
            bearerToken("builder-token-789")
            jsonBody(postData)
        }
        
        let (postResponseData, _) = try await URLSession.shared.data(for: postRequest)
        let createdPost = try JSONDecoder().decode(Post.self, from: postResponseData)
        print("✅ Created post with ID: \(createdPost.id)")
        
    } catch {
        print("❌ Result Builder Error: \(error.localizedDescription)")
    }
}

func demoRetryPolicies() async {
    print("\n🔄 Retry Strategies")
    print("-" * 40)
    
    print("🚫 Testing No Retry...")
    let noRetryService = NetworkServiceWithRetry.withoutRetry()
    do {
        _ = try await noRetryService.request(GetUserRequest(userId: 99999))
    } catch {
        print("✅ No retry - Failed immediately")
    }
    
    print("📈 Testing Linear Retry...")
    let linearService = NetworkServiceWithRetry.withLinearRetry(maxRetries: 2, delay: 0.1)
    do {
        _ = try await linearService.request(GetUserRequest(userId: 99998))
    } catch {
        print("✅ Linear retry - Failed after retries")
    }
    
    print("📊 Testing Exponential Backoff...")
    let exponentialService = NetworkServiceWithRetry.withExponentialBackoff(
        maxRetries: 2,
        baseDelay: 0.1,
        maxDelay: 2.0
    )
    do {
        _ = try await exponentialService.request(GetUserRequest(userId: 99997))
    } catch {
        print("✅ Exponential backoff - Failed after retries")
    }
}

func demoErrorHandling() async {
    print("\n❌ Error Handling")
    print("-" * 40)
    
    let service = DefaultNetworkService()
    print("🔍 Testing 404 error...")
    do {
        _ = try await service.request(GetUserRequest(userId: 99999))
    } catch let error as ServiceError {
        switch error {
        case .invalidStatusCode(let code):
            print("✅ Caught 404 error: \(code)")
            print("   Description: \(error.localizedDescription)")
            print("   Recovery: \(error.recoverySuggestion ?? "None")")
        default:
            print("✅ Other service error: \(error)")
        }
    } catch {
        print("✅ Generic error: \(error)")
    }
    
    print("🌐 Testing bad URL...")
    do {
        let badRequest = try URLRequestBuilder
            .get("invalid-url")
            .build()
        _ = try await URLSession.shared.data(for: badRequest)
    } catch {
        print("✅ Caught bad URL error")
    }
}

await BuilderPatternsDemo.runDemo()
