//
//  AddClimbRecordView.swift
//  Presentation
//
//  Created by 김영훈 on 10/2/25.
//

import UIKit
import SnapKit

final class AddClimbRecordView: BaseView {

    // 산 선택 레이블
    private let selectLabel = UILabel.create("산 선택", color: AppColor.primaryText, font: AppFont.titleM)

    // 검색 바
    let searchBar = CustomSearchBar()

    // 검색 결과 오버레이
    let searchResultsOverlay = {
        let view = UIView()
        view.backgroundColor = AppColor.background
        view.layer.cornerRadius = AppRadius.medium
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.clipsToBounds = false
        view.isHidden = true
        return view
    }()

    // 검색 결과 테이블 뷰
    let searchResultsTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = AppRadius.medium
        tableView.clipsToBounds = true
        tableView.isOpaque = true
        tableView.register(cellClass: SearchMountainTableViewCell.self)
        return tableView
    }()

    // 검색 결과 없음 표기 레이블
    private let emptyStateLabel = {
        let label = UILabel.create("검색 결과가 없습니다", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        label.isHidden = true
        label.backgroundColor = AppColor.background
        return label
    }()

    // 로딩 인디케이터
    let loadingIndicator = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = AppColor.primaryText
        return indicator
    }()

    // 선택된 산 박스
    private let mountainBoxView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = AppRadius.medium
        view.clipsToBounds = true
        return view
    }()

    // 선택된 산 정보 (이름, 주소)
    private let mountainInfoView = {
        let view = ItemView()
        view.setAlignment(.left)
        return view
    }()

    // 산 선택 Placeholder
    private let placeholderLabel = {
        let label = UILabel.create("검색으로 산을 선택해주세요", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        return label
    }()

    // 선택된 산 취소 버튼
    let cancelButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = AppColor.subText
        return button
    }()

    // 날짜 박스
    private let dateBoxView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = AppRadius.medium
        view.clipsToBounds = true
        return view
    }()

    // 날짜 레이블
    private let dateLabel = UILabel.create("날짜", color: AppColor.primaryText, font: AppFont.titleM)

    // 날짜 피커
    let datePicker = {
        let picker = UIDatePicker()
        picker.tintColor = AppColor.primary
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.maximumDate = Date()
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()

    // 다음 버튼
    let nextButton = CustomButton(title: "다음", image: nil, foreground: .white, background: AppColor.primary)

    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        setSearchBarBorder(isFirstResponder: false)
        mountainInfoView.isHidden = true
        placeholderLabel.isHidden = false
        cancelButton.isHidden = true
    }

    override func setupHierarchy() {
        [selectLabel, searchBar, mountainBoxView, dateLabel, dateBoxView, nextButton, searchResultsOverlay].forEach {
            addSubview($0)
        }

        [mountainInfoView, placeholderLabel, cancelButton].forEach {
            mountainBoxView.addSubview($0)
        }

        dateBoxView.addSubview(datePicker)

        [searchResultsTableView, emptyStateLabel, loadingIndicator].forEach {
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

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(mountainBoxView.snp.bottom).offset(AppSpacing.regular)
            make.leading.equalTo(safeAreaLayoutGuide).offset(AppSpacing.regular)
        }

        dateBoxView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
            make.bottom.lessThanOrEqualTo(nextButton.snp.top).offset(-AppSpacing.regular)
        }

        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(AppSpacing.compact)
        }

        nextButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }
    }
}

// MARK: - Binding Methods
extension AddClimbRecordView {

    // 검색 바 입력 시 Border 설정
    func setSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }

    // 검색 결과 창 Visiblity 설정
    func updateSearchResultsOverlayIsHidden(_ isHidden: Bool) {
        searchResultsOverlay.isHidden = isHidden
    }

    // 검색 결과 창 너비 동적 조절
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

    // 산 선택 시 박스 내용 설정
    func updateMountainLabelTexts(name: String, address: String) {
        mountainInfoView.setTitle(title: name)
        mountainInfoView.setSubtitle(subtitle: address)
        mountainInfoView.isHidden = false
        placeholderLabel.isHidden = true
        cancelButton.isHidden = false
    }

    // 산 선택 박스 초기화
    func clearMountainSelection() {
        mountainInfoView.isHidden = true
        placeholderLabel.isHidden = false
        cancelButton.isHidden = true
    }

    // 검색 바 초기화
    func clearSearchBar() {
        searchBar.text = ""
    }

    // 다음 버튼 활성화
    func setNextButtonEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        nextButton.alpha = isEnabled ? 1.0 : 0.5
    }

    // 로딩 인디케이터
    func setLoadingState(_ isLoading: Bool) {
        if isLoading {
            searchResultsOverlay.isHidden = false
            emptyStateLabel.isHidden = true
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}
