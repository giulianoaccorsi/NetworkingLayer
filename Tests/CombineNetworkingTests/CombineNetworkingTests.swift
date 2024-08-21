//
//  CombineNetworkingTests.swift
//
//
//  Created by Giuliano Accorsi on 27/06/24.
//

import XCTest
import Combine
@testable import CombineNetworking

final class CombineNetworkingTests: XCTestCase {

    var cancellables: Set<AnyCancellable>!
    var networkService: DefaultNetworkService!

    override func setUp() {
        super.setUp()
        cancellables = []

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        networkService = DefaultNetworkService(session: session)
    }

    override func tearDown() {
        cancellables = nil
        networkService = nil
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        super.tearDown()
    }

    func testRequestReturnsServiceErrorForStatusCode400() {
        let response = HTTPURLResponse(
            url: URL(string: "https://mockurl.com")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )!

        MockURLProtocol.response = response
        MockURLProtocol.responseData = nil
        MockURLProtocol.error = nil

        let expectation = XCTestExpectation(description: "Request fails with invalid status code")

        networkService.request(MockRequest())
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTAssertTrue(error is ServiceError)
                    XCTAssertEqual(error.localizedDescription, "Received an invalid status code: 400.")
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                XCTFail("Request succeeded unexpectedly with value: \(value)")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testRequestSuccess() {
        let response = HTTPURLResponse(
            url: URL(string: "https://mockurl.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let expectedData = """
        "Success"
        """.data(using: .utf8)!

        MockURLProtocol.response = response
        MockURLProtocol.responseData = expectedData
        MockURLProtocol.error = nil

        let expectation = XCTestExpectation(description: "Request completes successfully")

        networkService.request(MockRequest())
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Request failed with error: \(error)")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, "Success")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testMakeURLRequestPublisherWithQueryItemsAndHeaders() {
        struct RequestWithQueryItemsAndHeaders: DataRequestProtocol {
            typealias Response = String

            var domain: String = "https://mockurl.com"
            var path: String = "/test"
            var method: Commons.HTTPMethod = .get
            var headers: [String: String] = ["Authorization": "Bearer token"]
            var queryItems: [String: String] = ["name": "pikachu"]
        }

        let request = RequestWithQueryItemsAndHeaders()

        let expectation = XCTestExpectation(description: "URLRequest is created with correct query items and headers")

        request.makeURLRequestPublisher()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Request failed with error: \(error)")
                }
            }, receiveValue: { urlRequest in
                XCTAssertEqual(urlRequest.url?.absoluteString, "https://mockurl.com/test?name=pikachu")
                XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer token")
                XCTAssertEqual(urlRequest.httpMethod, "GET")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodeValidJSON() {
        struct MockResponse: Decodable, Equatable {
            let id: Int
            let name: String
        }

        struct Request: DataRequestProtocol {
            typealias Response = MockResponse

            var domain: String = "https://mockurl.com"
            var path: String = "/test"
            var method: Commons.HTTPMethod = .get
        }

        let request = Request()

        let jsonData = """
        {
            "id": 1,
            "name": "Pikachu"
        }
        """.data(using: .utf8)!

        let expectation = XCTestExpectation(description: "Response is decoded correctly")

        request.decode(jsonData)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Decoding failed with error: \(error)")
                }
            }, receiveValue: { response in
                XCTAssertEqual(response, MockResponse(id: 1, name: "Pikachu"))
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodeInvalidJSON() {
        struct Request: DataRequestProtocol {
            typealias Response = String

            var domain: String = "https://mockurl.com"
            var path: String = "/test"
            var method: Commons.HTTPMethod = .get
        }

        let request = Request()

        let invalidJsonData = "invalid json".data(using: .utf8)!

        let expectation = XCTestExpectation(description: "Decoding fails with invalid JSON")

        request.decode(invalidJsonData)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTAssertTrue(error is DecodingError)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Decoding succeeded unexpectedly")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }


}
