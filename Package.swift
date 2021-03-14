// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreResolve",
	defaultLocalization: "en",
	platforms: [
		.macOS(.v10_12), .iOS(.v9), .tvOS(.v10), .watchOS(.v3)
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
			resources: [
				.process("Resources/CoreAPIError.strings"),
				.process("Resources/CoreDataStackError.strings"),
				.process("Resources/CoreFactoryServiceError.strings"),
				.process("Resources/CoreFileStoreServiceError.strings"),
				.process("Resources/CoreServiceProvidingError.strings"),
				.process("Resources/MultipeerMessageManagerError.strings")
			]),
		.testTarget(
			name: "CoreResolveTests",
			dependencies: ["CoreResolve"])
    ]
)
