//
//  MountainInfoViewController.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit
import Combine
import Domain

final class MountainInfoViewController: UIViewController, BaseViewController, NetworkStatusObservable {

    let mainView = MountainInfoView()
    let viewModel: MountainInfoViewModel

    var networkStatusBanner: NetworkStatusBannerView?
    var networkStatusCancellable: AnyCancellable?
    
    private var cancellables = Set<AnyCancellable>()
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let viewDidAppearSubject = PassthroughSubject<Void, Never>()

    init(viewModel: MountainInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDelegates()
        setupNetworkStatusObserver()
        bind()

        viewDidLoadSubject.send(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewDidAppearSubject.send(())
    }
    
    deinit {
        removeNetworkStatusObserver()
    }

    func bind() {
        let input = MountainInfoViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            viewDidAppear: viewDidAppearSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        // 산 기본 정보
        output.mountainInfo
            .sink { [weak self] info in
                self?.navigationItem.title = info.name
                self?.mainView.setMountainInfo(info)
            }
            .store(in: &cancellables)

        // 이미지
        output.imageURLs
            .sink { [weak self] imageURLs in
                self?.mainView.imageCollectionView.reloadData()
                self?.mainView.showEmptyImageState(imageURLs.isEmpty)
            }
            .store(in: &cancellables)

        // 날씨
        output.weeklyForecast
            .sink { [weak self] weeklyForecast in
                self?.mainView.setWeeklyForecast(weeklyForecast)
            }
            .store(in: &cancellables)

        // 에러 Alert
        output.errorMessage
            .sink { [weak self] (title, message) in
                self?.presentDefaultAlert(title: title, message: message)
                self?.mainView.showWeatherLoadingError()
            }
            .store(in: &cancellables)
    }
    
    private func setupDelegates() {
        mainView.imageCollectionView.dataSource = self
    }
    
}

// MARK: - UICollectionViewDataSource
extension MountainInfoViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageURLStrings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellClass: ImageCollectionViewCell.self)

        let imageURLString = viewModel.imageURLStrings[indexPath.item]
        cell.setImage(urlString: imageURLString)

        return cell
    }
}
