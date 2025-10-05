//
//  MapSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

protocol MapSceneFlowCoordinatorDependencies {
    func makeMapViewController() -> MapViewController
}

public final class MapSceneFlowCoordinator: Coordinator {

    public let navigationController: UINavigationController
    private let dependencies: MapSceneFlowCoordinatorDependencies

    init(
        navigationController: UINavigationController,
        dependencies: MapSceneFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "지도", image: AppIcon.map, tag: 2)
        navigationController.navigationBar.tintColor = AppColor.primary

        let mapVC = dependencies.makeMapViewController()
        navigationController.pushViewController(mapVC, animated: false)
    }
}
