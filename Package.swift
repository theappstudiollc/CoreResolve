// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreResolve",
	defaultLocalization: "en",
	platforms: [
		.macOS("12.0"), .iOS("16.0"), .tvOS("16.0"), .watchOS("9.0")
	],
    products: [
        .library(
            name: "CoreResolve",
            targets: ["CoreResolve"]),
    ],
    targets: [
		.target(
			name: "CoreResolve_ObjC"),
        .target(
            name: "CoreResolve",
            dependencies: ["CoreResolve_ObjC"],
            path: ".",
            exclude: ["Tests", "Sources/CoreResolve_ObjC", "README.md"],
            sources: ["Sources/CoreResolve"],
            resources: [
                .process("Resources")
            ]),
		.testTarget(
			name: "CoreResolveTests",
			dependencies: ["CoreResolve"])
    ]
)
