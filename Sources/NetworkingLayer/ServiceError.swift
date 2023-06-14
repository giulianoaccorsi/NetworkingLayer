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
    case taskError
    case noResponse
    case invalidStatusCode(Int)
    case unauthorized
    case unknown

    var localizedDescription: String {
        switch self {
        case .invalidEndpoint:
            return "Endpoint Inválido"
        case .badURL:
            return "URL Inválida :("
        case .taskError:
            return "Erro na Requisição"
        case .noResponse:
            return "Servidor não respondeu"
        case .invalidStatusCode(let statusCode):
            return "Status Code Inválido - \(statusCode)"
        case .unknown:
            return "Erro desconhecido"
        case .unauthorized:
            return "Não autorizado"
        }
    }
}
