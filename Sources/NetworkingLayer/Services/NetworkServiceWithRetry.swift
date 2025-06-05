//
//  NetworkServiceWithRetry.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation
import OSLog

public final class NetworkServiceWithRetry: NetworkService {
    private let baseService: NetworkService
    private let retryPolicy: RetryPolicy
    private let logger: Logger
    
    public init(
        baseService: NetworkService = DefaultNetworkService(),
        retryPolicy: RetryPolicy = DefaultRetryPolicy()
    ) {
        self.baseService = baseService
        self.retryPolicy = retryPolicy
        self.logger = Logger(subsystem: "NetworkPackage", category: "retry")
    }
    
    public func request<Request: DataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response {
        
        var lastError: Error?
        
        for attempt in 0...retryPolicy.maxRetries {
            do {
                let result = try await baseService.request(request)
                
                if attempt > 0 {
                    logger.info("✅ Request succeeded after \(attempt) retries")
                }
                
                return result
                
            } catch {
                lastError = error
                
                guard retryPolicy.shouldRetry(for: error, attempt: attempt) else {
                    logger.warning("🚫 Not retrying for error: \(error.localizedDescription)")
                    throw error
                }
                
                if attempt < retryPolicy.maxRetries {
                    let delay = retryPolicy.delay(for: attempt)
                    
                    logger.info("🔄 Retrying in \(delay)s (attempt \(attempt + 1)/\(self.retryPolicy.maxRetries))")
                    
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                } else {
                    logger.error("❌ All retry attempts exhausted")
                }
            }
        }
        
        throw lastError ?? ServiceError.networkError(URLError(.unknown))
    }
}

// MARK: - Convenience Initializers

public extension NetworkServiceWithRetry {
    
    static func withExponentialBackoff(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0
    ) -> NetworkServiceWithRetry {
        let retryPolicy = DefaultRetryPolicy(
            maxRetries: maxRetries,
            baseDelay: baseDelay,
            maxDelay: maxDelay,
            backoffMultiplier: 2.0
        )
        
        return NetworkServiceWithRetry(retryPolicy: retryPolicy)
    }
    
    static func withLinearRetry(
        maxRetries: Int = 3,
        delay: TimeInterval = 1.0
    ) -> NetworkServiceWithRetry {
        let retryPolicy = LinearRetryPolicy(
            maxRetries: maxRetries,
            delay: delay
        )
        
        return NetworkServiceWithRetry(retryPolicy: retryPolicy)
    }
    
    static func withoutRetry() -> NetworkServiceWithRetry {
        return NetworkServiceWithRetry(retryPolicy: NoRetryPolicy())
    }
}
