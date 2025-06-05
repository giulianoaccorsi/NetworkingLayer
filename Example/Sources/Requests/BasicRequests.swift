import Foundation
import NetworkingLayer

// MARK: - Basic API Requests

/// Simple request to fetch all posts
struct GetPostsRequest: DataRequestProtocol {
    typealias Response = [Post]
    
    let domain = "https://jsonplaceholder.typicode.com"
    let path = "/posts"
    let method = HTTPMethod.get
}

/// Request to fetch a specific user by ID
struct GetUserRequest: DataRequestProtocol {
    typealias Response = User
    
    let userId: Int
    
    let domain = "https://jsonplaceholder.typicode.com"
    var path: String { "/users/\(userId)" }
    let method = HTTPMethod.get
} 