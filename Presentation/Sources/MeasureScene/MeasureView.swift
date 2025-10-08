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

    let startButton = CustomButton(title: "측정 시작", image: AppIcon.play, foreground: .white, background: AppColor.primary)

    // MARK: - After Start Measuring
    private let measuringBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.boxBackground
        view.layer.cornerRadius = AppRadius.radius
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let timeLabel = {
        let label = UILabel.create(color: AppColor.primaryText, font: .systemFont(ofSize: 32, weight: .medium))
        label.textAlignment = .center
        return label
    }()
    
    private let timeSubLabel = UILabel.create("경과 시간", color:AppColor.subText, font: AppFont.titleM)

    private let updateInfoLabel = {
        let label = UILabel.create("데이터 업데이트는 약간의 지연이 있습니다", color: AppColor.subText, font: AppFont.description)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let distanceContainer = UIView()

    private let distanceIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.address
        imageView.tintColor = AppColor.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let distanceView = {
        let view = ItemView(subtitle: "이동 거리")
        view.setTitleFont(AppFont.titleL)
        view.setSubTitleFont(AppFont.body)
        return view
    }()

    private let stepsContainer = UIView()

    private let stepsIconView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.footprints
        imageView.tintColor = AppColor.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stepsView = {
        let view = ItemView(subtitle: "걸음 수")
        view.setTitleFont(AppFont.titleL)
        view.setSubTitleFont(AppFont.body)
        return view
    }()

    private let measuringButtonsStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = AppSpacing.regular
        stackView.distribution = .fillEqually
        stackView.isHidden = true
        return stackView
    }()
    
    private let horizontalLineView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()
    
    private let verticalLineView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()

    let cancelMeasuringButton = CustomButton(title: "측정 취소", image: AppIcon.x, foreground: AppColor.dangerText, background: AppColor.danger)

    let stopButton = CustomButton(title: "측정 종료", image: AppIcon.stop, foreground: .white, background: AppColor.primary)

    // MARK: - Permission Required View
    private let permissionRequiredView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = AppRadius.radius
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let permissionIconView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.exclamation
        imageView.tintColor = AppColor.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let permissionTitleLabel = UILabel.create("'건강' 권한 필요", color: AppColor.primaryText, font: AppFont.titleL)

    private let permissionMessageLabel = {
        let label = UILabel.create("측정 기능을 사용하려면\n 설정에서 데이터 접근을 허용해주세요\n(설정 - 앱 - 건강 - 데이터 접근 및 기기)", color: AppColor.subText, font: AppFont.body)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    let openSettingsButton = CustomButton(title: "설정에서 권한 허용", image: AppIcon.gear, foreground: .white, background: AppColor.primary)

    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        updateSearchBarBorder(isFirstResponder: false)
        mountainInfoView.isHidden = true
        placeholderLabel.isHidden = false
        cancelButton.isHidden = true
    }
    
    override func setupHierarchy() {
        [selectLabel, searchBar, mountainBoxView, stackView, searchResultsOverlay, permissionRequiredView].forEach {
            addSubview($0)
        }

        [searchResultsTableView, emptyStateLabel].forEach {
            searchResultsOverlay.addSubview($0)
        }

        [startButton, measuringBoxView, measuringButtonsStackView].forEach {
            stackView.addArrangedSubview($0)
        }

        [mountainInfoView, placeholderLabel, cancelButton].forEach {
            mountainBoxView.addSubview($0)
        }

        [permissionIconView, permissionTitleLabel, permissionMessageLabel, openSettingsButton].forEach {
            permissionRequiredView.addSubview($0)
        }
        
        [timeLabel, timeSubLabel, updateInfoLabel, distanceContainer, stepsContainer, horizontalLineView, verticalLineView].forEach {
            measuringBoxView.addSubview($0)
        }

        [distanceIconView, distanceView].forEach {
            distanceContainer.addSubview($0)
        }

        [stepsIconView, stepsView].forEach {
            stepsContainer.addSubview($0)
        }

        [cancelMeasuringButton, stopButton].forEach {
            measuringButtonsStackView.addArrangedSubview($0)
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
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(mountainBoxView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }

        mountainBoxView.snp.makeConstraints { make in
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

        startButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(AppSpacing.regular)
            make.centerX.equalToSuperview()
        }
        
        timeSubLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }

        updateInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(timeSubLabel.snp.bottom).offset(AppSpacing.small)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(horizontalLineView.snp.centerY).offset(-AppSpacing.compact)
        }

        distanceContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpacing.compact)
            make.trailing.equalTo(snp.centerX).offset(-AppSpacing.compact / 2)
            make.verticalEdges.equalTo(verticalLineView)
        }

        distanceIconView.snp.makeConstraints { make in
            make.trailing.equalTo(distanceView.snp.leading).offset(-AppSpacing.small)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }

        distanceView.snp.makeConstraints { make in
            make.center.verticalEdges.equalToSuperview()
        }

        stepsContainer.snp.makeConstraints { make in
            make.leading.equalTo(snp.centerX).offset(AppSpacing.compact / 2)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.verticalEdges.equalTo(verticalLineView)
        }

        stepsIconView.snp.makeConstraints { make in
            make.trailing.equalTo(stepsView.snp.leading).offset(-AppSpacing.small)
            make.centerY.equalTo(stepsView)
            make.size.equalTo(20)
        }

        stepsView.snp.makeConstraints { make in
            make.center.verticalEdges.equalToSuperview()
        }
        
        horizontalLineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalToSuperview()
        }
        
        verticalLineView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.centerX.equalToSuperview()
            make.top.equalTo(horizontalLineView.snp.centerY).offset(AppSpacing.compact)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }

        cancelMeasuringButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        stopButton.snp.makeConstraints { make in
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

        permissionRequiredView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(24)
        }

        permissionIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }

        permissionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(permissionIconView.snp.bottom).offset(AppSpacing.regular)
            make.centerX.equalToSuperview()
        }

        permissionMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(permissionTitleLabel.snp.bottom).offset(AppSpacing.small)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }

        openSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(permissionMessageLabel.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().offset(-40)
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
        mountainInfoView.isHidden = false
        placeholderLabel.isHidden = true
        cancelButton.isHidden = false
    }

    func updateSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }

    func updateStartButtonIsEnabled(_ isEnabled: Bool) {
        startButton.isEnabled = isEnabled
    }

    func clearMountainSelection() {
        mountainInfoView.isHidden = true
        placeholderLabel.isHidden = false
        cancelButton.isHidden = true
    }

    func updateMeasuringState(isMeasuring: Bool) {
        if isMeasuring {
            startButton.isHidden = true
            measuringBoxView.isHidden = false
            measuringButtonsStackView.isHidden = false
            cancelButton.isEnabled = false
            mountainBoxView.alpha = 0.5
            selectLabel.isEnabled = false
            searchBar.searchTextField.leftView?.tintColor = .systemGray.withAlphaComponent(0.5)
            if #available(iOS 16.4, *) {
                searchBar.isEnabled = false
            } else {
                searchBar.isUserInteractionEnabled = false
                searchBar.alpha = 0.5
            }
            searchBar.searchTextField.clearButtonMode = .never
        } else {
            startButton.isHidden = false
            measuringBoxView.isHidden = true
            measuringButtonsStackView.isHidden = true
            cancelButton.isEnabled = true
            mountainBoxView.alpha = 1.0
            selectLabel.isEnabled = true
            searchBar.searchTextField.leftView?.tintColor = AppColor.mossGreen
            if #available(iOS 16.4, *) {
                searchBar.isEnabled = true
            } else {
                searchBar.isUserInteractionEnabled = true
                searchBar.alpha = 1.0
            }
            searchBar.searchTextField.clearButtonMode = .always
        }
    }

    func updateMeasuringData(time: String, distance: String, steps: String) {
        timeLabel.text = time
        distanceView.setTitle(title: distance)
        stepsView.setTitle(title: steps)
    }

    func clearSearchBar() {
        searchBar.text = ""
    }

    func updatePermissionRequiredViewIsHidden(_ authorized: Bool) {
        if authorized {
            permissionRequiredView.isHidden = true
            selectLabel.isHidden = false
            searchBar.isHidden = false
            mountainBoxView.isHidden = false
            stackView.isHidden = false
        } else {
            permissionRequiredView.isHidden = false
            selectLabel.isHidden = true
            searchBar.isHidden = true
            mountainBoxView.isHidden = true
            stackView.isHidden = true
        }
    }
    
}
