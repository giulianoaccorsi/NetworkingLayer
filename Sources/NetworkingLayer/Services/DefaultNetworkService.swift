//
//  DefaultNetworkService.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation
import OSLog

public final class DefaultNetworkService: NetworkService {
    private let session: URLSession
    private let logger: NetworkLogging
    private let responseValidator: ResponseValidating
    
    public init(
        session: URLSession = .shared,
        logger: NetworkLogging = NetworkLogger(),
        responseValidator: ResponseValidating = DefaultResponseValidator()
    ) {
        self.session = session
        self.logger = logger
        self.responseValidator = responseValidator
    }
    
    public func request<Request: DataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response {
        
        let urlRequest = try request.makeURLRequest()
        
        try urlRequest.validate()
        
        logger.logRequest(urlRequest)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = ServiceError.noResponse
                logger.logError(error, for: urlRequest)
                throw error
            }
            
            logger.logResponse(httpResponse, data: data)
            
            try responseValidator.validate(response: httpResponse, data: data)
            
            do {
                return try request.decode(data)
            } catch {
                let decodingError = ServiceError.decodingError(error)
                logger.logError(decodingError, for: urlRequest)
                throw decodingError
            }
            
        } catch let error as ServiceError {
            logger.logError(error, for: urlRequest)
            throw error
        } catch {
            let networkError = ServiceError.networkError(error)
            logger.logError(networkError, for: urlRequest)
            throw networkError
        }
    }
}
