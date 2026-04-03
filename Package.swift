// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ChromaDock",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ChromaDock",
            targets: ["ChromaDock"]),
    ],
    targets: [
        .executableTarget(
            name: "ChromaDock",
            dependencies: [])
    ]
)