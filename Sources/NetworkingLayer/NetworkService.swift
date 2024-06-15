//
//  NetworkService.swift
//  
//
//  Created by Giuliano Accorsi on 13/06/23.
//

import Foundation
import Combine

public protocol NetworkService {
    func request<Request: DataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response

    func request<Request: DataRequestProtocol>(
        _ request: Request
    )  throws -> AnyPublisher<Request.Response, Error>
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

    public func request<Request: DataRequestProtocol>(_ request: Request) throws -> AnyPublisher<Request.Response, Error> {
        let urlRequest = try request.makeURLRequest()

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw ServiceError.invalidStatusCode((output.response as? HTTPURLResponse)?.statusCode ?? 0)
                }
                return output.data
            }
            .tryMap { data in
                guard !data.isEmpty else {
                    throw ServiceError.badURL
                }
                return data
            }
            .decode(type: Request.Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
