import Foundation

public enum NetworkError: LocalizedError, Equatable, Sendable, Hashable {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case decodingFailed
    case encodingFailed
    case timeout
    case noInternetConnection
    case invalidURL
    case unknown(Error)
    case custom(statusCode: Int, data: Data? = nil)
    
    public var errorDescription: String? {
        switch self {
        case .badRequest:
            return String(localized: "error_bad_request", bundle: .module)
        case .unauthorized:
            return String(localized: "error_unauthorized", bundle: .module)
        case .forbidden:
            return String(localized: "error_forbidden", bundle: .module)
        case .notFound:
            return String(localized: "error_not_found", bundle: .module)
        case .serverError:
            return String(localized: "error_server_error", bundle: .module)
        case .decodingFailed:
            return String(localized: "error_decoding_failed", bundle: .module)
        case .encodingFailed:
            return String(localized: "error_encoding_failed", bundle: .module)
        case .timeout:
            return String(localized: "error_timeout", bundle: .module)
        case .noInternetConnection:
            return String(localized: "error_no_internet", bundle: .module)
        case .invalidURL:
            return String(localized: "error_invalid_url", bundle: .module)
        case .unknown(let error):
            return String(localized: "error_unknown", bundle: .module) + ": \(error.localizedDescription)"
        case .custom(statusCode: let statusCode, _):
            return "HTTP error with status code: \(statusCode)"
        }
    }
    
    public static func from(httpStatusCode: Int, data: Data?) -> NetworkError {
        if data == nil {
            switch httpStatusCode {
            case 400:
                return .badRequest
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500...599:
                return .serverError
            default:
                return .unknown(
                    NSError(
                        domain: "HTTPError",
                        code: httpStatusCode,
                        userInfo: nil
                    )
                )
            }
        }
        
        return .custom(statusCode: httpStatusCode, data: data)
    }
    
    // MARK: - Equatable
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.badRequest, .badRequest),
            (.unauthorized, .unauthorized),
            (.forbidden, .forbidden),
            (.notFound, .notFound),
            (.serverError, .serverError),
            (.decodingFailed, .decodingFailed),
            (.encodingFailed, .encodingFailed),
            (.timeout, .timeout),
            (.noInternetConnection, .noInternetConnection),
            (.invalidURL, .invalidURL),
            (.custom, .custom):
            return true
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .badRequest:
            hasher.combine(0)
        case .unauthorized:
            hasher.combine(1)
        case .forbidden:
            hasher.combine(2)
        case .notFound:
            hasher.combine(3)
        case .serverError:
            hasher.combine(4)
        case .decodingFailed:
            hasher.combine(5)
        case .encodingFailed:
            hasher.combine(6)
        case .timeout:
            hasher.combine(7)
        case .noInternetConnection:
            hasher.combine(8)
        case .invalidURL:
            hasher.combine(9)
        case .unknown(let error):
            hasher.combine(10)
            hasher.combine(error.localizedDescription)
        case .custom(let statusCode, _):
            hasher.combine(11)
            hasher.combine(statusCode)
        }
    }
}

// MARK: - CustomDebugStringConvertible
extension NetworkError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .badRequest:
            return "🔴 Bad Request (400)"
        case .unauthorized:
            return "🔒 Unauthorized (401)"
        case .forbidden:
            return "🚫 Forbidden (403)"
        case .notFound:
            return "🔍 Not Found (404)"
        case .serverError:
            return "💥 Server Error (5xx)"
        case .decodingFailed:
            return "📦 JSON Decoding Failed"
        case .encodingFailed:
            return "📝 JSON Encoding Failed"
        case .timeout:
            return "⏰ Request Timeout"
        case .noInternetConnection:
            return "📶 No Internet Connection"
        case .invalidURL:
            return "🔗 Invalid URL"
        case .unknown(let error):
            return "❓ Unknown Error: \(error)"
        case .custom(let statusCode, let data):
            let dataInfo = data != nil ? " with \(data!.count) bytes" : ""
            return "🔧 Custom Error (HTTP \(statusCode))\(dataInfo)"
        }
    }
}
