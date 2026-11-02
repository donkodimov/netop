// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Netop",
    platforms: [.macOS(.v14)],
    targets: [
        // All logic. Pure Swift, no SwiftUI/AppKit, fully testable headless.
        .target(name: "NetopCore"),
        // Thin SwiftUI shell: menu bar + window. Packaged into Netop.app by scripts/bundle.sh.
        .executableTarget(name: "Netop", dependencies: ["NetopCore"]),
        .testTarget(name: "NetopCoreTests", dependencies: ["NetopCore"]),
    ]
)
