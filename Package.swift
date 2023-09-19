// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "RichEditorView",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "RichEditorView",
            targets: ["RichEditorView"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "RichEditorView",
            dependencies: [],
            path: "RichEditorView/Classes",
            resources: [
                .process("RichEditorView/Assets/icons"),
                .process("RichEditorView/Assets/editor")
            ]
        ),
        // Uncomment the following line if you have tests
        // .testTarget(name: "RichEditorViewTests", dependencies: ["RichEditorView"]),
    ]
)
