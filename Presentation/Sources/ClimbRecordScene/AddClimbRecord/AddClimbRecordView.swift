//
//  AddClimbRecordView.swift
//  Presentation
//
//  Created by 김영훈 on 10/2/25.
//

import UIKit
import SnapKit

final class AddClimbRecordView: BaseView {

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
        tableView.isOpaque = true
        tableView.register(cellClass: SearchMountainTableViewCell.self)
        return tableView
    }()

    private let emptyStateLabel = {
        let label = UILabel.create("검색 결과가 없습니다", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        label.isHidden = true
        label.backgroundColor = AppColor.background
        return label
    }()

    private let mountainBoxView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = AppRadius.radius
        view.clipsToBounds = true
        return view
    }()

    private let mountainInfoView = {
        let view = ItemView()
        view.setAlignment(.left)
        return view
    }()

    private let placeholderLabel = {
        let label = UILabel.create("검색으로 산을 선택해주세요", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        return label
    }()

    let cancelButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = AppColor.subText
        return button
    }()

    private let dateBoxView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = AppRadius.radius
        view.clipsToBounds = true
        return view
    }()

    private let dateLabel = UILabel.create("날짜", color: AppColor.primaryText, font: AppFont.titleM)

    let datePicker = {
        let picker = UIDatePicker()
        picker.tintColor = AppColor.primary
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.maximumDate = Date()
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()

    let saveButton = CustomButton(title: "저장", image: nil, foreground: .white, background: AppColor.primary)

    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        setSearchBarBorder(isFirstResponder: false)
        mountainInfoView.isHidden = true
        placeholderLabel.isHidden = false
        cancelButton.isHidden = true
    }

    override func setupHierarchy() {
        [selectLabel, searchBar, mountainBoxView, dateLabel, dateBoxView, saveButton, searchResultsOverlay].forEach {
            addSubview($0)
        }

        [mountainInfoView, placeholderLabel, cancelButton].forEach {
            mountainBoxView.addSubview($0)
        }

        dateBoxView.addSubview(datePicker)

        [searchResultsTableView, emptyStateLabel].forEach {
            searchResultsOverlay.addSubview($0)
        }
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

        mountainBoxView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
            make.height.equalTo(60)
        }

        mountainInfoView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview().inset(AppSpacing.compact)
            make.trailing.equalTo(cancelButton.snp.leading).offset(-AppSpacing.small)
        }

        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
        }

        cancelButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
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

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(mountainBoxView.snp.bottom).offset(AppSpacing.regular)
            make.leading.equalTo(safeAreaLayoutGuide).offset(AppSpacing.regular)
        }

        dateBoxView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }

        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(AppSpacing.compact)
        }

        saveButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.equalTo(dateBoxView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }
    }
}

// MARK: - Binding Methods
extension AddClimbRecordView {

    func setSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }

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
        mountainInfoView.isHidden = false
        placeholderLabel.isHidden = true
        cancelButton.isHidden = false
    }

    func clearMountainSelection() {
        mountainInfoView.isHidden = true
        placeholderLabel.isHidden = false
        cancelButton.isHidden = true
    }

    func clearSearchBar() {
        searchBar.text = ""
    }

    func setSaveButtonEnabled(_ isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
        saveButton.alpha = isEnabled ? 1.0 : 0.5
    }
}
