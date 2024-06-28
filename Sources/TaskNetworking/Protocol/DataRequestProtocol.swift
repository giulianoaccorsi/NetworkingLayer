//
//  NetworkProtocol.swift
//
//
//  Created by Giuliano Accorsi on 27/06/24.
//

import Foundation
import Commons

public protocol DataRequestProtocol {

    associatedtype Response: Decodable

    var domain: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String : String] { get }
    var queryItems: [String : String] { get }
    var decoder: JSONDecoder { get }
    var body: Data? { get }

    func makeURLRequest() throws -> URLRequest
    func decode(_ data: Data) throws -> Response
}

public extension DataRequestProtocol {

    var headers: [String : String] {
        [:]
    }

    var queryItems: [String : String] {
        [:]
    }

    var body: Data? {
        nil
    }

    var decoder: JSONDecoder {
        JSONDecoder()
    }

    func makeURLRequest() throws -> URLRequest {
        let fullPath = domain + path
        guard var urlComponents = URLComponents(string: fullPath) else {
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
        request.httpBody = body

        return request
    }

    func decode(_ data: Data) throws -> Response {
        try decoder.decode(Response.self, from: data)
    }
}
