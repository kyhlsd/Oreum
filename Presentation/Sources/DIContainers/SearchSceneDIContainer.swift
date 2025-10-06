//
//  SearchSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data

public final class SearchSceneDIContainer {

    public init() {}

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
        return SearchViewModel(fetchMountainsUseCase: makeFetchMountainsUseCase())
    }

    private func makeMountainInfoViewModel(mountainInfo: MountainInfo) -> MountainInfoViewModel {
        return MountainInfoViewModel(mountainInfo: mountainInfo)
    }

    // MARK: - UseCases
    private func makeFetchMountainsUseCase() -> FetchMountainsUseCase {
        return FetchMountainsUseCaseImpl(repository: makeMountainInfoRepository())
    }

    // MARK: - Repositories
    private func makeMountainInfoRepository() -> MountainInfoRepository {
        return JSONMountainInfoRepositoryImpl()
    }
}
