//
//  ServiceError.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

public enum ServiceError: Error, Sendable {
    case invalidEndpoint
    case badURL
    case noResponse
    case invalidStatusCode(Int)
    case noData
    case networkError(Error)
    case decodingError(Error)
    case timeout
    
    public var localizedDescription: String {
        switch self {
        case .invalidEndpoint:
            return NSLocalizedString(
                "network.error.invalid_endpoint",
                value: "The endpoint provided is invalid.",
                comment: "Invalid Endpoint"
            )
        case .badURL:
            return NSLocalizedString(
                "network.error.bad_url",
                value: "The URL provided is malformed.",
                comment: "Bad URL"
            )
        case .noResponse:
            return NSLocalizedString(
                "network.error.no_response",
                value: "No response was received from the server.",
                comment: "No Response"
            )
        case .invalidStatusCode(let statusCode):
            return NSLocalizedString(
                "network.error.invalid_status_code",
                value: "Received an invalid status code: \(statusCode).",
                comment: "Invalid Status Code"
            )
        case .noData:
            return NSLocalizedString(
                "network.error.no_data",
                value: "No data was returned by the server.",
                comment: "No Data"
            )
        case .networkError(let error):
            return NSLocalizedString(
                "network.error.network_error",
                value: "Network error: \(error.localizedDescription)",
                comment: "Network Error"
            )
        case .decodingError(let error):
            return NSLocalizedString(
                "network.error.decoding_error",
                value: "Failed to decode response: \(error.localizedDescription)",
                comment: "Decoding Error"
            )
        case .timeout:
            return NSLocalizedString(
                "network.error.timeout",
                value: "Request timed out.",
                comment: "Timeout"
            )
        }
    }
}

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        return localizedDescription
    }
    
    public var failureReason: String? {
        switch self {
        case .invalidEndpoint:
            return NSLocalizedString(
                "network.failure.invalid_endpoint",
                value: "The endpoint specified is not valid and cannot be reached.",
                comment: "Invalid Endpoint Failure Reason"
            )
        case .badURL:
            return NSLocalizedString(
                "network.failure.bad_url",
                value: "The URL is not correctly formatted.",
                comment: "Bad URL Failure Reason"
            )
        case .noResponse:
            return NSLocalizedString(
                "network.failure.no_response",
                value: "The server did not respond to the request.",
                comment: "No Response Failure Reason"
            )
        case .invalidStatusCode(let statusCode):
            return NSLocalizedString(
                "network.failure.invalid_status_code",
                value: "The server responded with a status code that indicates failure: \(statusCode).",
                comment: "Invalid Status Code Failure Reason"
            )
        case .noData:
            return NSLocalizedString(
                "network.failure.no_data",
                value: "The response did not contain any data.",
                comment: "No Data Failure Reason"
            )
        case .networkError:
            return NSLocalizedString(
                "network.failure.network_error",
                value: "A network error occurred.",
                comment: "Network Error Failure Reason"
            )
        case .decodingError:
            return NSLocalizedString(
                "network.failure.decoding_error",
                value: "Failed to process the server response.",
                comment: "Decoding Error Failure Reason"
            )
        case .timeout:
            return NSLocalizedString(
                "network.failure.timeout",
                value: "The request took too long to complete.",
                comment: "Timeout Failure Reason"
            )
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidEndpoint:
            return NSLocalizedString(
                "network.recovery.invalid_endpoint",
                value: "Please check the endpoint and try again.",
                comment: "Invalid Endpoint Recovery Suggestion"
            )
        case .badURL:
            return NSLocalizedString(
                "network.recovery.bad_url",
                value: "Please ensure the URL is correct and try again.",
                comment: "Bad URL Recovery Suggestion"
            )
        case .noResponse:
            return NSLocalizedString(
                "network.recovery.no_response",
                value: "Please check your internet connection or try again later.",
                comment: "No Response Recovery Suggestion"
            )
        case .invalidStatusCode:
            return NSLocalizedString(
                "network.recovery.invalid_status_code",
                value: "Please contact support or try again later.",
                comment: "Invalid Status Code Recovery Suggestion"
            )
        case .noData:
            return NSLocalizedString(
                "network.recovery.no_data",
                value: "Please try again later or contact support.",
                comment: "No Data Recovery Suggestion"
            )
        case .networkError, .timeout:
            return NSLocalizedString(
                "network.recovery.network_error",
                value: "Please check your internet connection and try again.",
                comment: "Network Error Recovery Suggestion"
            )
        case .decodingError:
            return NSLocalizedString(
                "network.recovery.decoding_error",
                value: "Please try again or contact support if the problem persists.",
                comment: "Decoding Error Recovery Suggestion"
            )
        }
    }
}
