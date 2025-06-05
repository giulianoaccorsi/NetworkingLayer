// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NetworkingLayer",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "NetworkingLayer",
            targets: ["NetworkingLayer"]
        )
    ],
    dependencies: [
        // Add dependencies here if needed in the future
    ],
    targets: [
        .target(
            name: "NetworkingLayer",
            path: "Sources/NetworkingLayer",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "NetworkingLayerTests",
            dependencies: ["NetworkingLayer"],
            path: "Tests/NetworkingLayerTests"
        ),
    ]
)
