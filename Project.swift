import ProjectDescription

let version = "16.0"

let project = Project(
    name: "Oreum",
    targets: [
        .target(
            name: "Oreum",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.kyh.Oreum",
            deploymentTargets: .iOS(version),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "오름",
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
                    "NSAppTransportSecurity": [
                        "NSExceptionDomains": [
                            "forest.go.kr": [
                                "NSIncludesSubdomains": true,
                                "NSTemporaryExceptionAllowsInsecureHTTPLoads": true,
                                "NSTemporaryExceptionMinimumTLSVersion": "TLSv1.0"
                            ]
                        ]
                    ],
                    "UIUserInterfaceStyle": "Light",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "NSHealthShareUsageDescription": "등산 기록을 위해 걸음 수와 이동 거리 데이터를 사용합니다.",
                    "NSHealthUpdateUsageDescription": "등산 활동 데이터를 저장하기 위해 HealthKit 접근이 필요합니다.",
                    "NSLocationWhenInUseUsageDescription": "내 주위 명산을 표기하기 위해 위치 정보를 사용합니다."
                ],
            ),
            sources: ["Oreum/Sources/**"],
            resources: ["Oreum/Resources/**"],
            entitlements: .file(path: "Oreum/Oreum.entitlements"),
            dependencies: [
                .target(name: "Presentation"),
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Core"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseCrashlytics")
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES",
                    "OTHER_LDFLAGS": "$(inherited) -ObjC"
                ]
            )
        ),

            .target(name: "Core",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Core",
                    deploymentTargets: .iOS(version),
                    sources: ["Core/Sources/**"],
                    dependencies: []
                   ),

            .target(name: "Domain",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Domain",
                    deploymentTargets: .iOS(version),
                    sources: ["Domain/Sources/**"],
                    dependencies: []
                   ),
        
            .target(name: "Data",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Data",
                    deploymentTargets: .iOS(version),
                    sources: ["Data/Sources/**"],
                    resources: ["Data/Resources/**"],
                    dependencies: [
                        .target(name: "Domain"),
                        .external(name: "RealmSwift"),
                        .external(name: "Alamofire")
                    ]
                   ),
        
            .target(name: "Presentation",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Presentation",
                    deploymentTargets: .iOS(version),
                    sources: ["Presentation/Sources/**"],
                    resources: ["Presentation/Resources/**"],
                    dependencies: [
                        .target(name: "Domain"),
                        .target(name: "Data"),
                        .target(name: "Core"),
                        .external(name: "Kingfisher"),
                        .external(name: "SnapKit"),
                        .external(name: "Toast")
                    ]
                   )
    ]
)
