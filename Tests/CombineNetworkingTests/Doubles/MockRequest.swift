//
//  File.swift
//  
//
//  Created by Giuliano Accorsi on 20/08/24.
//

import Foundation
@testable import CombineNetworking

struct MockRequest: DataRequestProtocol {
    typealias Response = String

    var domain: String = "mock"

    var path: String = "/mock"

    var method: Commons.HTTPMethod = .get

}
