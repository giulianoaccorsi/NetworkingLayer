//
//  BasicRequests.swift
//  NetworkingExample
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation
import NetworkingLayer

struct GetPostsRequest: DataRequestProtocol {
    typealias Response = [Post]
    
    let domain = "https://jsonplaceholder.typicode.com"
    let path = "/posts"
    let method = HTTPMethod.get
}

struct GetUserRequest: DataRequestProtocol {
    typealias Response = User
    
    let userId: Int
    
    let domain = "https://jsonplaceholder.typicode.com"
    var path: String { "/users/\(userId)" }
    let method = HTTPMethod.get
} 
