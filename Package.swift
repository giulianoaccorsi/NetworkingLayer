// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "NetworkingLayer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "TaskNetworking",
            targets: ["TaskNetworking"]
        ),
        .library(
            name: "CombineNetworking",
            targets: ["CombineNetworking"]
        ),
    ],
    targets: [
        .target(
            name: "TaskNetworking",
            dependencies: ["Commons"],
            path: "Sources/TaskNetworking"
        ),
        .testTarget(
            name: "TaskNetworkingTests",
            dependencies: ["TaskNetworking"],
            path: "Tests/TaskNetworkingTests"
        ),
        .target(
            name: "CombineNetworking",
            dependencies: ["Commons"],
            path: "Sources/CombineNetworking"
        ),
        .testTarget(
            name: "CombineNetworkingTests",
            dependencies: ["CombineNetworking"],
            path: "Tests/CombineNetworkingTests"
        ),
        .target(
            name: "Commons",
            path: "Sources/Commons"
        ),
    ]
)
