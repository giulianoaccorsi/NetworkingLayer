import Foundation

public enum HTTPBody: Sendable {
    case none
    case raw(Data)
    case json(any Codable & Sendable)
    case custom([String: any Sendable])
    case string(String)
    
    public func toData() throws -> Data? {
        switch self {
        case .none:
            return nil
        case .raw(let data):
            return data
        case .json(let codable):
            return try JSONEncoder().encode(codable)
        case .custom(let dictionary):
            return try JSONSerialization.data(withJSONObject: dictionary as [String: Any])
        case .string(let string):
            return string.data(using: .utf8)
        }
    }
} 