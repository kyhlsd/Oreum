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

    // 첫 화면 기록 리스트 화면
    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "기록", image: AppIcon.bookOpen, tag: 0)
        navigationController.navigationBar.tintColor = AppColor.primary

        let listVC = dependencies.makeClimbRecordListViewController()
        listVC.pushDetailVC = { [weak self] climbRecord in
            self?.showDetailFromList(climbRecord: climbRecord, listVC: listVC)
        }
        listVC.presentAddVC = { [weak self] in
            self?.showAddClimbRecord()
        }

        navigationController.pushViewController(listVC, animated: false)
    }

    // 기존 기록 상세 화면 이동
    private func showDetailFromList(climbRecord: ClimbRecord, listVC: ClimbRecordListViewController) {
        let detailVC = dependencies.makeClimbRecordDetailViewController(climbRecord: climbRecord, isFromAddRecord: false)
        detailVC.popVC = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        detailVC.pushVC = { [weak self] climbRecord in
            self?.showActivityLog(climbRecord: climbRecord)
        }
        detailVC.viewModel.delegate = listVC.viewModel

        navigationController.pushViewController(detailVC, animated: true)
    }

    // 새로운 기록 생성 화면 이동
    private func showAddClimbRecord() {
        let addVC = dependencies.makeAddClimbRecordViewController()
        addVC.dismissVC = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        addVC.pushVC = { [weak self] climbRecord in
            self?.showDetailFromAdd(climbRecord: climbRecord, addVC: addVC)
        }

        let navController = UINavigationController(rootViewController: addVC)
        navController.modalPresentationStyle = .fullScreen
        navigationController.present(navController, animated: true)
    }

    // 새로운 기록 생성에서 상세 화면 이동
    private func showDetailFromAdd(climbRecord: ClimbRecord, addVC: AddClimbRecordViewController) {
        let detailVC = dependencies.makeClimbRecordDetailViewController(climbRecord: climbRecord, isFromAddRecord: true)
        detailVC.isFromAddRecord = true
        detailVC.popVC = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        detailVC.pushVC = { [weak self] climbRecord in
            self?.showActivityLogFromAdd(climbRecord: climbRecord, addVC: addVC)
        }

        addVC.navigationController?.pushViewController(detailVC, animated: true)
    }

    // 기존 기록에서 통계 화면 이동
    private func showActivityLog(climbRecord: ClimbRecord) {
        let activityVC = dependencies.makeActivityLogViewController(climbRecord: climbRecord)
        navigationController.pushViewController(activityVC, animated: true)
    }

    // 기록 추가에서 통계 화면 이동
    private func showActivityLogFromAdd(climbRecord: ClimbRecord, addVC: AddClimbRecordViewController) {
        let activityVC = dependencies.makeActivityLogViewController(climbRecord: climbRecord)
        addVC.navigationController?.pushViewController(activityVC, animated: true)
    }

    // 측정에서 기록 상세 화면으로 이동
    public func showDetailFromMeasure(climbRecord: ClimbRecord) {
        // 네비게이션 스택 초기화 후 리스트 VC로 돌아감
        navigationController.popToRootViewController(animated: false)

        // 기록 상세 화면 표기
        guard let listVC = navigationController.viewControllers.first as? ClimbRecordListViewController else { return }

        let detailVC = dependencies.makeClimbRecordDetailViewController(climbRecord: climbRecord, isFromAddRecord: false)
        detailVC.popVC = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        detailVC.pushVC = { [weak self] climbRecord in
            self?.showActivityLog(climbRecord: climbRecord)
        }
        detailVC.viewModel.delegate = listVC.viewModel

        navigationController.pushViewController(detailVC, animated: true)
    }

}
