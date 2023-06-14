// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "NetworkingLayer",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "NetworkingLayer",
            targets: ["NetworkingLayer"]
        ),
    ],
    targets: [
        .target(
            name: "NetworkingLayer"),
        .testTarget(
            name: "NetworkingLayerTests",
            dependencies: ["NetworkingLayer"]
        ),
    ]
)
