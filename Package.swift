// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetServiceLinuxTest",
	dependencies: [
		.package(url: "https://github.com/Bouke/NetService.git", from: "0.8.0")
	],
	targets: [
        .executableTarget(
            name: "NetServiceLinuxTest",
			dependencies: [
				.product(name: "NetService", package: "NetService")
			]
		),
    ]
)
