import XCTest
@testable import NetworkingLayer

final class NetworkingLayerTests: XCTestCase {
    
    var mockSession: URLSession!
    var networkService: DefaultNetworkService!
    
    override func setUp() {
        super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        networkService = DefaultNetworkService(session: mockSession)
        
        // Reset mock state
        MockURLProtocol.reset()
    }
    
    override func tearDown() {
        MockURLProtocol.reset()
        mockSession = nil
        networkService = nil
        super.tearDown()
    }
    
    // MARK: - DataRequestProtocol Tests
    
    func testMakeURLRequestWithBasicProperties() throws {
        let request = TestDataRequest()
        
        let urlRequest = try request.makeURLRequest()
        
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/test")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.timeoutInterval, 60.0)
        XCTAssertEqual(urlRequest.cachePolicy, .useProtocolCachePolicy)
    }


    
    // MARK: - DefaultNetworkService Tests
    
    func testSuccessfulRequest() async throws {
        let expectedResponse = TestResponse(id: 1, name: "Test")
        let responseData = try JSONEncoder().encode(expectedResponse)
        
        MockURLProtocol.responseData = responseData
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let request = TestDataRequest()
        let response = try await networkService.request(request)
        
        XCTAssertEqual(response.id, expectedResponse.id)
        XCTAssertEqual(response.name, expectedResponse.name)
    }
    
    func testRequestWithInvalidStatusCode() async {
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        let request = TestDataRequest()
        
        do {
            _ = try await networkService.request(request)
            XCTFail("Expected request to throw error")
        } catch let error as ServiceError {
            if case .invalidStatusCode(let statusCode) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("Expected ServiceError.invalidStatusCode")
            }
        } catch {
            XCTFail("Expected ServiceError, got \(error)")
        }
    }
    
    func testRequestWithNetworkError() async {
        MockURLProtocol.error = URLError(.notConnectedToInternet)
        
        let request = TestDataRequest()
        
        do {
            _ = try await networkService.request(request)
            XCTFail("Expected request to throw error")
        } catch let error as ServiceError {
            if case .networkError = error {
                // Expected error
            } else {
                XCTFail("Expected ServiceError.networkError")
            }
        } catch {
            XCTFail("Expected ServiceError, got \(error)")
        }
    }
    
    func testRequestWithNoResponse() async {
        MockURLProtocol.response = URLResponse() // Not HTTPURLResponse
        
        let request = TestDataRequest()
        
        do {
            _ = try await networkService.request(request)
            XCTFail("Expected request to throw error")
        } catch let error as ServiceError {
            if case .noResponse = error {
                // Expected error
            } else {
                XCTFail("Expected ServiceError.noResponse")
            }
        } catch {
            XCTFail("Expected ServiceError, got \(error)")
        }
    }
    
    func testRequestWithDecodingError() async {
        MockURLProtocol.responseData = "invalid json".data(using: .utf8)
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let request = TestDataRequest()
        
        do {
            _ = try await networkService.request(request)
            XCTFail("Expected request to throw error")
        } catch let error as ServiceError {
            if case .decodingError = error {
                // Expected error
            } else {
                XCTFail("Expected ServiceError.decodingError, got \(error)")
            }
        } catch {
            XCTFail("Expected ServiceError, got \(error)")
        }
    }
    
    // MARK: - HTTP Methods Tests
    
    func testAllHTTPMethods() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.head.rawValue, "HEAD")
        XCTAssertEqual(HTTPMethod.options.rawValue, "OPTIONS")
    }
    
    // MARK: - ServiceError Tests
    
    func testServiceErrorLocalizedDescriptions() {
        let errors: [ServiceError] = [
            .invalidEndpoint,
            .badURL,
            .noResponse,
            .invalidStatusCode(404),
            .noData,
            .networkError(URLError(.notConnectedToInternet)),
            .decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Test"))),
            .timeout
        ]
        
        for error in errors {
            XCTAssertFalse(error.localizedDescription.isEmpty, "Error \(error) should have a localized description")
            XCTAssertNotNil(error.failureReason, "Error \(error) should have a failure reason")
            XCTAssertNotNil(error.recoverySuggestion, "Error \(error) should have a recovery suggestion")
        }
    }
}

// MARK: - Test Helpers

struct TestResponse: Codable, Equatable, Sendable {
    let id: Int
    let name: String
}

struct TestDataRequest: DataRequestProtocol {
    typealias Response = TestResponse
    
    let domain: String
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [String: String]
    let body: Data?
    let timeoutInterval: TimeInterval
    let cachePolicy: URLRequest.CachePolicy
    
    init(
        domain: String = "https://api.example.com",
        path: String = "/test",
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryItems: [String: String] = [:],
        body: Data? = nil,
        timeoutInterval: TimeInterval = 60.0,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    ) {
        self.domain = domain
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
    }
}

