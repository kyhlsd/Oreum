//
//  RecordSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data

public final class RecordSceneDIContainer {
    
    private lazy var climbRecordRepository = makeClimbRecordRepository()
    
    public init() {}
    
    public func makeRecordSceneFlowCoordinator(navigationController: UINavigationController) -> RecordSceneFlowCoordinator {
        return RecordSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension RecordSceneDIContainer: RecordSceneFlowCoordinatorDependencies {
    
    // MARK: - ViewControllers
    func makeClimbRecordListViewController() -> ClimbRecordListViewController {
        return ClimbRecordListViewController(viewModel: makeClimbRecordListViewModel())
    }
    
    func makeClimbRecordDetailViewController(climbRecord: ClimbRecord, isFromAddRecord: Bool) -> ClimbRecordDetailViewController {
        return ClimbRecordDetailViewController(viewModel: makeClimbRecordDetailViewModel(climbRecord: climbRecord, isFromAddRecord: isFromAddRecord))
    }
    
    func makeActivityLogViewController(climbRecord: ClimbRecord) -> ActivityLogViewController {
        return ActivityLogViewController(viewModel: makeActivityLogViewModel(climbRecord: climbRecord))
    }

    func makeAddClimbRecordViewController() -> AddClimbRecordViewController {
        return AddClimbRecordViewController(viewModel: makeAddClimbRecordViewModel())
    }

    // MARK: - ViewModels
    private func makeClimbRecordListViewModel() -> ClimbRecordListViewModel {
        return ClimbRecordListViewModel(fetchUseCase: makeFetchClimbRecordsUseCase(), toggleBookmarkUseCase: makeToggleBookmarkUseCase())
    }
    
    private func makeClimbRecordDetailViewModel(climbRecord: ClimbRecord, isFromAddRecord: Bool = false) -> ClimbRecordDetailViewModel {
        let saveUseCase = isFromAddRecord ? makeSaveClimbRecordUseCase() : nil
        return ClimbRecordDetailViewModel(updateUseCase: makeUpdateUseCase(), deleteUseCase: makeDeleteClimbRecordUseCase(), climbRecord: climbRecord, saveClimbRecordUseCase: saveUseCase)
    }
    
    private func makeActivityLogViewModel(climbRecord: ClimbRecord) -> ActivityLogViewModel {
        return ActivityLogViewModel(activityStatUseCase: makeActivityStatUseCase(), climbRecord: climbRecord)
    }

    private func makeAddClimbRecordViewModel() -> AddClimbRecordViewModel {
        return AddClimbRecordViewModel(
            fetchMountainInfosUseCase: makeFetchMountainInfosUseCase(),
            saveClimbRecordUseCase: makeSaveClimbRecordUseCase()
        )
    }

    // MARK: - UseCases
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
    
    private func makeActivityStatUseCase() -> ActivityStatUseCase {
        return ActivityStatUseCaseImpl()
    }

    private func makeSaveClimbRecordUseCase() -> SaveClimbRecordUseCase {
        return SaveClimbRecordUseCaseImpl(repository: climbRecordRepository)
    }

    private func makeFetchMountainInfosUseCase() -> FetchMountainInfosUseCase {
        return FetchMountainInfosUseCaseImpl(repository: makeMountainInfoRepository())
    }

    // MARK: - Repositories
    private func makeClimbRecordRepository() -> ClimbRecordRepository {
        do {
            return try DefaultClimbRecordRepositoryImpl()
        } catch {
            print("Failed to initialize Realm: \(error.localizedDescription)")
            return ErrorClimbRecordRepositoryImpl()
        }
    }
    
    private func makeMountainInfoRepository() -> MountainInfoRepository {
        return DummyMountainInfoRepositoryImpl()
    }
}
