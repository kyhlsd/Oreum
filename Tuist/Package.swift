// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "Realm": .staticFramework,
            "Alamofire": .staticFramework,
            "Kingfisher": .staticFramework,
            "SnapKit": .staticFramework,
            "Toast": .staticFramework
        ]
    )
#endif

let package = Package(
    name: "Oreum",
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift", from: "20.0.3"), // Realm
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.2"), // Alamofire
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.5.0"), // Kingfisher
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"), // SnapKit
        .package(url: "https://github.com/scalessec/Toast-Swift.git", from: "5.1.1"), // Toast
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0") // Firebase
    ]
)
