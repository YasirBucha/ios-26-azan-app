// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyAzan",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyAzan",
            targets: ["MyAzan"]),
    ],
    dependencies: [
        .package(url: "https://github.com/batoulapps/adhan-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "MyAzan",
            dependencies: [
                .product(name: "Adhan", package: "adhan-swift")
            ]),
        .testTarget(
            name: "MyAzanTests",
            dependencies: ["MyAzan"]),
    ]
)
