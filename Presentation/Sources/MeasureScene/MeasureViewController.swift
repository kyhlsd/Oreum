//
//  MeasureViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit

final class MeasureViewController: UIViewController, BaseViewController {
    
    let mainView = MeasureView()
    let viewModel: MeasureViewModel
    
    init(viewModel: MeasureViewModel) {
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
        setupDelegates()
    }
    
    func bind() {
        mainView.setSelectViewsEnabled(true)
        mainView.setStartButtonEnabled(false)
        mainView.setMountainBoxIsHidden(false)
        mainView.setSelectedMountain(name: "백두산", address: "중국 지린성 연변조선족자치주")
    }
    
    private func setNavItem(isMeasuring: Bool) {
        navigationItem.leftBarButtonItem?.isHidden = isMeasuring
        navigationItem.title = isMeasuring ? "측정 중" : " "
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "측정"))
    }
    
    private func setupDelegates() {
        mainView.searchBar.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate
extension MeasureViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: false)
    }
    
}
