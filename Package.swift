// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkingLayer",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(
            name: "NetworkingLayer",
            targets: ["NetworkingLayer"]
        )
    ],
    targets: [
        .target(
            name: "NetworkingLayer",
            path: "Sources/NetworkingLayer",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
