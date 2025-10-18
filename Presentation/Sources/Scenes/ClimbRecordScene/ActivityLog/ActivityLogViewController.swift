//
//  ActivityLogViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Domain

final class ActivityLogViewController: UIViewController, BaseViewController {
    
    let mainView = ActivityLogView()
    let viewModel: ActivityLogViewModel
    
    init(viewModel: ActivityLogViewModel) {
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
    
    func bind() {
        let input = ActivityLogViewModel.Input()
        let output = viewModel.transform(input: input)
        
        mainView.setMountainName(name: output.mountainName)
        mainView.setStat(activityStat: output.activityStat)
        mainView.setActivityLogs(activityLogs: output.activityLogs)
    }
    
    private func setupNavItem() {
        navigationItem.title = "활동 타임라인"
        navigationItem.backButtonTitle = " "
    }
}
