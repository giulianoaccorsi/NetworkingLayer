//
//  AdvancedRequests.swift
//  NetworkingExample
//
//  Created by Giuliano Accorsi on 05/06/25.
//


import Foundation
import NetworkingLayer

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
