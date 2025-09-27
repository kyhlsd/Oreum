//
//  RecordSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

protocol RecordSceneFlowCoordinatorDependencies {
    func makeClimbRecordListViewController() -> ClimbRecordListViewController
}

public final class RecordSceneFlowCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    private let dependencies: RecordSceneFlowCoordinatorDependencies
    
    init(
        navigationController: UINavigationController,
        dependencies: RecordSceneFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "기록", image: AppIcon.bookOpen, tag: 0)
        let vc = dependencies.makeClimbRecordListViewController()
        navigationController.pushViewController(vc, animated: false)
    }
    
}
