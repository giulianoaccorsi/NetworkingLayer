//
//  CombineNetworkingTests.swift
//
//
//  Created by Giuliano Accorsi on 27/06/24.
//

import XCTest
import Combine
import Commons

@testable import CombineNetworking

struct MockRequest: DataRequestProtocol {
    typealias Response = String

    var domain: String = "mock"

    var path: String = "/mock"

    var method: Commons.HTTPMethod = .get

}

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
        // Given
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

        // When
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
        // Given
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

        // When
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
}
