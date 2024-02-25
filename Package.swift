// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Migrator",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "Migrator",
            targets: ["Migrator", "MigratorCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .target(name: "MigratorCore",
                swiftSettings: [
                    .enableExperimentalFeature("StrictConcurrency"),
                ]),
        .target(name: "Migrator", dependencies: ["MigratorCore", "MigratorMacros"]),
        .macro(
            name: "MigratorMacros",
            dependencies: [
                .target(name: "MigratorCore"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "MigratorTests",
            dependencies: [
                "MigratorCore",
                "Migrator",
                "MigratorMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
