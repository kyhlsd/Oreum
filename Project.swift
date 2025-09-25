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
            dependencies: []
        ),
    ]
)
