import ProjectDescription

let project = Project(
    name: "Oreum",
    targets: [
        .target(
            name: "Oreum",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Oreum",
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
                ]
            ),
            sources: ["Oreum/Sources/**"],
            resources: ["Oreum/Resources/**"],
            dependencies: []
        ),
    ]
)
