// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "CapoServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),

        .package(url: "https://github.com/noahemmet/GraphQLRouteCollection.git", .branch("master")),
        
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),

    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "VaporGraphQL", "Vapor", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

