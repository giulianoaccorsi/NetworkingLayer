//
//  MockURLProtocol.swift
//  
//
//  Created by Giuliano Accorsi on 27/06/24.
//

import Foundation
class MockURLProtocol: URLProtocol {
    static var responseData: Data?
    static var response: URLResponse?
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else {
            if let response = MockURLProtocol.response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = MockURLProtocol.responseData {
                self.client?.urlProtocol(self, didLoad: data)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
