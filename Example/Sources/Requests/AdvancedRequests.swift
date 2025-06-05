import Foundation
import NetworkingLayer

// MARK: - Advanced API Requests

/// Request with pagination using query parameters
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

/// Search request with multiple query parameters and custom headers
struct SearchPostsRequest: DataRequestProtocol {
    typealias Response = [Post]
    
    let query: String
    let userId: Int?
    
    let domain = "https://jsonplaceholder.typicode.com"
    let path = "/posts"
    let method = HTTPMethod.get
    
    var queryItems: [String: String] {
        var items = ["q": query]
        if let userId = userId {
            items["userId"] = String(userId)
        }
        return items
    }
    
    var headers: [String: String] {
        [
            "Accept": "application/json",
            "User-Agent": "NetworkingLayer-Example/1.0"
        ]
    }
}

/// POST request with JSON body
struct CreatePostRequest: DataRequestProtocol {
    typealias Response = Post
    
    let postData: CreatePostData
    
    let domain = "https://jsonplaceholder.typicode.com"
    let path = "/posts"
    let method = HTTPMethod.post
    
    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var body: Data? {
        try? JSONEncoder().encode(postData)
    }
}

/// PUT request with JSON body for updating resources
struct UpdateUserRequest: DataRequestProtocol {
    typealias Response = User
    
    let userId: Int
    let userData: UpdateUserData
    
    let domain = "https://jsonplaceholder.typicode.com"
    var path: String { "/users/\(userId)" }
    let method = HTTPMethod.put
    
    var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    var body: Data? {
        try? JSONEncoder().encode(userData)
    }
} 