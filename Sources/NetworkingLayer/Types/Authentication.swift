import Foundation

public enum Authentication: Sendable, Equatable {
    case none
    case bearer(String)
    case basic(username: String, password: String)
    case apiKey(String, String)
    
    public func toHeader() -> HTTPHeader? {
        switch self {
        case .none:
            return nil
        case .bearer(let token):
            return .bearer(token)
        case .basic(let username, let password):
            return .basic(username: username, password: password)
        case .apiKey(let key, let value):
            return .custom(key, value)
        }
    }
}

// MARK: - CustomDebugStringConvertible
extension Authentication: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .none:
            return "None"
        case .bearer:
            return "🔑 Bearer Token"
        case .basic:
            return "🔐 Basic Auth"
        case .apiKey(let key, _):
            return "🗝️ API Key (\(key))"
        }
    }
} 