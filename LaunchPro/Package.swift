// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LaunchPro",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "LaunchPro", targets: ["LaunchPro"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "LaunchPro",
            dependencies: [],
            path: "LaunchPro",
            resources: [.process("Resources")]
        )
    ]
)
