// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "NIOMQTT",
    dependencies: [
      .package(url: "https://github.com/danger/swift.git", from: "1.0.0")
    ],
    targets: [
        // This is just an arbitrary Swift file in our app, that has
        // no dependencies outside of Foundation, the dependencies section
        // ensures that the library for Danger gets build also.
        .target(
            name: "NIOMQTT",
            dependencies: ["Danger"],
            path: "Danger",
            sources: ["Foundation.swift"])
    ]
)
