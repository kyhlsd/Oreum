//
//  MeasureView.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Domain
import SnapKit

final class MeasureView: BaseView {

    private let selectLabel = UILabel.create("산 선택", color: AppColor.primaryText, font: AppFont.titleM)

    let searchBar = CustomSearchBar()

    let searchResultsOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.background
        view.layer.cornerRadius = AppRadius.radius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.clipsToBounds = false
        view.isHidden = true
        return view
    }()

    let searchResultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = AppRadius.radius
        tableView.clipsToBounds = true
        tableView.register(cellClass: SearchMountainTableViewCell.self)
        return tableView
    }()

    private let stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = AppSpacing.regular
        return stackView
    }()

    private let mountainBoxView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = AppRadius.radius
        view.clipsToBounds = true
        return view
    }()

    private let startButton = CustomButton(title: "측정 시작", image: AppIcon.play, foreground: .white, background: AppColor.primary)

    private let mountainInfoView = {
        let view = ItemView()
        view.setAlignment(.left)
        return view
    }()
    
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        setSearchBarBorder(isFirstResponder: false)
    }
    
    override func setupHierarchy() {
        [selectLabel, searchBar, stackView].forEach {
            addSubview($0)
        }

        [mountainBoxView, startButton].forEach {
            stackView.addArrangedSubview($0)
        }
        mountainBoxView.addSubview(mountainInfoView)

        addSubview(searchResultsOverlay)
        searchResultsOverlay.addSubview(searchResultsTableView)
    }
    
    override func setupLayout() {
        selectLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).offset(AppSpacing.regular)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(selectLabel.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
            make.height.equalTo(40)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }

        mountainInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(AppSpacing.compact)
        }

        startButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        searchResultsOverlay.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(searchBar)
            make.height.equalTo(300)
        }

        searchResultsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Binding Methods
extension MeasureView {

    func setSearchResultsOverlayIsHidden(_ isHidden: Bool) {
        searchResultsOverlay.isHidden = isHidden
    }

    func setMountainLabelTexts(name: String, address: String) {
        mountainInfoView.setTitle(title: name)
        mountainInfoView.setSubtitle(subtitle: address)
    }

    func setSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }

    func setSelectViewsEnabled(_ isEnabled: Bool) {
        selectLabel.isEnabled = isEnabled

        searchBar.searchTextField.leftView?.tintColor = isEnabled ? AppColor.mossGreen : .systemGray.withAlphaComponent(0.5)
        if #available(iOS 16.4, *) {
            searchBar.isEnabled = isEnabled
        } else {
            searchBar.isUserInteractionEnabled = isEnabled
            searchBar.alpha = isEnabled ? 1.0 : 0.5
        }
    }

    func setStartButtonEnabled(_ isEnabled: Bool) {
        startButton.isEnabled = isEnabled
    }

    func setMountainBoxIsHidden(_ isHidden: Bool) {
        mountainBoxView.isHidden = isHidden
    }

}
