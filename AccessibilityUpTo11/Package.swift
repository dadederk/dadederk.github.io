// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AccessibilityUpTo11",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/twostraws/Ignite.git", from: "0.6.2")
    ],
    targets: [
        .executableTarget(
            name: "AccessibilityUpTo11",
            dependencies: ["Ignite"]),
    ]
)
