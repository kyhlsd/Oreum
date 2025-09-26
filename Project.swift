import ProjectDescription

let version = "16.0"

let project = Project(
    name: "Oreum",
    targets: [
        .target(
            name: "Oreum",
            destinations: [.iPhone],
            product: .app,
            bundleId: "io.tuist.Oreum",
            deploymentTargets: .iOS(version),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ],
                            ]
                        ]
                    ],
                    "UIUserInterfaceStyle": "Light",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ]
                ],
            ),
            sources: ["Oreum/Sources/**"],
            resources: ["Oreum/Resources/**"],
            dependencies: [
                .target(name: "Presentation"),
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Common")
            ]
        ),
        
            .target(name: "Domain",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "io.tuist.Domain",
                    deploymentTargets: .iOS(version),
                    sources: ["Domain/Sources/**"],
                    resources: ["Domain/Resources/**"],
                    dependencies: [
                        .target(name: "Common")
                    ]
                   ),
        
            .target(name: "Data",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "io.tuist.Data",
                    deploymentTargets: .iOS(version),
                    sources: ["Data/Sources/**"],
                    resources: ["Data/Resources/**"],
                    dependencies: [
                        .target(name: "Common"),
                        .target(name: "Domain"),
                        .external(name: "Realm"),
                        .external(name: "Alamofire")
                    ]
                   ),
        
            .target(name: "Presentation",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "io.tuist.Presentation",
                    deploymentTargets: .iOS(version),
                    sources: ["Presentation/Sources/**"],
                    resources: ["Presentation/Resources/**"],
                    dependencies: [
                        .target(name: "Common"),
                        .target(name: "Domain"),
                        .target(name: "Data"),
                        .external(name: "Kingfisher"),
                        .external(name: "KingfisherWebP"),
                        .external(name: "SnapKit"),
                        .external(name: "Toast")
                    ]
                   ),
        
            .target(name: "Common",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "io.tuist.Common",
                    deploymentTargets: .iOS(version),
                    sources: ["Common/Sources/**"],
                    resources: ["Common/Resources/**"],
                    dependencies: []
                   ),
    ]
)
