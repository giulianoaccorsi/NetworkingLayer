//
//  File.swift
//  
//
//  Created by Giuliano Accorsi on 20/08/24.
//

import Foundation
import XCTest
@testable import TaskNetworking

struct MockRequest: DataRequestProtocol {
    typealias Response = MockResponse

    var domain: String
    var path: String
    var method: Commons.HTTPMethod
    var headers: [String : String] = [:]
    var queryItems: [String : String] = [:]
    var body: Data? = nil
}

struct MockResponse: Decodable, Equatable {
    let id: Int
    let name: String
}
