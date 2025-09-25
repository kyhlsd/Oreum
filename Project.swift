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
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Oreum/Sources/**"],
            resources: ["Oreum/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "OreumTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.OreumTests",
            infoPlist: .default,
            sources: ["Oreum/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Oreum")]
        ),
    ]
)
