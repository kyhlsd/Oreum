//
//  MeasureSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data
import Core

public final class MeasureSceneDIContainer {

    private let configuration: EnvironmentConfigurable
    
    private lazy var climbRecordRepository = makeClimbRecordRepository()
    private lazy var mountainInfoRepository = makeMountainInfoRepository()
    private lazy var trackActivityRepository = makeTrackActivityRepository()
    
    public init(configuration: EnvironmentConfigurable) {
        self.configuration = configuration
    }

    public func makeMeasureSceneFlowCoordinator(navigationController: UINavigationController) -> MeasureSceneFlowCoordinator {
        return MeasureSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
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
            searchMountainUseCase: makeSearchMountainUseCase(),
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
    
    // MARK: - Repositories
    private func makeClimbRecordRepository() -> ClimbRecordRepository {
        switch configuration.environment {
        case .release, .dev:
            return RealmClimbRecordRepositoryImpl()
        case .dummy:
            return DummyClimbRecordRepositoryImpl.shared
        }
    }

    private func makeMountainInfoRepository() -> MountainInfoRepository {
        switch configuration.environment {
        case .release, .dev:
            return DefaultMountainInfoRepositoryImpl()
        case .dummy:
            return DummyMountainInfoRepositoryImpl()
        }
    }

    private func makeTrackActivityRepository() -> TrackActivityRepository {
        switch configuration.environment {
        case .release, .dev:
            return HealthKitTrackActivityRepositoryImpl()
        case .dummy:
            return DummyTrackActivityRepositoryImpl.shared
        }
    }

    // MARK: - UseCases
    private func makeSearchMountainUseCase() -> SearchMountainUseCase {
        return SearchMountainUseCaseImpl(repository: mountainInfoRepository)
    }

    private func makeRequestTrackActivityAuthorizationUseCase() -> RequestTrackActivityAuthorizationUseCase {
        return RequestTrackActivityAuthorizationUseCaseImpl(repository: trackActivityRepository)
    }

    private func makeStartTrackingActivityUseCase() -> StartTrackingActivityUseCase {
        return StartTrackingActivityUseCaseImpl(repository: trackActivityRepository)
    }

    private func makeGetActivityLogsUseCase() -> GetActivityLogsUseCase {
        return GetActivityLogsUseCaseImpl(repository: trackActivityRepository)
    }

    private func makeStopTrackingActivityUseCase() -> StopTrackingActivityUseCase {
        return StopTrackingActivityUseCaseImpl(repository: trackActivityRepository)
    }

    private func makeGetTrackingStatusUseCase() -> GetTrackingStatusUseCase {
        return GetTrackingStatusUseCaseImpl(repository: trackActivityRepository)
    }

    private func makeGetCurrentActivityDataUseCase() -> GetCurrentActivityDataUseCase {
        return GetCurrentActivityDataUseCaseImpl(repository: trackActivityRepository)
    }

    private func makeObserveActivityDataUpdatesUseCase() -> ObserveActivityDataUpdatesUseCase {
        return ObserveActivityDataUpdatesUseCaseImpl(repository: trackActivityRepository)
    }

    private func makeGetClimbingMountainUseCase() -> GetClimbingMountainUseCase {
        return GetClimbingMountainUseCaseImpl(repository: trackActivityRepository)
    }
    
    private func makeSaveClimbRecordUseCase() -> SaveClimbRecordUseCase {
        return SaveClimbRecordUseCaseImpl(repository: climbRecordRepository)
    }
    
}
