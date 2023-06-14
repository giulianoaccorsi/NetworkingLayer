//
//  NetworkProtocol.swift
//  
//
//  Created by Giuliano Accorsi on 13/06/23.
//

import Foundation

public protocol DataRequest {

    associatedtype Response: Decodable

    var url: String { get }
    var method: HTTPMethod { get }
    var headers: [String : String] { get }
    var queryItems: [String : String] { get }
    var decoder: JSONDecoder { get }

    func makeURLRequest() throws -> URLRequest
    func decode(_ data: Data) throws -> Response
}

public extension DataRequest {

    var headers: [String : String] {
        [:]
    }

    var queryItems: [String : String] {
        [:]
    }

    var decoder: JSONDecoder {
        JSONDecoder()
    }

    func makeURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: url) else {
            throw ServiceError.badURL
        }

        urlComponents.queryItems = queryItems.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }

        guard let finalURL = urlComponents.url else {
            throw ServiceError.badURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        return request
    }

    func decode(_ data: Data) throws -> Response {
        try decoder.decode(Response.self, from: data)
    }
}
