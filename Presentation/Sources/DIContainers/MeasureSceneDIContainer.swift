//
//  MeasureSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data

public final class MeasureSceneDIContainer {

    public init() {}

    public func makeMeasureSceneFlowCoordinator(navigationController: UINavigationController) -> MeasureSceneFlowCoordinator {
        return MeasureSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
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
    
    private func makeTrackActivityRepository() -> TrackActivityRepository {
        return DefaultTrackActivityRepositoryImpl()
    }

    // MARK: - UseCases
    private func makeFetchMountainsUseCase() -> FetchMountainInfosUseCase {
        return FetchMountainInfosUseCaseImpl(repository: makeMountainInfoRepository())
    }

    private func makeRequestTrackActivityAuthorizationUseCase() -> RequestTrackActivityAuthorizationUseCase {
        return RequestTrackActivityAuthorizationUseCaseImpl(repository: makeTrackActivityRepository())
    }

    private func makeStartTrackingActivityUseCase() -> StartTrackingActivityUseCase {
        return StartTrackingActivityUseCaseImpl(repository: makeTrackActivityRepository())
    }

    private func makeGetActivityLogsUseCase() -> GetActivityLogsUseCase {
        return GetActivityLogsUseCaseImpl(repository: makeTrackActivityRepository())
    }

    private func makeStopTrackingActivityUseCase() -> StopTrackingActivityUseCase {
        return StopTrackingActivityUseCaseImpl(repository: makeTrackActivityRepository())
    }

    private func makeGetTrackingStatusUseCase() -> GetTrackingStatusUseCase {
        return GetTrackingStatusUseCaseImpl(repository: makeTrackActivityRepository())
    }

    private func makeGetCurrentActivityDataUseCase() -> GetCurrentActivityDataUseCase {
        return GetCurrentActivityDataUseCaseImpl(repository: makeTrackActivityRepository())
    }

    private func makeObserveActivityDataUpdatesUseCase() -> ObserveActivityDataUpdatesUseCase {
        return ObserveActivityDataUpdatesUseCaseImpl(repository: makeTrackActivityRepository())
    }

    private func makeGetClimbingMountainUseCase() -> GetClimbingMountainUseCase {
        return GetClimbingMountainUseCaseImpl(repository: makeTrackActivityRepository())
    }
    
    private func makeSaveClimbRecordUseCase() -> SaveClimbRecordUseCase {
        return SaveClimbRecordUseCaseImpl(repository: makeClimbRecordRepository())
    }
}

extension MeasureSceneDIContainer: MeasureSceneFlowCoordinatorDependencies {

    // MARK: - ViewControllers
    func makeMeasureViewController() -> MeasureViewController {
        return MeasureViewController(viewModel: makeMeasureViewModel())
    }

    // MARK: - ViewModels
    private func makeMeasureViewModel() -> MeasureViewModel {
        return MeasureViewModel(
            fetchMountainInfosUseCase: makeFetchMountainsUseCase(),
            requestTrackActivityAuthorizationUseCase: makeRequestTrackActivityAuthorizationUseCase(),
            startTrackingActivityUseCase: makeStartTrackingActivityUseCase(),
            getActivityLogsUseCase: makeGetActivityLogsUseCase(),
            stopTrackingActivityUseCase: makeStopTrackingActivityUseCase(),
            getTrackingStatusUseCase: makeGetTrackingStatusUseCase(),
            getCurrentActivityDataUseCase: makeGetCurrentActivityDataUseCase(),
            observeActivityDataUpdatesUseCase: makeObserveActivityDataUpdatesUseCase(),
            getClimbingMountainUseCase: makeGetClimbingMountainUseCase(),
            saveClimbRecordUseCase: makeSaveClimbRecordUseCase()
        )
    }
}
