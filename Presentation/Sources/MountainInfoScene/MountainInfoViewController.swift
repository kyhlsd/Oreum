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

        setupNavItem()
        bind()

        viewDidLoadSubject.send(())
    }

    func bind() {
        let input = MountainInfoViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.mountainInfo
            .sink { [weak self] mountainInfo in
                self?.mainView.configure(with: mountainInfo)
                self?.title = mountainInfo.name
            }
            .store(in: &cancellables)
    }

    private func setupNavItem() {
        navigationItem.backButtonTitle = " "
    }
}
