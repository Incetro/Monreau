// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Monreau",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "Monreau",
            targets: ["Monreau"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.31.0")
    ],
    targets: [
        .target(
            name: "Monreau",
            dependencies: ["RealmSwift"]
        ),
        .testTarget(
            name: "MonreauTests",
            dependencies: ["Monreau", "RealmSwift"]
        ),
    ]
)
