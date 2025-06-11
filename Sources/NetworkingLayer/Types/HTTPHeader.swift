import Foundation

public enum HTTPHeader {
    case json
    case xml
    case formURLEncoded
    case multipartFormData
    case bearer(String)
    case basic(username: String, password: String)
    case custom(String, String)
    
    public var key: String {
        switch self {
        case .json, .xml, .formURLEncoded, .multipartFormData:
            return "Content-Type"
        case .bearer, .basic:
            return "Authorization"
        case .custom(let key, _):
            return key
        }
    }
    
    public var value: String {
        switch self {
        case .json:
            return "application/json"
        case .xml:
            return "application/xml"
        case .formURLEncoded:
            return "application/x-www-form-urlencoded"
        case .multipartFormData:
            return "multipart/form-data"
        case .bearer(let token):
            return "Bearer \(token)"
        case .basic(let username, let password):
            let credentials = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? ""
            return "Basic \(credentials)"
        case .custom(_, let value):
            return value
        }
    }
    
    public var keyValuePair: (String, String) {
        return (key, value)
    }
} 