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

    let searchResultsOverlay = {
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

    let searchResultsTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = AppRadius.radius
        tableView.clipsToBounds = true
        tableView.register(cellClass: SearchMountainTableViewCell.self)
        return tableView
    }()

    private let emptyStateLabel = {
        let label = UILabel.create("검색 결과가 없습니다", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        label.isHidden = true
        return label
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

    let cancelButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = AppColor.subText
        return button
    }()

    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        updateSearchBarBorder(isFirstResponder: false)
    }
    
    override func setupHierarchy() {
        [selectLabel, searchBar, stackView].forEach {
            addSubview($0)
        }

        [mountainBoxView, startButton].forEach {
            stackView.addArrangedSubview($0)
        }
        mountainBoxView.addSubview(mountainInfoView)
        mountainBoxView.addSubview(cancelButton)

        addSubview(searchResultsOverlay)
        searchResultsOverlay.addSubview(searchResultsTableView)
        searchResultsOverlay.addSubview(emptyStateLabel)
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
            make.verticalEdges.leading.equalToSuperview().inset(AppSpacing.compact)
            make.trailing.equalTo(cancelButton.snp.leading).offset(-AppSpacing.small)
        }

        cancelButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        startButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        searchResultsOverlay.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.small)
            make.horizontalEdges.equalTo(searchBar)
            make.height.equalTo(300).priority(.low)
        }

        searchResultsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
    }
}

// MARK: - Binding Methods
extension MeasureView {

    func updateSearchResultsOverlayIsHidden(_ isHidden: Bool) {
        searchResultsOverlay.isHidden = isHidden
    }

    func updateSearchResults(count: Int) {
        let isEmpty = count == 0
        emptyStateLabel.isHidden = !isEmpty
        searchResultsTableView.isHidden = isEmpty

        let height: CGFloat
        if isEmpty {
            height = 60
        } else {
            let cellHeight = 60.0
            height = min(CGFloat(count) * cellHeight, 300)
        }

        searchResultsOverlay.snp.remakeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.small)
            make.horizontalEdges.equalTo(searchBar)
            make.height.equalTo(height)
        }
    }

    func updateMountainLabelTexts(name: String, address: String) {
        mountainInfoView.setTitle(title: name)
        mountainInfoView.setSubtitle(subtitle: address)
    }

    func updateSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }

    func updateSelectViewsIsEnabled(_ isEnabled: Bool) {
        selectLabel.isEnabled = isEnabled

        searchBar.searchTextField.leftView?.tintColor = isEnabled ? AppColor.mossGreen : .systemGray.withAlphaComponent(0.5)
        if #available(iOS 16.4, *) {
            searchBar.isEnabled = isEnabled
        } else {
            searchBar.isUserInteractionEnabled = isEnabled
            searchBar.alpha = isEnabled ? 1.0 : 0.5
        }
    }

    func updateStartButtonIsEnabled(_ isEnabled: Bool) {
        startButton.isEnabled = isEnabled
    }

    func updateMountainBoxIsHidden(_ isHidden: Bool) {
        mountainBoxView.isHidden = isHidden
    }

}
