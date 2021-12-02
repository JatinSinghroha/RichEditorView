// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "RichEditorView",
    platforms: [
         .iOS(.v11)
    ],
    products: [
        .library(name: "RichEditorView", targets: ["RichEditorView"])
    ],
    targets: [
        .target(name: "RichEditorView")
    ]
)
