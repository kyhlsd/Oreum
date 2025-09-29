//
//  ActivityLogViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Combine
import Domain

final class ActivityLogViewController: UIViewController {
    
    private let mainView = ActivityLogView()
    private let viewModel: ActivityLogViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private func bind() {
        
    }
    
    private func setupNavItem() {
        navigationItem.title = "활동 타임라인"
        navigationItem.backButtonTitle = " "
    }
}
