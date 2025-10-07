//
//  MeasureSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain

protocol MeasureSceneFlowCoordinatorDependencies {
    func makeMeasureViewController() -> MeasureViewController
}

public final class MeasureSceneFlowCoordinator: Coordinator {

    public let navigationController: UINavigationController
    private let dependencies: MeasureSceneFlowCoordinatorDependencies
    public weak var parentCoordinator: ParentCoordinator?

    init(
        navigationController: UINavigationController,
        dependencies: MeasureSceneFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "측정", image: AppIcon.activity, tag: 1)
        navigationController.navigationBar.tintColor = AppColor.primary

        let measureVC = dependencies.makeMeasureViewController()
        measureVC.showRecordDetail = { [weak self] climbRecord in
            self?.parentCoordinator?.showClimbRecordDetail(climbRecord: climbRecord)
        }

        navigationController.pushViewController(measureVC, animated: false)
    }
}
