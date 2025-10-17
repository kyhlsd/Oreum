//
//  SearchSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain

protocol SearchSceneFlowCoordinatorDependencies {
    func makeSearchViewController() -> SearchViewController
    func makeMountainInfoViewController(mountainInfo: MountainInfo) -> MountainInfoViewController
}

public final class SearchSceneFlowCoordinator: Coordinator {

    public let navigationController: UINavigationController
    private let dependencies: SearchSceneFlowCoordinatorDependencies

    init(navigationController: UINavigationController,
                dependencies: SearchSceneFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // 시작 화면 검색 화면
    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "검색", image: AppIcon.search, tag: 3)
        navigationController.navigationBar.tintColor = AppColor.primary

        let searchVC = dependencies.makeSearchViewController()
        searchVC.pushInfoVC = { [weak self] mountainInfo in
            self?.pushMountainInfo(mountainInfo: mountainInfo)
        }
        navigationController.pushViewController(searchVC, animated: false)
    }

    // 산 정보 화면 이동
    private func pushMountainInfo(mountainInfo: MountainInfo) {
        let mountainInfoVC = dependencies.makeMountainInfoViewController(mountainInfo: mountainInfo)
        navigationController.pushViewController(mountainInfoVC, animated: true)
    }
}
