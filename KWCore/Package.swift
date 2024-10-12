// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KWCore",
    platforms: [
        .macOS(.v14), .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "KWCore", targets: ["KWCore"]),
    ],
    targets: [
        .target(
            name: "KWCore"),
        .testTarget(
            name: "KWCoreTests",
            dependencies: ["KWCore"]
        ),
    ]
)
