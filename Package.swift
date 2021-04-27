// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "swift-nio-mqtt",
    platforms: [.iOS(.v12), .macOS(.v10_14), .tvOS(.v12), .watchOS(.v6)],
    products: [
        .library(name: "MQTTCodec", targets: ["MQTTCodec"]),
        .library(name: "NIOMQTTClient", targets: ["NIOMQTTClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-collections", from: "0.0.1"),
    ],
    targets: [
        .target(name: "MQTTCodec", dependencies: ["NIO", "NIOFoundationCompat"]),
        .testTarget(name: "MQTTCodecTests", dependencies: ["MQTTCodec"]),
        .target(
            name: "NIOMQTTClient",
            dependencies: ["MQTTCodec", "NIO", "NIOTransportServices", "Logging", "Collections"]),
        .testTarget(name: "NIOMQTTClientTests", dependencies: ["NIOMQTTClient"]),
    ]
)
