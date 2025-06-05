//
//  ResponseValidator.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

public protocol ResponseValidating: Sendable {
    func validate(response: HTTPURLResponse, data: Data) throws
}

public struct DefaultResponseValidator: ResponseValidating {
    private let acceptableStatusCodes: Range<Int>
    private let acceptableContentTypes: Set<String>?
    
    public init(
        acceptableStatusCodes: Range<Int> = 200..<300,
        acceptableContentTypes: Set<String>? = nil
    ) {
        self.acceptableStatusCodes = acceptableStatusCodes
        self.acceptableContentTypes = acceptableContentTypes
    }
    
    public func validate(response: HTTPURLResponse, data: Data) throws {
        // Validate status code
        guard acceptableStatusCodes.contains(response.statusCode) else {
            throw ServiceError.invalidStatusCode(response.statusCode)
        }
        
        // Validate content type if specified
        if let acceptableContentTypes = acceptableContentTypes,
           let contentType = response.value(forHTTPHeaderField: "Content-Type") {
            
            let normalizedContentType = contentType.components(separatedBy: ";").first?.trimmingCharacters(in: .whitespaces) ?? ""
            
            guard acceptableContentTypes.contains(normalizedContentType) else {
                throw ServiceError.invalidContentType(contentType)
            }
        }
        
        // Validate if there's data when expected
        if data.isEmpty && shouldHaveContent(for: response) {
            throw ServiceError.noData
        }
    }
    
    private func shouldHaveContent(for response: HTTPURLResponse) -> Bool {
        // Status codes that normally don't have content
        let noContentStatusCodes: Set<Int> = [204, 205, 304]
        return !noContentStatusCodes.contains(response.statusCode)
    }
}

// MARK: - Specialized Validators

public struct JSONResponseValidator: ResponseValidating {
    public init() {}
    
    public func validate(response: HTTPURLResponse, data: Data) throws {
        let validator = DefaultResponseValidator(
            acceptableContentTypes: ["application/json", "text/json"]
        )
        
        try validator.validate(response: response, data: data)
        
        // Validate if it's valid JSON
        if !data.isEmpty {
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                throw ServiceError.invalidJSONResponse
            }
        }
    }
}

public struct XMLResponseValidator: ResponseValidating {
    public init() {}
    
    public func validate(response: HTTPURLResponse, data: Data) throws {
        let validator = DefaultResponseValidator(
            acceptableContentTypes: ["application/xml", "text/xml"]
        )
        
        try validator.validate(response: response, data: data)
    }
}

public struct ImageResponseValidator: ResponseValidating {
    public init() {}
    
    public func validate(response: HTTPURLResponse, data: Data) throws {
        let validator = DefaultResponseValidator(
            acceptableContentTypes: [
                "image/jpeg", "image/jpg", "image/png",
                "image/gif", "image/webp", "image/svg+xml"
            ]
        )
        
        try validator.validate(response: response, data: data)
    }
}

public struct CustomStatusCodeValidator: ResponseValidating {
    private let acceptableStatusCodes: Set<Int>
    
    public init(acceptableStatusCodes: Set<Int>) {
        self.acceptableStatusCodes = acceptableStatusCodes
    }
    
    public func validate(response: HTTPURLResponse, data: Data) throws {
        guard acceptableStatusCodes.contains(response.statusCode) else {
            throw ServiceError.invalidStatusCode(response.statusCode)
        }
    }
}

// MARK: - Composite Validator

public struct CompositeResponseValidator: ResponseValidating {
    private let validators: [ResponseValidating]
    
    public init(_ validators: [ResponseValidating]) {
        self.validators = validators
    }
    
    public func validate(response: HTTPURLResponse, data: Data) throws {
        for validator in validators {
            try validator.validate(response: response, data: data)
        }
    }
}

// MARK: - Custom Closure Validator

public struct ClosureResponseValidator: ResponseValidating, @unchecked Sendable {
    private let validation: (HTTPURLResponse, Data) throws -> Void
    
    public init(_ validation: @escaping (HTTPURLResponse, Data) throws -> Void) {
        self.validation = validation
    }
    
    public func validate(response: HTTPURLResponse, data: Data) throws {
        try validation(response, data)
    }
}

// MARK: - HTTPURLResponse Extensions

public extension HTTPURLResponse {
    
    /// Checks if the status code indicates success
    var isSuccessful: Bool {
        return 200..<300 ~= statusCode
    }
    
    /// Checks if the status code indicates client error
    var isClientError: Bool {
        return 400..<500 ~= statusCode
    }
    
    /// Checks if the status code indicates server error
    var isServerError: Bool {
        return 500..<600 ~= statusCode
    }
    
    /// Checks if the response is a redirection
    var isRedirection: Bool {
        return 300..<400 ~= statusCode
    }
    
    /// Returns the normalized content type (without parameters)
    var normalizedContentType: String? {
        return value(forHTTPHeaderField: "Content-Type")?
            .components(separatedBy: ";")
            .first?
            .trimmingCharacters(in: .whitespaces)
    }
    
    /// Checks if the content type is JSON
    var isJSON: Bool {
        guard let contentType = normalizedContentType else { return false }
        return contentType.contains("json")
    }
    
    /// Checks if the content type is XML
    var isXML: Bool {
        guard let contentType = normalizedContentType else { return false }
        return contentType.contains("xml")
    }
    
    /// Checks if the content type is an image
    var isImage: Bool {
        guard let contentType = normalizedContentType else { return false }
        return contentType.hasPrefix("image/")
    }
}

// MARK: - ServiceError Extensions

public extension ServiceError {
    static func invalidContentType(_ contentType: String) -> ServiceError {
        return .networkError(InvalidContentTypeError(contentType: contentType))
    }
    
    static var invalidJSONResponse: ServiceError {
        return .networkError(InvalidJSONResponseError())
    }
}

// MARK: - Custom Errors

public struct InvalidContentTypeError: LocalizedError, Sendable {
    let contentType: String
    
    public var errorDescription: String? {
        return "Invalid content type: \(contentType)"
    }
}

public struct InvalidJSONResponseError: LocalizedError, Sendable {
    public var errorDescription: String? {
        return "Response is not valid JSON"
    }
}

// MARK: - Factory Methods

public extension ResponseValidating where Self == DefaultResponseValidator {
    
    static var `default`: DefaultResponseValidator {
        DefaultResponseValidator()
    }
    
    static func statusCodes(_ range: Range<Int>) -> DefaultResponseValidator {
        DefaultResponseValidator(acceptableStatusCodes: range)
    }
    
    static func contentTypes(_ types: Set<String>) -> DefaultResponseValidator {
        DefaultResponseValidator(acceptableContentTypes: types)
    }
    
    static func json() -> JSONResponseValidator {
        JSONResponseValidator()
    }
    
    static func xml() -> XMLResponseValidator {
        XMLResponseValidator()
    }
    
    static func image() -> ImageResponseValidator {
        ImageResponseValidator()
    }
    
    static func custom(_ validation: @escaping (HTTPURLResponse, Data) throws -> Void) -> ClosureResponseValidator {
        ClosureResponseValidator(validation)
    }
}
