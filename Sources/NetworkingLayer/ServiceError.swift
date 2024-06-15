//
//  File.swift
//  
//
//  Created by Giuliano Accorsi on 13/06/23.
//

import Foundation
public enum ServiceError: Error {
    case invalidEndpoint
    case badURL
    case noResponse
    case invalidStatusCode(Int)
    case noData

    var localizedDescription: String {
        switch self {
        case .invalidEndpoint:
            return NSLocalizedString(
                "The endpoint provided is invalid.",
                comment: "Invalid Endpoint"
            )
        case .badURL:
            return NSLocalizedString(
                "The URL provided is malformed.",
                comment: "Bad URL"
            )
        case .noResponse:
            return NSLocalizedString(
                "No response was received from the server.",
                comment: "No Response"
            )
        case .invalidStatusCode(
            let statusCode
        ):
            return NSLocalizedString(
                "Received an invalid status code: \(statusCode).",
                comment: "Invalid Status Code"
            )
        case .noData:
            return NSLocalizedString(
                "No data was returned by the server.",
                comment: "No Data"
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
                "The endpoint specified is not valid and cannot be reached.",
                comment: "Invalid Endpoint Failure Reason"
            )
        case .badURL:
            return NSLocalizedString(
                "The URL is not correctly formatted.",
                comment: "Bad URL Failure Reason"
            )
        case .noResponse:
            return NSLocalizedString(
                "The server did not respond to the request.",
                comment: "No Response Failure Reason"
            )
        case .invalidStatusCode(let statusCode):
            return NSLocalizedString(
                "The server responded with a status code that indicates failure: \(statusCode).",
                comment: "Invalid Status Code Failure Reason"
            )
        case .noData:
            return NSLocalizedString(
                "The response did not contain any data.",
                comment: "No Data Failure Reason"
            )
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidEndpoint:
            return NSLocalizedString(
                "Please check the endpoint and try again.",
                comment: "Invalid Endpoint Recovery Suggestion"
            )
        case .badURL:
            return NSLocalizedString(
                "Please ensure the URL is correct and try again.",
                comment: "Bad URL Recovery Suggestion"
            )
        case .noResponse:
            return NSLocalizedString(
                "Please check your internet connection or try again later.",
                comment: "No Response Recovery Suggestion"
            )
        case .invalidStatusCode:
            return NSLocalizedString(
                "Please contact support or try again later.",
                comment: "Invalid Status Code Recovery Suggestion"
            )
        case .noData:
            return NSLocalizedString(
                "Please try again later or contact support.",
                comment: "No Data Recovery Suggestion"
            )
        }
    }
}
