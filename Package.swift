// swift-tools-version:5.1.0

import PackageDescription

let package = Package(
    name: "SenseHat",
    products: [
        .library(
            name: "SenseHat",
            targets: ["SenseHat"]),
        .library(
            name: "Font8x8",
            targets: ["Font8x8"]),
        .executable(name: "Blink", targets: ["Blink"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SenseHat",
            dependencies: ["Font8x8"]),
        .target(
            name: "Font8x8",
            dependencies: []),
        .target(
            name: "Blink",
            dependencies: ["SenseHat"]),
        .testTarget(
            name: "SenseHatTests",
            dependencies: ["SenseHat"]),
    ]
)
