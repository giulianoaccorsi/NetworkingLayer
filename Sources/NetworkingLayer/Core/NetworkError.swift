import Foundation

public enum NetworkError: LocalizedError, Equatable {
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
        }
    }
    
    public static func from(httpStatusCode: Int) -> NetworkError {
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
            return .unknown(NSError(domain: "HTTPError", code: httpStatusCode, userInfo: nil))
        }
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
             (.invalidURL, .invalidURL):
            return true
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
} 