//
//  HTTPMethod.swift
//  NetworkingLayer
//
//  Created by Giuliano Accorsi on 05/06/25.
//

import Foundation

public enum HTTPMethod: String, CaseIterable, Sendable {
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}
