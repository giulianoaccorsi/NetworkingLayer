//
//  RetryPolicy.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

// MARK: - Retry Policy Protocol

public protocol RetryPolicy: Sendable {
    var maxRetries: Int { get }
    func shouldRetry(for error: Error, attempt: Int) -> Bool
    func delay(for attempt: Int) -> TimeInterval
}

// MARK: - Default Exponential Backoff Policy

public struct DefaultRetryPolicy: RetryPolicy {
    public let maxRetries: Int
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval
    private let backoffMultiplier: Double
    
    public init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        backoffMultiplier: Double = 2.0
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.backoffMultiplier = backoffMultiplier
    }
    
    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }
        
        // Don't retry for client errors (4xx)
        if case ServiceError.invalidStatusCode(let code) = error,
           400..<500 ~= code {
            return false
        }
        
        // Don't retry for decoding errors
        if case ServiceError.decodingError = error {
            return false
        }
        
        // Retry for network errors and server errors (5xx)
        return true
    }
    
    public func delay(for attempt: Int) -> TimeInterval {
        let delay = baseDelay * pow(backoffMultiplier, Double(attempt))
        return min(delay, maxDelay)
    }
}

// MARK: - No Retry Policy

public struct NoRetryPolicy: RetryPolicy {
    public let maxRetries: Int = 0
    
    public init() {}
    
    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        false
    }
    
    public func delay(for attempt: Int) -> TimeInterval {
        0
    }
}

// MARK: - Linear Retry Policy

public struct LinearRetryPolicy: RetryPolicy {
    public let maxRetries: Int
    private let delay: TimeInterval
    
    public init(maxRetries: Int = 3, delay: TimeInterval = 1.0) {
        self.maxRetries = maxRetries
        self.delay = delay
    }
    
    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }
        
        // Don't retry for client errors (4xx)
        if case ServiceError.invalidStatusCode(let code) = error,
           400..<500 ~= code {
            return false
        }
        
        // Don't retry for decoding errors
        if case ServiceError.decodingError = error {
            return false
        }
        
        return true
    }
    
    public func delay(for attempt: Int) -> TimeInterval {
        delay
    }
}

// MARK: - Jittered Exponential Backoff Policy

public struct JitteredRetryPolicy: RetryPolicy {
    public let maxRetries: Int
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval
    private let backoffMultiplier: Double
    private let jitterRange: ClosedRange<Double>
    
    public init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        backoffMultiplier: Double = 2.0,
        jitterRange: ClosedRange<Double> = 0.0...0.1
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.backoffMultiplier = backoffMultiplier
        self.jitterRange = jitterRange
    }
    
    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }
        
        // Don't retry for client errors (4xx)
        if case ServiceError.invalidStatusCode(let code) = error,
           400..<500 ~= code {
            return false
        }
        
        // Don't retry for decoding errors
        if case ServiceError.decodingError = error {
            return false
        }
        
        return true
    }
    
    public func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = baseDelay * pow(backoffMultiplier, Double(attempt))
        let jitter = Double.random(in: jitterRange) * exponentialDelay
        let delayWithJitter = exponentialDelay + jitter
        return min(delayWithJitter, maxDelay)
    }
}

// MARK: - Custom Condition Policy

public struct CustomRetryPolicy: RetryPolicy {
    public let maxRetries: Int
    private let delayCalculation: @Sendable (Int) -> TimeInterval
    private let retryCondition: @Sendable (Error, Int) -> Bool
    
    public init(
        maxRetries: Int,
        delayCalculation: @escaping @Sendable (Int) -> TimeInterval,
        retryCondition: @escaping @Sendable (Error, Int) -> Bool
    ) {
        self.maxRetries = maxRetries
        self.delayCalculation = delayCalculation
        self.retryCondition = retryCondition
    }
    
    public func shouldRetry(for error: Error, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }
        return retryCondition(error, attempt)
    }
    
    public func delay(for attempt: Int) -> TimeInterval {
        delayCalculation(attempt)
    }
}

// MARK: - Factory Methods

public extension RetryPolicy where Self == DefaultRetryPolicy {
    /// Creates a default exponential backoff retry policy
    static var `default`: DefaultRetryPolicy {
        DefaultRetryPolicy()
    }
    
    /// Creates an exponential backoff policy with custom parameters
    static func exponential(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        multiplier: Double = 2.0
    ) -> DefaultRetryPolicy {
        DefaultRetryPolicy(
            maxRetries: maxRetries,
            baseDelay: baseDelay,
            maxDelay: maxDelay,
            backoffMultiplier: multiplier
        )
    }
    
    /// Creates a linear retry policy
    static func linear(
        maxRetries: Int = 3,
        delay: TimeInterval = 1.0
    ) -> LinearRetryPolicy {
        LinearRetryPolicy(maxRetries: maxRetries, delay: delay)
    }
    
    /// Creates a jittered exponential backoff policy
    static func jittered(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        multiplier: Double = 2.0,
        jitterRange: ClosedRange<Double> = 0.0...0.1
    ) -> JitteredRetryPolicy {
        JitteredRetryPolicy(
            maxRetries: maxRetries,
            baseDelay: baseDelay,
            maxDelay: maxDelay,
            backoffMultiplier: multiplier,
            jitterRange: jitterRange
        )
    }
    
    /// Creates a policy with no retries
    static var none: NoRetryPolicy {
        NoRetryPolicy()
    }
    
    /// Creates a custom retry policy
    static func custom(
        maxRetries: Int,
        delayCalculation: @escaping @Sendable (Int) -> TimeInterval,
        retryCondition: @escaping @Sendable (Error, Int) -> Bool
    ) -> CustomRetryPolicy {
        CustomRetryPolicy(
            maxRetries: maxRetries,
            delayCalculation: delayCalculation,
            retryCondition: retryCondition
        )
    }
}

// MARK: - Convenience Extensions

public extension RetryPolicy {
    /// Checks if the error should be retried based on common patterns
    func shouldRetryCommonErrors(for error: Error, attempt: Int) -> Bool {
        guard attempt < maxRetries else { return false }
        
        // Check for network connectivity issues
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .timedOut,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .dnsLookupFailed:
                return true
            default:
                return false
            }
        }
        
        // Check for service errors
        if case ServiceError.invalidStatusCode(let code) = error {
            // Retry server errors (5xx) but not client errors (4xx)
            return 500..<600 ~= code
        }
        
        // Don't retry decoding errors
        if case ServiceError.decodingError = error {
            return false
        }
        
        // Retry network errors by default
        if case ServiceError.networkError = error {
            return true
        }
        
        return false
    }
}
