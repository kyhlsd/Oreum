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

    private func makeRequestHealthKitAuthorizationUseCase() -> RequestHealthKitAuthorizationUseCase {
        return RequestHealthKitAuthorizationUseCaseImpl(repository: makeTrackActivityRepository())
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
}

extension MeasureSceneDIContainer: MeasureSceneFlowCoordinatorDependencies {

    // MARK: - ViewControllers
    func makeMeasureViewController() -> MeasureViewController {
        return MeasureViewController(viewModel: makeMeasureViewModel())
    }

    // MARK: - ViewModels
    private func makeMeasureViewModel() -> MeasureViewModel {
        return MeasureViewModel(
            fetchMountainsUseCase: makeFetchMountainsUseCase(),
            requestHealthKitAuthorizationUseCase: makeRequestHealthKitAuthorizationUseCase(),
            startTrackingActivityUseCase: makeStartTrackingActivityUseCase(),
            getActivityLogsUseCase: makeGetActivityLogsUseCase(),
            stopTrackingActivityUseCase: makeStopTrackingActivityUseCase()
        )
    }
}
