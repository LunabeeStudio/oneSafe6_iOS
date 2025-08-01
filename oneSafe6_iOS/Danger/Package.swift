// swift-tools-version:4.2
import PackageDescription

let package: Package = .init(
    name: "Danger Package",
    dependencies: [
      .package(url: "https://github.com/danger/swift.git", from: "3.21.2")
    ],
    targets: [
        // This is just an arbitrary Swift file in our app, that has
        // no dependencies outside of Foundation, the dependencies section
        // ensures that the library for Danger gets build also.
        .target(name: "Danger Dependencies", dependencies: ["Danger"], path: ".", sources: ["DangerDependency.swift"])
    ]
)
