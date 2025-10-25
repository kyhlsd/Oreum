//
//  SearchSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data
import Core

public final class SearchSceneDIContainer {

    private let configuration: EnvironmentConfigurable

    private lazy var recentSearchRepository = makeRecentSearchRepository()
    private lazy var mountainInfoRepository = makeMountainInfoRepository()
    private lazy var forecastRepository = makeForecastRepository()
    private lazy var geocodeRepository = makeGeocodeRepository()
    
    public init(configuration: EnvironmentConfigurable) {
        self.configuration = configuration
    }

    public func makeSearchSceneFlowCoordinator(navigationController: UINavigationController) -> SearchSceneFlowCoordinator {
        return SearchSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension SearchSceneDIContainer: SearchSceneFlowCoordinatorDependencies {

    // MARK: - ViewControllers
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController(viewModel: makeSearchViewModel())
    }

    func makeMountainInfoViewController(mountainInfo: MountainInfo) -> MountainInfoViewController {
        return MountainInfoViewController(viewModel: makeMountainInfoViewModel(mountainInfo: mountainInfo))
    }

    // MARK: - ViewModels
    private func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(
            searchMountainUseCase: makeSearchMountainUseCase(),
            fetchRecentSearchesUseCase: makeFetchRecentSearchesUseCase(),
            saveRecentSearchUseCase: makeSaveRecentSearchUseCase(),
            deleteRecentSearchUseCase: makeDeleteRecentSearchUseCase(),
            clearRecentSearchesUseCase: makeClearRecentSearchesUseCase()
        )
    }

    private func makeMountainInfoViewModel(mountainInfo: MountainInfo) -> MountainInfoViewModel {
        return MountainInfoViewModel(
            fetchCoordinateUseCase: makeFetchCoordinateUseCase(),
            fetchWeeklyForecastUseCase: makeFetchWeeklyForecastUseCase(),
            fetchMountainImageUseCase: makeFetchMountainImageUseCase(),
            mountainInfo: mountainInfo
        )
    }

    // MARK: - UseCases
    private func makeSearchMountainUseCase() -> SearchMountainUseCase {
        return SearchMountainUseCaseImpl(repository: mountainInfoRepository)
    }

    private func makeFetchRecentSearchesUseCase() -> FetchRecentSearchesUseCase {
        return FetchRecentSearchesUseCaseImpl(repository: recentSearchRepository)
    }

    private func makeSaveRecentSearchUseCase() -> SaveRecentSearchUseCase {
        return SaveRecentSearchUseCaseImpl(repository: recentSearchRepository)
    }

    private func makeDeleteRecentSearchUseCase() -> DeleteRecentSearchUseCase {
        return DeleteRecentSearchUseCaseImpl(repository: recentSearchRepository)
    }

    private func makeClearRecentSearchesUseCase() -> ClearRecentSearchesUseCase {
        return ClearRecentSearchesUseCaseImpl(repository: recentSearchRepository)
    }

    private func makeFetchCoordinateUseCase() -> FetchCoordinateUseCase {
        return FetchCoordinateUseCaseImpl(repository: makeGeocodeRepository())
    }
    
    private func makeFetchWeeklyForecastUseCase() -> FetchWeeklyForecastUseCase {
        return FetchWeeklyForecastUseCaseImpl(repository: makeForecastRepository())
    }

    private func makeFetchMountainImageUseCase() -> FetchMountainImageUseCase {
        return FetchMountainImageUseCaseImpl(repository: mountainInfoRepository)
    }

    // MARK: - Repositories
    private func makeMountainInfoRepository() -> MountainInfoRepository {
        switch configuration.environment {
        case .release, .dev:
            return DefaultMountainInfoRepositoryImpl()
        case .dummy:
            return DummyMountainInfoRepositoryImpl()
        }
    }

    private func makeRecentSearchRepository() -> RecentSearchRepository {
        switch configuration.environment {
        case .release, .dev:
            return RealmRecentSearchRepositoryImpl()
        case .dummy:
            return DummyRecentSearchRepositoryImpl.shared
        }
    }

    private func makeGeocodeRepository() -> GeocodeRepository {
        switch configuration.environment {
        case .release, .dev:
            return DefaultGeocodeRepositoryImpl()
        case .dummy:
            return DummyGeocodeRepositoryImpl()
        }
    }

    private func makeForecastRepository() -> ForecastRepository {
        switch configuration.environment {
        case .release, .dev:
            return DefaultForecastRepositoryImpl()
        case .dummy:
            return DummyForecastRepositoryImpl()
        }
    }
    
}
