//
//  Package.swift
//  RichEditorView
//
//  Created by Paresh Mittal on 02/12/21.
//


import PackageDescription

let package = Package(
    name: "KeychainAccess",
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
