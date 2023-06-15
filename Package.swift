// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MangoPayVaultSDK",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MangopayVault",
            targets: ["MangopayVault"]),
    ],
    
    targets: [
        .target(
            name: "MangopayVault",
            path: "MangopayVault"
        ),
        .testTarget(
            name: "Tests",
            path: "Tests"
//            swiftSettings: [
//                .unsafeFlags(["-enable-testing-search-paths"]),
//            ]
        )

//        .plugin(name: "SwiftLintCommandPlugin.swift",
//                capability: .command(
//                    intent: .sourceCodeFormatting(),
//                    permissions: [
//                        .writeToPackageDirectory(reason: "This command reformats source files")
//                    ]
//                )
//               )
        
    ]
)
