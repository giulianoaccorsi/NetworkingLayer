//
//  NetworkLogger.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation
import OSLog

public protocol NetworkLogging: Sendable {
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: HTTPURLResponse, data: Data)
    func logError(_ error: Error, for request: URLRequest)
}

public final class NetworkLogger: NetworkLogging {
    private let logger: Logger
    private let isEnabled: Bool
    
    public init(
        subsystem: String = "NetworkPackage",
        category: String = "network",
        isEnabled: Bool = true
    ) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.isEnabled = isEnabled
    }
    
    public func logRequest(_ request: URLRequest) {
        guard isEnabled else { return }
        
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown"
        
        logger.info("🌐 \(method) \(url)")
        
        // Log headers em debug
        #if DEBUG
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logger.debug("📋 Headers: \(String(describing: headers))")
        }
        
        if let body = request.httpBody {
            logger.debug("📦 Body size: \(body.count) bytes")
        }
        #endif
    }
    
    public func logResponse(_ response: HTTPURLResponse, data: Data) {
        guard isEnabled else { return }
        
        let statusCode = response.statusCode
        let dataSize = data.count
        let url = response.url?.absoluteString ?? "unknown"
        
        if 200..<300 ~= statusCode {
            logger.info("✅ \(statusCode) \(url) - \(dataSize) bytes")
        } else {
            logger.warning("⚠️ \(statusCode) \(url) - \(dataSize) bytes")
        }
        
        #if DEBUG
        if let headers = response.allHeaderFields as? [String: String], !headers.isEmpty {
            logger.debug("📋 Response Headers: \(headers)")
        }
        #endif
    }
    
    public func logError(_ error: Error, for request: URLRequest) {
        guard isEnabled else { return }
        
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown"
        
        logger.error("❌ \(method) \(url) - Error: \(error.localizedDescription)")
    }
}

// MARK: - Silent Logger (for production)
public final class SilentNetworkLogger: NetworkLogging {
    public init() {}
    
    public func logRequest(_ request: URLRequest) {}
    public func logResponse(_ response: HTTPURLResponse, data: Data) {}
    public func logError(_ error: Error, for request: URLRequest) {}
}
