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

    // 산 선택 레이블
    private let selectLabel = UILabel.create("산 선택", color: AppColor.primaryText, font: AppFont.titleM)
    // 검색 바
    let searchBar = CustomSearchBar()
    // 검색 결과 오버레이
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
    // 검색 결과 테이블 뷰
    let searchResultsTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = AppRadius.radius
        tableView.clipsToBounds = true
        tableView.register(cellClass: SearchMountainTableViewCell.self)
        return tableView
    }()
    // 검색 결과 없음 표기 레이블
    private let emptyStateLabel = {
        let label = UILabel.create("검색 결과가 없습니다", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        label.isHidden = true
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
        view.layer.cornerRadius = AppRadius.radius
        view.clipsToBounds = true
        return view
    }()
    // 산 정보
    private let mountainInfoView = {
        let view = ItemView()
        view.setAlignment(.left)
        return view
    }()
    // 산 미선택 시 표기 레이블
    private let placeholderLabel = {
        let label = UILabel.create("검색으로 산을 선택해주세요", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        return label
    }()
    // 산 취소 버튼
    let cancelButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = AppColor.subText
        return button
    }()
    
    // 변경되는 뷰 담을 스택뷰
    private let stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = AppSpacing.regular
        return stackView
    }()

    // 시작 버튼
    let startButton = CustomButton(title: "측정 시작", image: AppIcon.play, foreground: .white, background: AppColor.primary)

    // MARK: - After Start Measuring
    
    // 측정 박스
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
    // 시간 레이블
    private let timeLabel = {
        let label = UILabel.create(color: AppColor.primaryText, font: .systemFont(ofSize: 32, weight: .medium))
        label.textAlignment = .center
        return label
    }()
    // 경과 시간 텍스트 레이블
    private let timeSubLabel = UILabel.create("경과 시간", color:AppColor.subText, font: AppFont.titleM)

    // 업데이트 지연 안내 레이블
    private let updateInfoLabel = {
        let label = UILabel.create("데이터 업데이트는 약간의 지연이 있습니다", color: AppColor.subText, font: AppFont.description)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // 거리 컨테이너
    private let distanceContainer = UIView()
    // 거리 이미지
    private let distanceIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.address
        imageView.tintColor = AppColor.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // 거리 표기
    private let distanceView = {
        let view = ItemView(subtitle: "이동 거리")
        view.setTitleFont(AppFont.titleL)
        view.setSubTitleFont(AppFont.body)
        return view
    }()

    // 걸음 수 컨테이너
    private let stepsContainer = UIView()
    // 걸음 수 이미지
    private let stepsIconView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.footprints
        imageView.tintColor = AppColor.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // 걸음 수 표기
    private let stepsView = {
        let view = ItemView(subtitle: "걸음 수")
        view.setTitleFont(AppFont.titleL)
        view.setSubTitleFont(AppFont.body)
        return view
    }()
    
    // 가로 구분선
    private let horizontalLineView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()
    // 세로 구분선
    private let verticalLineView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()

    // 측정 취소/종료 스택뷰
    private let measuringButtonsStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = AppSpacing.regular
        stackView.distribution = .fillEqually
        stackView.isHidden = true
        return stackView
    }()
    // 측정 취소 버튼
    let cancelMeasuringButton = CustomButton(title: "측정 취소", image: AppIcon.x, foreground: AppColor.dangerText, background: AppColor.danger)
    // 측정 종료 버튼
    let stopButton = CustomButton(title: "측정 종료", image: AppIcon.stop, foreground: .white, background: AppColor.primary)

    // 측정 가능 안내 레이블
    private let backgroundMeasurementInfoLabel = {
        let label = UILabel.create("앱을 종료해도 측정이 가능합니다", color: AppColor.subText, font: AppFont.description)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - Permission Required View
    
    // HealthKit 권한 요구 뷰
    private let permissionRequiredView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.layer.cornerRadius = AppRadius.radius
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    // 권한 요구 이미지
    private let permissionIconView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.exclamation
        imageView.tintColor = AppColor.primary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // 권한 요구 타이틀 레이블
    private let permissionTitleLabel = UILabel.create("'건강' 권한 필요", color: AppColor.primaryText, font: AppFont.titleL)
    // 권한 요구 메세지 레이블
    private let permissionMessageLabel = {
        let label = UILabel.create("측정 기능을 사용하려면\n 설정에서 데이터 접근을 허용해주세요\n(설정 - 앱 - 건강 - 데이터 접근 및 기기)", color: AppColor.subText, font: AppFont.body)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    // 설정 이동 버튼
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

        [searchResultsTableView, emptyStateLabel, loadingIndicator].forEach {
            searchResultsOverlay.addSubview($0)
        }

        [startButton, measuringBoxView, backgroundMeasurementInfoLabel, measuringButtonsStackView].forEach {
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

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
    
    // 검색 결과 오버레이 Visibility
    func updateSearchResultsOverlayIsHidden(_ isHidden: Bool) {
        searchResultsOverlay.isHidden = isHidden
    }
    
    // 검색 결과 높이 업데이트
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
    
    // 산 선택 반영
    func updateMountainLabelTexts(name: String, address: String) {
        mountainInfoView.setTitle(title: name)
        mountainInfoView.setSubtitle(subtitle: address)
        mountainInfoView.isHidden = false
        placeholderLabel.isHidden = true
        cancelButton.isHidden = false
    }
    
    // 검색 활성화에 따른 테두리 표기
    func updateSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }
    
    // 측정 시작 버튼 활성화
    func updateStartButtonIsEnabled(_ isEnabled: Bool) {
        startButton.isEnabled = isEnabled
    }

    // 산 선택 초기화
    func clearMountainSelection() {
        mountainInfoView.isHidden = true
        placeholderLabel.isHidden = false
        cancelButton.isHidden = true
    }

    // 측정 상태에 따른 변경
    func updateMeasuringState(isMeasuring: Bool) {
        if isMeasuring { // 측정 중일 때
            startButton.isHidden = true
            measuringBoxView.isHidden = false
            measuringButtonsStackView.isHidden = false
            backgroundMeasurementInfoLabel.isHidden = false
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
        } else { // 측정 중이 아닐 때
            startButton.isHidden = false
            measuringBoxView.isHidden = true
            measuringButtonsStackView.isHidden = true
            backgroundMeasurementInfoLabel.isHidden = true
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

    // 측정 데이터 업데이트
    func updateMeasuringData(time: String, distance: String, steps: String) {
        timeLabel.text = time
        distanceView.setTitle(title: distance)
        stepsView.setTitle(title: steps)
    }

    // 검색 바 초기화
    func clearSearchBar() {
        searchBar.text = ""
    }

    // 권한 허용 뷰 Visibility 설정
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
