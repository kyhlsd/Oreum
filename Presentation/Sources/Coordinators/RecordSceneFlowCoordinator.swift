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
    func makeClimbRecordDetailViewController(climbRecord: ClimbRecord, isFromAddRecord: Bool) -> ClimbRecordDetailViewController
    func makeActivityLogViewController(climbRecord: ClimbRecord) -> ActivityLogViewController
    func makeAddClimbRecordViewController() -> AddClimbRecordViewController
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

            let detailVC = self.dependencies.makeClimbRecordDetailViewController(climbRecord: climbRecord, isFromAddRecord: false)
            detailVC.popVC = { [weak self] in
                self?.navigationController.popViewController(animated: true)
            }
            detailVC.pushVC = { [weak self] climbRecord in
                guard let self else { return }
                navigationController.pushViewController(dependencies.makeActivityLogViewController(climbRecord: climbRecord), animated: true)
            }
            detailVC.viewModel.delegate = listVC.viewModel

            self.navigationController.pushViewController(detailVC, animated: true)
        }

        listVC.pushAddVC = { [weak self] in
            guard let self else { return }

            let addVC = self.dependencies.makeAddClimbRecordViewController()
            addVC.dismissVC = { [weak self] in
                self?.navigationController.dismiss(animated: true)
            }
            addVC.pushVC = { [weak self] climbRecord in
                guard let self else { return }

                let detailVC = self.dependencies.makeClimbRecordDetailViewController(climbRecord: climbRecord, isFromAddRecord: true)
                detailVC.isFromAddRecord = true
                detailVC.popVC = { [weak self] in
                    self?.navigationController.dismiss(animated: true)
                }
                detailVC.pushVC = { [weak self] climbRecord in
                    guard let self else { return }
                    let activityVC = self.dependencies.makeActivityLogViewController(climbRecord: climbRecord)
                    addVC.navigationController?.pushViewController(activityVC, animated: true)
                }

                addVC.navigationController?.pushViewController(detailVC, animated: true)
            }

            let navController = UINavigationController(rootViewController: addVC)
            self.navigationController.present(navController, animated: true)
        }

        navigationController.pushViewController(listVC, animated: false)
    }
    
}
