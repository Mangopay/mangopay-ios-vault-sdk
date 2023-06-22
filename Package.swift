// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MangopayVaultSDK",
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

        )
        
    ]
)
