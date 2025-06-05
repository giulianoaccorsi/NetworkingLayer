//
//  APIModels.swift
//  NetworkingExample
//
//  Created by Giuliano Accorsi on 05/06/25.
//


import Foundation

struct Post: Codable, Sendable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct User: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
    let username: String
    let website: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, email, username, website
    }
}

struct Comment: Codable, Sendable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

struct CreatePostData: Codable, Sendable {
    let userId: Int
    let title: String
    let body: String
}

struct UpdateUserData: Codable, Sendable {
    let name: String
    let email: String
    let website: String?
} 
