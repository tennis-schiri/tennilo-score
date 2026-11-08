// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TenniloScore",
    platforms: [.watchOS(.v10), .iOS(.v17)],
    products: [.library(name: "ScoreCore", targets: ["ScoreCore"])],
    targets: [
        .target(name: "ScoreCore", path: "Sources/ScoreCore"),
        .testTarget(name: "ScoreCoreTests", dependencies: ["ScoreCore"], path: "Tests/ScoreCoreTests")
    ]
)
