// swift-tools-version:5.1.0

import PackageDescription

let package = Package(
    name: "SenseHat",
    products: [
        .library(name: "SenseHat", targets: ["SenseHat"]),
        .library(name: "Font8x8", targets: ["Font8x8"]),
        .executable(name: "Blink", targets: ["Blink"]),
        .executable(name: "Snake", targets: ["Snake"]),
        .executable(name: "Life", targets: ["Life"]),
        .executable(name: "Sensors", targets: ["Sensors"]),
        .executable(name: "Runner", targets: ["Runner"]),

    ],
    dependencies: [],
    targets: [
        .target(name: "SenseHat", dependencies: ["Font8x8"]),
        .target(name: "Font8x8", dependencies: []),
        .target(name: "Blink", dependencies: ["SenseHat"]),
        .target(name: "Snake", dependencies: ["SenseHat"]),
        .target(name: "Life", dependencies: ["SenseHat"]),
        .target(name: "Sensors", dependencies: ["SenseHat"]),
        .target(name: "Runner", dependencies: ["SenseHat"]),
        .testTarget(name: "SenseHatTests", dependencies: ["SenseHat"]),
    ]
)
