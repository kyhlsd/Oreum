//
//  MountainInfoViewController.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit
import Combine
import Domain

final class MountainInfoViewController: UIViewController, BaseViewController {

    let mainView = MountainInfoView()
    let viewModel: MountainInfoViewModel

    private var cancellables = Set<AnyCancellable>()
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private lazy var imageDataSource = createImageDataSource()

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

        bind()

        viewDidLoadSubject.send(())
    }

    func bind() {
        let input = MountainInfoViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        // 산 이름
        output.mountainName
            .sink { [weak self] name in
                self?.navigationItem.title = name
                self?.mainView.setMountainName(name)
            }
            .store(in: &cancellables)

        // 주소
        output.address
            .sink { [weak self] address in
                self?.mainView.setAddress(address)
            }
            .store(in: &cancellables)
        
        // 높이
        output.height
            .sink { [weak self] height in
                self?.mainView.setHeight(height)
            }
            .store(in: &cancellables)

        // 산 소개 문구
        output.introduction
            .sink { [weak self] introduction in
                let attributedText = self?.createIntroductionAttributedString(from: introduction) ?? NSAttributedString()
                self?.mainView.setIntroduction(attributedText)
            }
            .store(in: &cancellables)

        // 이미지
        output.imageURLs
            .sink { [weak self] imageURLs in
                self?.applyImageSnapshot(imageURLs: imageURLs)
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

    private func createIntroductionAttributedString(from text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8

        if text.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: AppFont.body,
                .foregroundColor: AppColor.tertiaryText
            ]
            return NSAttributedString(string: "소개 문구가 없습니다.", attributes: attributes)
        } else {
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: AppFont.body,
                .foregroundColor: AppColor.subText
            ]
            return NSAttributedString(string: text, attributes: attributes)
        }
    }
}

// MARK: - CollectionView SubMethods
extension MountainInfoViewController {

    private enum Section: CaseIterable {
        case main
    }

    private func createImageRegistration() -> UICollectionView.CellRegistration<ImageCollectionViewCell, URL> {
        return UICollectionView.CellRegistration<ImageCollectionViewCell, URL> { cell, indexPath, item in
            cell.setImage(url: item)
        }
    }

    private func createImageDataSource() -> UICollectionViewDiffableDataSource<Section, URL> {
        let registration = createImageRegistration()
        return UICollectionViewDiffableDataSource<Section, URL>(collectionView: mainView.imageCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func applyImageSnapshot(imageURLs: [URL]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, URL>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(imageURLs)
        imageDataSource.apply(snapshot, animatingDifferences: true)
    }
}
