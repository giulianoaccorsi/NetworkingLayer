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

        guard let urlRequestURL = try request.makeURLRequest().url else {
            throw ServiceError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: urlRequestURL)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.noResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw ServiceError.invalidStatusCode(httpResponse.statusCode)
        }


        return try request.decode(data)
    }
}
