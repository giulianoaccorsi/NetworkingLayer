import Foundation

// MARK: - API Response Models

/// Represents a blog post from JSONPlaceholder API
struct Post: Codable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

/// Represents a user from JSONPlaceholder API
struct User: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let username: String
    let website: String?
    
    // API might return additional fields, but we only need these
    private enum CodingKeys: String, CodingKey {
        case id, name, email, username, website
    }
}

/// Represents a comment from JSONPlaceholder API
struct Comment: Codable, Sendable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

// MARK: - Request Data Models

/// Data structure for creating new posts
struct CreatePostData: Codable, Sendable {
    let userId: Int
    let title: String
    let body: String
}

/// Data structure for updating user information
struct UpdateUserData: Codable, Sendable {
    let name: String
    let email: String
    let website: String?
} 