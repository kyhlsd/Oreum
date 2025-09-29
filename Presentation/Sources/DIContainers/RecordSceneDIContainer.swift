//
//  RecordSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain

public final class RecordSceneDIContainer {
    
    private lazy var climbRecordRepository = makeClimbRecordRepository()
    
    public init() {}
    
    public func makeRecordSceneFlowCoordinator(navigationController: UINavigationController) -> RecordSceneFlowCoordinator {
        return RecordSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension RecordSceneDIContainer: RecordSceneFlowCoordinatorDependencies {
    
    func makeClimbRecordListViewController() -> ClimbRecordListViewController {
        return ClimbRecordListViewController(viewModel: makeClimbRecordListViewModel())
    }
    
    func makeClimbRecordDetailViewController(climbRecord: ClimbRecord) -> ClimbRecordDetailViewController {
        return ClimbRecordDetailViewController(viewModel: makeClimbRecordDetailViewModel(climbRecord: climbRecord))
    }
    
    private func makeClimbRecordListViewModel() -> ClimbRecordListViewModel {
        return ClimbRecordListViewModel(fetchUseCase: makeFetchClimbRecordsUseCase(), toggleBookmarkUseCase: makeToggleBookmarkUseCase())
    }
    
    private func makeClimbRecordDetailViewModel(climbRecord: ClimbRecord) -> ClimbRecordDetailViewModel {
        return ClimbRecordDetailViewModel(updateUseCase: makeUpdateUseCase(), deleteUseCase: makeDeleteClimbRecordUseCase(), climbRecord: climbRecord)
    }
    
    private func makeFetchClimbRecordsUseCase() -> FetchClimbRecordUseCase {
        return FetchClimbRecordUseCaseImpl(repository: climbRecordRepository)
    }
    
    private func makeToggleBookmarkUseCase() -> ToggleBookmarkUseCase {
        return ToggleBookmarkUseCaseImpl(repository: climbRecordRepository)
    }
    
    private func makeUpdateUseCase() -> UpdateClimbRecordUseCase {
        return UpdateClimbRecordUseCaseImpl(repository: climbRecordRepository)
    }
    
    private func makeDeleteClimbRecordUseCase() -> DeleteClimbRecordUseCase {
        return DeleteClimbRecordUseCaseImpl(repository: climbRecordRepository)
    }
    
    private func makeClimbRecordRepository() -> ClimbRecordRepository {
        return ClimbRecordRepositoryImpl()
    }
}
