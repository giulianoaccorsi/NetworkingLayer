import Foundation

public enum Authentication: Sendable {
    case none
    case bearer(String)
    case basic(username: String, password: String)
    case apiKey(String, String) // key, value
    
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