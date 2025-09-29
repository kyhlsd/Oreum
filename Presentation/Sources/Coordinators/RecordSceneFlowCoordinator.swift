//
//  RecordSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain

protocol RecordSceneFlowCoordinatorDependencies {
    func makeClimbRecordListViewController() -> ClimbRecordListViewController
    func makeClimbRecordDetailViewController(climbRecord: ClimbRecord) -> ClimbRecordDetailViewController
}

public final class RecordSceneFlowCoordinator: Coordinator {
    
    public let navigationController: UINavigationController
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
        navigationController.navigationBar.tintColor = AppColor.primary
        
        let listVC = dependencies.makeClimbRecordListViewController()
        listVC.pushVC = { [weak self] climbRecord in
            guard let self else { return }
            
            let detailVC = self.dependencies.makeClimbRecordDetailViewController(climbRecord: climbRecord)
            detailVC.popVC = { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
            detailVC.viewModel.delegate = listVC.viewModel
            
            self.navigationController.pushViewController(detailVC, animated: true)
        }
        
        navigationController.pushViewController(listVC, animated: false)
    }
    
}
