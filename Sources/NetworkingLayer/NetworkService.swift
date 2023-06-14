//
//  NetworkService.swift
//  
//
//  Created by Giuliano Accorsi on 13/06/23.
//

import Foundation

public protocol NetworkService {
    func request<Request: DataRequest>(_ request: Request) async throws -> Request.Response
}


public final class DefaultNetworkService: NetworkService {

    public init() {}

    public func request<Request: DataRequest>(_ request: Request) async throws -> Request.Response {

        guard var urlComponent = URLComponents(string: request.url) else {
            throw NSError(
                domain: ServiceError.invalidEndpoint.localizedDescription,
                code: 404,
                userInfo: nil
            )
        }

        var queryItems: [URLQueryItem] = []

        request.queryItems.forEach {
            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
            urlComponent.queryItems?.append(urlQueryItem)
            queryItems.append(urlQueryItem)
        }

        urlComponent.queryItems = queryItems

        guard let url = urlComponent.url else {
            throw NSError(
                domain: ServiceError.invalidEndpoint.localizedDescription,
                code: 404,
                userInfo: nil
            )
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers

        guard let urlRequestURL = urlRequest.url else {
            throw NSError(
                domain: ServiceError.invalidEndpoint.localizedDescription,
                code: 404,
                userInfo: nil
            )
        }

        let (data, response) = try await URLSession.shared.data(from: urlRequestURL)

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NSError(
                domain: ServiceError.invalidEndpoint.localizedDescription,
                code: 404,
                userInfo: nil
            )
        }

        return try request.decode(data)
    }
}
