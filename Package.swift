// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIPlus",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftUIPlus",
            targets: ["SwiftUIPlus"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hstdt/SwiftUIBackports", branch: "main")
    ],
    targets: [
        .target(name: "SwiftUIPlus", dependencies: ["SwiftUIBackports"])
    ]
)
