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

    var localizedDescription: String {
        switch self {
        case .invalidEndpoint:
            return "Endpoint Inválido"
        case .badURL:
            return "URL Inválida :("
        case .noResponse:
            return "Servidor não respondeu"
        case .invalidStatusCode(let statusCode):
            return "Status Code Inválido - \(statusCode)"
        }
    }
}
