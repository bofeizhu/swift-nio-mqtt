// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "swift-nio-mqtt",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "NIOMQTT",
            targets: ["NIOMQTT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.2.1"),
    ],
    targets: [
        .target(
            name: "NIOMQTT",
            dependencies: ["NIO", "NIOTransportServices"]),
        .testTarget(
            name: "NIOMQTTTests",
            dependencies: ["NIOMQTT"]),
    ]
)
