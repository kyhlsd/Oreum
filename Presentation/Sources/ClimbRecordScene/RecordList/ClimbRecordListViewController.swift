//
//  ClimbRecordListViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Combine

final class ClimbRecordListViewController: UIViewController {

    private let mainView = ClimbRecordListView()
    private let viewModel: ClimbRecordListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ClimbRecordListViewModel) {
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
        setupNavItem()
    }
    
    private func bind() {
        let input = ClimbRecordListViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            searchText: mainView.searchBar.textDidChange
        )
        
        let output = viewModel.transform(input: input)
        
        output.climbRecordList
            .sink { [weak self] recordList in
                self?.mainView.setClimbRecords(items: recordList)
            }
            .store(in: &cancellables)
        
        output.guideText
            .sink { [weak self] text in
                self?.mainView.setGuideLabelText(text)
            }
            .store(in: &cancellables)
        
        output.errorMessage
            .sink { errorMessage in
               print(errorMessage)
            }
            .store(in: &cancellables)
    }

    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "나의 등산 기록"))
        navigationItem.backButtonTitle = " "
    }
}
