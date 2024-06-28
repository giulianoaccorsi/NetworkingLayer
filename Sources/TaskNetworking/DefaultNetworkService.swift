//
//  NetworkService.swift
//  
//
//  Created by Giuliano Accorsi on 13/06/23.
//

import Foundation
import Commons

public protocol NetworkService {
    func request<Request: DataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response
}

public final class DefaultNetworkService: NetworkService {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<Request: DataRequestProtocol>(_ request: Request) async throws -> Request.Response {
        let urlRequest = try request.makeURLRequest()

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.noResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw ServiceError.invalidStatusCode(httpResponse.statusCode)
        }

        return try request.decode(data)
    }
}
