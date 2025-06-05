//
//  NetworkConfiguration.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

public struct NetworkConfiguration: Sendable {
    public let baseURL: String
    public let defaultHeaders: [String: String]
    public let timeoutInterval: TimeInterval
    public let cachePolicy: URLRequest.CachePolicy
    
    public init(
        baseURL: String,
        defaultHeaders: [String: String] = [:],
        timeoutInterval: TimeInterval = 30.0,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
    }
    
    public static let `default` = NetworkConfiguration(
        baseURL: "",
        defaultHeaders: [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    )
}
