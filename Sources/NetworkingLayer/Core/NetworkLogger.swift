import Foundation
import os.log

public final class NetworkLogger: Sendable {
    private let logger: Logger
    
    public static let shared = NetworkLogger()
    
    private init() {
        self.logger = Logger(subsystem: "com.networkinglayer", category: "networking")
    }
    
    // MARK: - Request Logging
    public func logRequest(_ request: URLRequest) {
        guard #available(iOS 14.0, macOS 11.0, *) else { return }
        
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "Unknown URL"
        
        var logMessage = """
        🚀 [REQUEST] \(method) \(url)
        📋 Headers: \(formatHeaders(request.allHTTPHeaderFields))
        """
        
        if let body = request.httpBody {
            logMessage += "\n📦 Body: \(formatBody(body))"
        }
        
        if request.timeoutInterval != 60.0 {
            logMessage += "\n⏱️ Timeout: \(request.timeoutInterval)s"
        }
        
        logger.info("\(logMessage)")
    }
    
    // MARK: - Response Logging
    public func logResponse(_ response: HTTPURLResponse, data: Data?, duration: TimeInterval) {
        guard #available(iOS 14.0, macOS 11.0, *) else { return }
        
        let statusEmoji = getStatusEmoji(response.statusCode)
        let url = response.url?.absoluteString ?? "Unknown URL"
        let size = formatDataSize(data?.count ?? 0)
        
        var logMessage = """
        \(statusEmoji) [RESPONSE] \(response.statusCode) \(url)
        ⏱️ Duration: \(String(format: "%.3f", duration))s
        📏 Size: \(size)
        """
        
        if !response.allHeaderFields.isEmpty {
            logMessage += "\n📋 Headers: \(formatHeaders(response.allHeaderFields))"
        }
        
        if let data = data, data.count > 0 {
            logMessage += "\n📄 Body: \(formatResponseBody(data))"
        }
        
        if (200...299).contains(response.statusCode) {
            logger.info("\(logMessage)")
        } else {
            logger.error("\(logMessage)")
        }
    }
    
    // MARK: - Error Logging
    public func logError(_ error: Error, for request: URLRequest?, duration: TimeInterval? = nil) {
        guard #available(iOS 14.0, macOS 11.0, *) else { return }
        
        let url = request?.url?.absoluteString ?? "Unknown URL"
        let method = request?.httpMethod ?? "GET"
        
        var logMessage = """
        ❌ [ERROR] \(method) \(url)
        🔥 Error: \(error.localizedDescription)
        """
        
        if let duration = duration {
            logMessage += "\n⏱️ Duration: \(String(format: "%.3f", duration))s"
        }
        
        if let networkError = error as? NetworkError {
            logMessage += "\n🏷️ Type: \(networkError.debugDescription)"
        }
        
        logger.error("\(logMessage)")
    }
    
    // MARK: - Configuration
    public func logConfiguration(_ config: String) {
        guard #available(iOS 14.0, macOS 11.0, *) else { return }
        logger.info("⚙️ [CONFIG] \(config)")
    }
    
    // MARK: - Private Helpers
    private func getStatusEmoji(_ statusCode: Int) -> String {
        switch statusCode {
        case 200...299: return "✅"
        case 300...399: return "↩️"
        case 400...499: return "⚠️"
        case 500...599: return "🔥"
        default: return "❓"
        }
    }
    
    private func formatHeaders(_ headers: [AnyHashable: Any]?) -> String {
        guard let headers = headers, !headers.isEmpty else { return "None" }
        
        let sortedHeaders = headers.sorted { String(describing: $0.key) < String(describing: $1.key) }
        let formattedHeaders = sortedHeaders.map { "\($0.key): \($0.value)" }
        return "\n    " + formattedHeaders.joined(separator: "\n    ")
    }
    
    private func formatBody(_ data: Data) -> String {
        guard data.count > 0 else { return "Empty" }
        
        if data.count > 1024 {
            return "Binary data (\(formatDataSize(data.count)))"
        }
        
        if let string = String(data: data, encoding: .utf8) {
            return string.count > 500 ? String(string.prefix(500)) + "..." : string
        }
        
        return "Binary data (\(formatDataSize(data.count)))"
    }
    
    private func formatResponseBody(_ data: Data) -> String {
        guard data.count > 0 else { return "Empty" }
        
        // Try to format as JSON for better readability
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString.count > 1000 ? String(prettyString.prefix(1000)) + "..." : prettyString
        }
        
        return formatBody(data)
    }
    
    private func formatDataSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Logging Configuration
public struct NetworkLoggingConfig: Sendable {
    public let isEnabled: Bool
    public let logLevel: LogLevel
    public let maxBodySize: Int
    
    public init(isEnabled: Bool = true, logLevel: LogLevel = .info, maxBodySize: Int = 1024) {
        self.isEnabled = isEnabled
        self.logLevel = logLevel
        self.maxBodySize = maxBodySize
    }
    
    public enum LogLevel: Sendable {
        case debug
        case info
        case error
    }
} 