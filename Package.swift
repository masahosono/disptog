// swift-tools-version: 5.9
// Package.swift for SPM-based tool management (SwiftLint, SwiftFormat)
// This package is only used for managing development tools via plugins.
// The actual application is built using XcodeGen and xcodebuild.

import PackageDescription

let package = Package(
    name: "DispTog",
    platforms: [
        .macOS(.v11)
    ],
    products: [],
    dependencies: [
        // SwiftLint plugin for linting
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.57.1"),
        // SwiftFormat plugin for code formatting
        .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.55.3")
    ],
    targets: []
)
