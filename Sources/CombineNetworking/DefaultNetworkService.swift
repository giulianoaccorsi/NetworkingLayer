//
//  DefaultNetworkService.swift
//
//
//  Created by Giuliano Accorsi on 27/06/24.
//

import Foundation
import Combine
@_exported import Commons

public protocol NetworkService {
    func request<Request: DataRequestProtocol>(
        _ request: Request
    ) -> AnyPublisher<Request.Response, Error>
}

public final class DefaultNetworkService: NetworkService {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func request<Request: DataRequestProtocol>(
        _ request: Request
    ) -> AnyPublisher<Request.Response, Error> {
        
        return request.makeURLRequestPublisher()
            .flatMap { urlRequest in
                self.session.dataTaskPublisher(for: urlRequest)
                    .mapError { $0 as Error }
                    .flatMap { output -> AnyPublisher<Data, Error> in
                        
                        if let httpResponse = output.response as? HTTPURLResponse,
                           200..<300 ~= httpResponse.statusCode {
                            return Result<Data, Error>.Publisher(
                                .success(output.data)
                            ).eraseToAnyPublisher()
                            
                        } else {
                            let statusCode = (output.response as? HTTPURLResponse)?.statusCode ?? 0
                            
                            return Result<Data, Error>.Publisher(
                                .failure(ServiceError.invalidStatusCode(statusCode))
                            ).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { data in
                request.decode(data)
            }
            .eraseToAnyPublisher()
    }
}
