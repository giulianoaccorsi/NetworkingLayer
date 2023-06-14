//
//  NetworkProtocol.swift
//  
//
//  Created by Giuliano Accorsi on 13/06/23.
//

import Foundation

public protocol DataRequest {
    associatedtype Response
    
    var url: String { get }
    var method: HTTPMethod { get }
    var headers: [String : String] { get }
    var queryItems: [String : String] { get }

    func decode(_ data: Data) throws -> Response
}

public extension DataRequest where Response: Decodable {
    func decode(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}

public extension DataRequest {
    var headers: [String : String] {
        [:]
    }

    var queryItems: [String : String] {
        [:]
    }
}
