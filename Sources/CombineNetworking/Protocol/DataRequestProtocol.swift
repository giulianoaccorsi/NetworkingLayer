//
//  DataRequestProtocol.swift
//
//
//  Created by Giuliano Accorsi on 27/06/24.
//


import Foundation
import Commons
import Combine

public protocol DataRequestProtocol {
    associatedtype Response: Decodable

    var domain: String { get }
    var path: String { get }
    var method: Commons.HTTPMethod { get }
    var headers: [String : String] { get }
    var queryItems: [String : String] { get }
    var decoder: JSONDecoder { get }
    var body: Data? { get }

    func makeURLRequestPublisher() -> AnyPublisher<URLRequest, Error>
    func decode(_ data: Data) -> AnyPublisher<Response, Error>
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

    func makeURLRequestPublisher() -> AnyPublisher<URLRequest, Error> {
        let result: Result<URLRequest, Error> = {
            let fullPath = self.domain + self.path
            guard var urlComponents = URLComponents(string: fullPath) else {
                return .failure(ServiceError.badURL)
            }

            urlComponents.queryItems = self.queryItems.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }

            guard let finalURL = urlComponents.url else {
                return .failure(ServiceError.badURL)
            }

            var request = URLRequest(url: finalURL)
            request.httpMethod = self.method.rawValue
            request.allHTTPHeaderFields = self.headers
            request.httpBody = self.body

            return .success(request)
        }()

        return result.publisher.eraseToAnyPublisher()
    }

    func decode(_ data: Data) -> AnyPublisher<Response, Error> {
        let result: Result<Response, Error> = {
            do {
                let response = try self.decoder.decode(Response.self, from: data)
                return .success(response)
            } catch {
                return .failure(error)
            }
        }()

        return result.publisher.eraseToAnyPublisher()
    }
}
