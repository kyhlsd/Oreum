//
//  RecordSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data
import Core

public final class RecordSceneDIContainer {

    private let configuration: EnvironmentConfigurable
    private lazy var climbRecordRepository = makeClimbRecordRepository()
    private lazy var recordImageRepository = makeRecordImageRepository()

    public init(configuration: EnvironmentConfigurable) {
        self.configuration = configuration
    }
    
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
        return ClimbRecordDetailViewModel(updateUseCase: makeUpdateUseCase(), deleteUseCase: makeDeleteClimbRecordUseCase(), saveClimbRecordUseCase: makeSaveClimbRecordUseCase(), saveRecordImageUseCase: makeSaveRecordImageUseCase(), fetchRecordImageUseCase: makeFetchRecordImageUseCase(), deleteRecordImageUseCase: makeDeleteRecordImageUseCase(), addImageToRecordUseCase: makeAddImageToRecordUseCase(), removeImageFromRecordUseCase: makeRemoveImageFromRecordUseCase(), climbRecord: climbRecord, isFromAddRecord: isFromAddRecord)
    }
    
    private func makeActivityLogViewModel(climbRecord: ClimbRecord) -> ActivityLogViewModel {
        return ActivityLogViewModel(activityStatUseCase: makeActivityStatUseCase(), climbRecord: climbRecord)
    }

    private func makeAddClimbRecordViewModel() -> AddClimbRecordViewModel {
        return AddClimbRecordViewModel(
            fetchMountainsUseCase: makeFetchMountainsUseCase(),
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

    private func makeFetchMountainsUseCase() -> FetchMountainsUseCase {
        return FetchMountainsUseCaseImpl(repository: makeMountainInfoRepository())
    }
    
    private func makeSaveRecordImageUseCase() -> SaveRecordImageUseCase {
        return SaveRecordImageUseCaseImpl(repository: recordImageRepository)
    }

    private func makeFetchRecordImageUseCase() -> FetchRecordImageUseCase {
        return FetchRecordImageUseCaseImpl(repository: recordImageRepository)
    }

    private func makeDeleteRecordImageUseCase() -> DeleteRecordImageUseCase {
        return DeleteRecordImageUseCaseImpl(repository: recordImageRepository)
    }

    private func makeAddImageToRecordUseCase() -> AddImageToRecordUseCase {
        return AddImageToRecordUseCaseImpl(repository: climbRecordRepository)
    }

    private func makeRemoveImageFromRecordUseCase() -> RemoveImageFromRecordUseCase {
        return RemoveImageFromRecordUseCaseImpl(repository: climbRecordRepository)
    }

    // MARK: - Repositories
    private func makeClimbRecordRepository() -> ClimbRecordRepository {
        switch configuration.environment {
        case .release, .dev:
            do {
                return try RealmClimbRecordRepositoryImpl()
            } catch {
                print("Failed to initialize Realm: \(error.localizedDescription)")
                return ErrorClimbRecordRepositoryImpl()
            }
        case .dummy:
            return DummyClimbRecordRepositoryImpl.shared
        }
    }
    
    private func makeMountainInfoRepository() -> MountainInfoRepository {
        return JSONMountainInfoRepositoryImpl()
    }
    
    private func makeRecordImageRepository() -> RecordImageRepository {
        switch configuration.environment {
        case .release, .dev:
            return FileManagerRecordImageRepositoryImpl()
        case .dummy:
            return DummyRecordImageRepositoryImpl.shared
        }
    }
}
