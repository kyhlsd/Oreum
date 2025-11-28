import ProjectDescription

let iOSVersion = "16.0"
let teamID = "4QUWH828P3"
let appVersion = "1.4.0"
let buildNumber = "1"

let project = Project(
    name: "Oreum",
    targets: [
        .target(
            name: "Oreum",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.kyh.Oreum",
            deploymentTargets: .iOS(iOSVersion),
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
                    "CFBundleShortVersionString": .string(appVersion),
                    "UIUserInterfaceStyle": "Light",
                    "App Uses Non-Exempty Encryption": false,
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "NSHealthShareUsageDescription": "등산 기록을 위해 걸음 수와 이동 거리 데이터를 사용합니다.",
                    "NSHealthUpdateUsageDescription": "등산 활동 데이터를 저장하기 위해 HealthKit 접근이 필요합니다.",
                    "NSLocationWhenInUseUsageDescription": "내 주위 명산을 표기하기 위해 위치 정보를 사용합니다."
                ]
            ),
            sources: ["Oreum/Sources/**"],
            resources: ["Oreum/Resources/**"],
            entitlements: .file(path: "Oreum/Oreum.entitlements"),
            scripts: [
                .post(
                    script: """
                    "${PROJECT_DIR}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
                    """,
                    name: "Crashlytics",
                    inputPaths: [
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
                        "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
                        "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)",
                        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}.debug.dylib"
                    ]
                )
            ],
            dependencies: [
                .target(name: "Presentation"),
                .target(name: "Domain"),
                .target(name: "Data"),
                .target(name: "Core"),
                .target(name: "OreumWidgetExtension"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseCrashlytics")
            ],
            settings: .settings(
                base: [
                    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                    "CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION": "YES",
                    "OTHER_LDFLAGS": "$(inherited) -ObjC",
                    "DEVELOPMENT_TEAM": .string(teamID),
                    "MARKETING_VERSION": .string(appVersion),
                    "CURRENT_PROJECT_VERSION": .string(buildNumber)
                ],
                configurations: [
                    .release(name: .release, settings: [
                        "CODE_SIGN_STYLE": "Manual",
                        "CODE_SIGN_IDENTITY": "Apple Distribution"
                    ])
                ]
            )
        ),

            .target(name: "Core",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Core",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Core/Sources/**"],
                    dependencies: [],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID)
                        ]
                    )
                   ),

            .target(name: "Domain",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Domain",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Domain/Sources/**"],
                    dependencies: [
                        .target(name: "Core")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID)
                        ]
                    )
                   ),

            .target(name: "DomainTests",
                    destinations: [.iPhone],
                    product: .unitTests,
                    bundleId: "com.kyh.DomainTests",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["DomainTests/**"],
                    dependencies: [
                        .target(name: "Domain"),
                        .target(name: "Data")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID)
                        ]
                    )
                   ),
        
            .target(name: "Data",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Data",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Data/Sources/**"],
                    resources: ["Data/Resources/**"],
                    dependencies: [
                        .target(name: "Core"),
                        .target(name: "Domain"),
                        .external(name: "RealmSwift"),
                        .external(name: "Alamofire"),
                        .external(name: "XMLCoder")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID)
                        ]
                    )
                   ),
        
            .target(name: "Presentation",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Presentation",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Presentation/Sources/**"],
                    resources: ["Presentation/Resources/**"],
                    dependencies: [
                        .target(name: "Domain"),
                        .target(name: "Data"),
                        .target(name: "Core"),
                        .external(name: "Kingfisher"),
                        .external(name: "SnapKit"),
                        .external(name: "Toast")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID)
                        ]
                    )
                   ),

            .target(name: "OreumWidgetExtension",
                    destinations: [.iPhone],
                    product: .appExtension,
                    bundleId: "com.kyh.Oreum.OreumWidget",
                    deploymentTargets: .iOS(iOSVersion),
                    infoPlist: .extendingDefault(
                        with: [
                            "CFBundleDisplayName": "오름 위젯",
                            "NSExtension": [
                                "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                            ]
                        ]
                    ),
                    sources: ["OreumWidget/Sources/**"],
                    resources: [],
                    entitlements: .file(path: "OreumWidget/OreumWidget.entitlements"),
                    dependencies: [
                        .target(name: "Core")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID)
                        ],
                        configurations: [
                            .release(name: .release, settings: [
                                "CODE_SIGN_STYLE": "Manual",
                                "CODE_SIGN_IDENTITY": "Apple Distribution"
                            ])
                        ]
                    )
                   )
    ]
)

