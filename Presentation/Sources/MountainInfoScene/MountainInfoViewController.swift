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

        output.mountainName
            .sink { [weak self] name in
                self?.navigationItem.title = name
                self?.mainView.setMountainName(name)
            }
            .store(in: &cancellables)

        output.address
            .sink { [weak self] address in
                self?.mainView.setAddress(address)
            }
            .store(in: &cancellables)

        output.height
            .sink { [weak self] height in
                self?.mainView.setHeight(height)
            }
            .store(in: &cancellables)

        output.introduction
            .sink { [weak self] introduction in
                let attributedText = self?.createIntroductionAttributedString(from: introduction) ?? NSAttributedString()
                self?.mainView.setIntroduction(attributedText)
            }
            .store(in: &cancellables)

        output.imageURL
            .sink { [weak self] imageURL in
                self?.mainView.setImage(imageURL)
            }
            .store(in: &cancellables)
        
        output.weeklyForecast
            .sink { [weak self] weeklyForecast in
                self?.mainView.setWeeklyForecast(weeklyForecast)
            }
            .store(in: &cancellables)
        
        output.errorMessage
            .sink { [weak self] message in
                print(message)
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
