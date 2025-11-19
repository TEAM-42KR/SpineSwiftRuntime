// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpineSwiftRuntime",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macCatalyst(.v13),
        .visionOS(.v1),
        .macOS(.v10_15),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SpineSwiftRuntime",
            targets: ["SpineSwiftRuntimeWrapper"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/EsotericSoftware/spine-runtimes.git", branch: "4.3-beta")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "spine_apple_extension",
            dependencies: [
                .product(name: "SpineC", package: "spine-runtimes")
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .target(
            name: "SpineSwiftRuntime",
            dependencies: [
                "spine_apple_extension", "SIMDSpineShadersStructs",
                .product(name: "SpineC", package: "spine-runtimes"),
                .product(name: "SpineSwift", package: "spine-runtimes"),
            ]
        ),

        .target(
            name: "SpineSwiftRuntimeWrapper",
            dependencies: [
                .target(
                    name: "SpineSwiftRuntime",
                    condition: .when(
                        platforms: [
                            .iOS, .macOS, .tvOS, .macCatalyst, .visionOS, .watchOS,
                        ]
                    )
                )
            ]
        ),
        .systemLibrary(name: "SIMDSpineShadersStructs"),
    ]
)
