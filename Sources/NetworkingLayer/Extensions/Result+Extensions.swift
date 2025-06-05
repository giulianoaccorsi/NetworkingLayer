//
//  Result+Extensions.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation
import OSLog

public extension Result {
    
    // MARK: - Value Extraction
    
    /// Converts a Result to an optional value, discarding the error
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Converts a Result to an optional error, discarding the success value
    var error: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    // MARK: - State Checking
    
    /// Checks if the Result is a success
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Checks if the Result is a failure
    var isFailure: Bool {
        !isSuccess
    }
    
    // MARK: - Transformations
    
    /// Applies a transformation to the success value, keeping the error unchanged
    func map<NewSuccess>(_ transform: (Success) throws -> NewSuccess) rethrows -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return .success(try transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Applies a transformation that can fail to the success value
    func flatMap<NewSuccess>(_ transform: (Success) throws -> Result<NewSuccess, Failure>) rethrows -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return try transform(value)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Transforms the error into a new error type
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(transform(error))
        }
    }
    
    /// Applies a transformation that can fail to the error
    func flatMapError<NewFailure>(_ transform: (Failure) throws -> Result<Success, NewFailure>) rethrows -> Result<Success, NewFailure> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return try transform(error)
        }
    }
    
    // MARK: - Side Effects
    
    /// Executes a closure only on success
    func onSuccess(_ action: (Success) throws -> Void) rethrows -> Result<Success, Failure> {
        if case .success(let value) = self {
            try action(value)
        }
        return self
    }
    
    /// Executes a closure only on failure
    func onFailure(_ action: (Failure) throws -> Void) rethrows -> Result<Success, Failure> {
        if case .failure(let error) = self {
            try action(error)
        }
        return self
    }
    
    /// Executes specific closures for success and failure
    func handle(
        onSuccess: (Success) throws -> Void,
        onFailure: (Failure) throws -> Void
    ) rethrows {
        switch self {
        case .success(let value):
            try onSuccess(value)
        case .failure(let error):
            try onFailure(error)
        }
    }
    
    // MARK: - Default Values
    
    /// Provides a default value on failure
    func withDefault(_ defaultValue: Success) -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return defaultValue
        }
    }
    
    /// Provides a default value using a closure on failure
    func withDefault(_ defaultValue: () throws -> Success) rethrows -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return try defaultValue()
        }
    }
    
    // MARK: - Error Recovery
    
    /// Recovers from an error with a new value
    func recover(_ recovery: (Failure) throws -> Success) rethrows -> Result<Success, Never> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .success(try recovery(error))
        }
    }
    
    /// Attempts to recover from an error, maintaining the possibility of failure
    func tryRecover(_ recovery: (Failure) throws -> Result<Success, Failure>) rethrows -> Result<Success, Failure> {
        switch self {
        case .success:
            return self
        case .failure(let error):
            return try recovery(error)
        }
    }
}

// MARK: - Void Success Extensions

public extension Result where Success == Void {
    
    /// Creates a successful Result with Void
    static var success: Result<Void, Failure> {
        .success(())
    }
    
    /// Executes a closure only on success
    func onSuccess(_ action: () throws -> Void) rethrows -> Result<Success, Failure> {
        if case .success = self {
            try action()
        }
        return self
    }
}

// MARK: - Error Type Extensions

public extension Result where Failure == Error {
    
    /// Creates a Result capturing any error that might be thrown
    init(catching body: () throws -> Success) {
        do {
            self = .success(try body())
        } catch {
            self = .failure(error)
        }
    }
    
    /// Creates an async Result capturing any error that might be thrown
    init(catching body: () async throws -> Success) async {
        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
}

// MARK: - Async/Await Conversions

public extension Result {
    
    /// Converts a Result to async/await, throwing the error on failure
    func async() async throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Array of Results Utilities

public extension Array where Element: ResultProtocol {
    
    /// Separates an array of Results into successes and failures
    var partitioned: (successes: [Element.Success], failures: [Element.Failure]) {
        var successes: [Element.Success] = []
        var failures: [Element.Failure] = []
        
        for result in self {
            switch result.result {
            case .success(let value):
                successes.append(value)
            case .failure(let error):
                failures.append(error)
            }
        }
        
        return (successes, failures)
    }
    
    /// Returns only the success values
    var successes: [Element.Success] {
        compactMap { $0.result.value }
    }
    
    /// Returns only the errors
    var failures: [Element.Failure] {
        compactMap { $0.result.error }
    }
}

// MARK: - Helper Protocol for Arrays

public protocol ResultProtocol {
    associatedtype Success
    associatedtype Failure: Error
    
    var result: Result<Success, Failure> { get }
}

extension Result: ResultProtocol {
    public var result: Result<Success, Failure> {
        return self
    }
}

// MARK: - Custom Operators

precedencegroup ResultOperatorPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator ??= : ResultOperatorPrecedence

/// Operator that applies a default value on failure
public func ??= <Success, Failure>(
    lhs: inout Success,
    rhs: Result<Success, Failure>
) {
    if case .success(let value) = rhs {
        lhs = value
    }
}

// MARK: - Debugging and Logging

public extension Result {
    
    /// Prints the result for debugging
    func debug(_ message: String = "") -> Result<Success, Failure> {
        switch self {
        case .success(let value):
            print("✅ \(message) Success: \(value)")
        case .failure(let error):
            print("❌ \(message) Failure: \(error)")
        }
        return self
    }
    
    /// Applies logging using os.log
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    func log(
        _ message: String = "",
        logger: Logger = Logger(subsystem: "Result", category: "debug")
    ) -> Result<Success, Failure> {
        switch self {
        case .success(let value):
            logger.info("✅ \(message) Success: \(String(describing: value))")
        case .failure(let error):
            logger.error("❌ \(message) Failure: \(String(describing: error))")
        }
        return self
    }
}
