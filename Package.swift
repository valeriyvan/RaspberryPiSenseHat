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
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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
