import Foundation

public enum HTTPMethod: String, CaseIterable, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
}

// MARK: - CustomDebugStringConvertible
extension HTTPMethod: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .get: return "🔵 GET"
        case .post: return "🟢 POST"
        case .put: return "🟡 PUT"
        case .delete: return "🔴 DELETE"
        case .patch: return "🟠 PATCH"
        case .head: return "⚪ HEAD"
        case .options: return "🟣 OPTIONS"
        }
    }
} 