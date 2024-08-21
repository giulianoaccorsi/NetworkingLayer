import XCTest
@testable import TaskNetworking

final class DataRequestProtocolTests: XCTestCase {
    func testMakeURLRequestWithoutQueryItemsOrHeaders() throws {
        let request = MockRequest(domain: "https://api.example.com", path: "/pokemon", method: .get)
        
        let urlRequest = try request.makeURLRequest()
        
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/pokemon")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertNil(urlRequest.httpBody)
        XCTAssertTrue(urlRequest.allHTTPHeaderFields?.isEmpty ?? true)
    }
    
    func testMakeURLRequestWithQueryItemsAndHeaders() throws {
        let request = MockRequest(
            domain: "https://api.example.com",
            path: "/pokemon",
            method: .get,
            headers: ["Authorization": "Bearer token"],
            queryItems: ["name": "pikachu"]
        )
        
        let urlRequest = try request.makeURLRequest()
        
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/pokemon?name=pikachu")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer token")
    }
    
    func testMakeURLRequestWithBody() throws {
        let bodyData = "{\"key\": \"value\"}".data(using: .utf8)
        let request = MockRequest(
            domain: "https://api.example.com",
            path: "/pokemon",
            method: .post,
            body: bodyData
        )
        
        let urlRequest = try request.makeURLRequest()
        
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/pokemon")
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.httpBody, bodyData)
    }
    
    func testDecodeSuccess() throws {
        let jsonData = """
            {
                "id": 1,
                "name": "Pikachu"
            }
            """.data(using: .utf8)!
        
        let request = MockRequest(domain: "https://api.example.com", path: "/pokemon", method: .get)
        let response = try request.decode(jsonData)
        
        let expectedResponse = MockResponse(id: 1, name: "Pikachu")
        XCTAssertEqual(response, expectedResponse)
    }
    
    func testDecodeThrowsErrorForInvalidData() {
        let invalidJsonData = "invalid json".data(using: .utf8)!
        
        let request = MockRequest(domain: "https://api.example.com", path: "/pokemon", method: .get)
        
        XCTAssertThrowsError(try request.decode(invalidJsonData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}

