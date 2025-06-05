//
//  NetworkServiceProtocol.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

// MARK: - Network Service Protocol
public protocol NetworkService: Sendable {
    func request<Request: DataRequestProtocol>(
        _ request: Request
    ) async throws -> Request.Response
}
