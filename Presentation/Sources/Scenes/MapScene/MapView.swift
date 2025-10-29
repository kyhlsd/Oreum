//
//  MapView.swift
//  Presentation
//
//  Created by 김영훈 on 10/4/25.
//

import UIKit
import MapKit
import SnapKit

final class MapView: BaseView {

    // 검색 바
    let searchBar = {
        let searchBar = CustomSearchBar()
        searchBar.backgroundColor = .white
        searchBar.placeholder = "산 이름 혹은 지역 명을 입력하세요"
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOpacity = 0.25
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        searchBar.layer.shadowRadius = 12
        return searchBar
    }()
    
    // 지도
    let mapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()
    // 현재 위치로 버튼
    let currentLocationButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = AppColor.primary
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4
        return button
    }()

    // 드래그 가능한 컨테이너
    private let containerView = {
        let view = UIView()
        view.backgroundColor = AppColor.background
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.layer.shadowRadius = 12
        return view
    }()

    // 드래그 핸들
    private let handleView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        view.layer.cornerRadius = 2.5
        return view
    }()

    // 내 주위 명산 레이블
    private let titleLabel = UILabel.create("내 주위 명산", color: AppColor.primaryText, font: AppFont.titleM)
    // 산림청 100대 명산 레이블
    private let descriptionLabel = UILabel.create("산림청에서 지정한 100대 명산", color: AppColor.subText, font: AppFont.description)
    
    // 검색 결과 없을 때 표기 레이블
    let emptyLabel = {
        let label = UILabel.create("검색 결과가 없습니다", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    // 산 목록 컬렉션 뷰
    lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()

    // 컨테이너 top constraint
    private var containerTopConstraint: Constraint?

    // 패널 상태
    enum PanelState {
        case expanded
        case half
        case collapsed

        func offset(safeAreaTop: CGFloat, safeAreaBottom: CGFloat, screenHeight: CGFloat) -> CGFloat {
            switch self {
            case .expanded:
                return safeAreaTop + 60
            case .half:
                return screenHeight * 0.5
            case .collapsed:
                return screenHeight - safeAreaBottom - 100
            }
        }
    }

    private var currentPanelState: PanelState = .half
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = AppSpacing.small
        section.contentInsets = NSDirectionalEdgeInsets(top: AppSpacing.regular, leading: AppSpacing.regular, bottom: AppSpacing.regular, trailing: AppSpacing.regular)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        searchBar.setBorder(false)
        setupGestures()
    }

    override func setupHierarchy() {
        [mapView, searchBar, currentLocationButton, containerView].forEach {
            addSubview($0)
        }

        [handleView, titleLabel, descriptionLabel, collectionView, emptyLabel].forEach {
            containerView.addSubview($0)
        }
    }

    override func setupLayout() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppSpacing.regular)
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }

        currentLocationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.regular)
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.compact)
            make.width.height.equalTo(40)
        }

        containerView.snp.makeConstraints { make in
            containerTopConstraint = make.top.equalTo(safeAreaLayoutGuide).offset(DeviceSize.height * 0.5).constraint
            make.horizontalEdges.bottom.equalToSuperview()
        }

        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(AppSpacing.regular)
            make.leading.equalToSuperview().inset(AppSpacing.regular)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.regular)
            make.lastBaseline.equalTo(titleLabel)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.bottom.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(collectionView)
        }
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        containerView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)

        switch gesture.state {
        case .changed:
            let newOffset = (containerTopConstraint?.layoutConstraints.first?.constant ?? 0) + translation.y
            let minOffset = safeAreaInsets.top + 60
            let maxOffset = frame.height - safeAreaInsets.bottom - 100

            containerTopConstraint?.update(offset: max(minOffset, min(newOffset, maxOffset)))
            gesture.setTranslation(.zero, in: self)

        case .ended:
            let currentOffset = containerTopConstraint?.layoutConstraints.first?.constant ?? 0
            let screenHeight = frame.height

            let targetState: PanelState
            if velocity.y > 500 {
                // 빠르게 아래로
                targetState = currentPanelState == .expanded ? .half : .collapsed
            } else if velocity.y < -500 {
                // 빠르게 위로
                targetState = currentPanelState == .collapsed ? .half : .expanded
            } else {
                // 위치 기반
                let expandedThreshold = screenHeight * 0.3
                let collapsedThreshold = screenHeight - safeAreaInsets.bottom - 250

                if currentOffset < expandedThreshold {
                    targetState = .expanded
                } else if currentOffset < collapsedThreshold {
                    targetState = .half
                } else {
                    targetState = .collapsed
                }
            }

            animateToState(targetState)

        default:
            break
        }
    }

    private func animateToState(_ state: PanelState) {
        currentPanelState = state
        let offset = state.offset(safeAreaTop: safeAreaInsets.top, safeAreaBottom: safeAreaInsets.bottom, screenHeight: frame.height)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.containerTopConstraint?.update(offset: offset)
            self.layoutIfNeeded()
        }
    }

}

// MARK: - UIGestureRecognizerDelegate
extension MapView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // CollectionView 스크롤과 패널 드래그를 동시에 허용
        return true
    }
}

// MARK: - Binding Methods
extension MapView {
    // 지도 이동
    func updateMapRegion(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 40000, longitudinalMeters: 40000)
        mapView.setRegion(region, animated: true)
    }

    // 지도 바운더리 설정
    func setupMapBoundary(region: MKCoordinateRegion, zoomRange: MKMapView.CameraZoomRange) {
        let cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
        mapView.setCameraBoundary(cameraBoundary, animated: false)
        mapView.setCameraZoomRange(zoomRange, animated: false)
    }

    // 검색 결과 유무에 따른 처리
    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
        collectionView.isHidden = show
    }

    // 검색 여부에 따라 테두리 설정
    func setWithFirstResponder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)

        if isFirstResponder {
            animateToState(.expanded)
        }
    }
}
