//
//  MapSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain

protocol MapSceneFlowCoordinatorDependencies {
    func makeMapViewController() -> MapViewController
    func makeMountainInfoViewController(mountainInfo: MountainInfo) -> MountainInfoViewController
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

    // 첫 화면 맵뷰
    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "지도", image: AppIcon.map, tag: 2)
        navigationController.navigationBar.tintColor = AppColor.primary

        let mapVC = dependencies.makeMapViewController()
        mapVC.pushInfoVC = { [weak self] mountainInfo in
            self?.showMountainInfoFromMap(mountainInfo: mountainInfo)
        }
        
        navigationController.pushViewController(mapVC, animated: false)
    }
    
    // 산 정보 뷰 이동
    private func showMountainInfoFromMap(mountainInfo: MountainInfo) {
        let mountainInfoVC = dependencies.makeMountainInfoViewController(mountainInfo: mountainInfo)
        
        navigationController.pushViewController(mountainInfoVC, animated: true)
    }
}
