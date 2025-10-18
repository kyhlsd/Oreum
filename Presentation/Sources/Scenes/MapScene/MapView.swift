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
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    // 내 주위 명산 레이블
    private let titleLabel = UILabel.create("내 주위 명산", color: AppColor.primaryText, font: AppFont.titleM)
    // 산림청 100대 명산 레이블
    private let descriptionLabel = UILabel.create("산림청에서 지정한 100대 명산", color: AppColor.subText, font: AppFont.description)

    // 검색 바
    let searchBar = {
        let searchBar = CustomSearchBar()
        searchBar.placeholder = "산 이름 혹은 지역 명을 입력하세요"
        return searchBar
    }()
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
    }

    override func setupHierarchy() {
        [mapView, currentLocationButton, titleLabel, descriptionLabel, searchBar, collectionView, emptyLabel].forEach {
            addSubview($0)
        }
    }

    override func setupLayout() {
        mapView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(300)
        }

        currentLocationButton.snp.makeConstraints { make in
            make.trailing.equalTo(mapView).inset(AppSpacing.regular)
            make.bottom.equalTo(mapView).inset(AppSpacing.regular)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(AppSpacing.regular)
            make.leading.equalToSuperview().inset(AppSpacing.regular)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.regular)
            make.lastBaseline.equalTo(titleLabel)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpacing.compact)
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }

        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(collectionView)
        }
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
    func setSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }
}
