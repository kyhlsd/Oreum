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

    let mapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()

    lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = AppColor.background
        return collectionView
    }()

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

    private let titleLabel = UILabel.create("내 주변 명산", color: AppColor.primaryText, font: AppFont.titleM)

    private let descriptionLabel = UILabel.create("산림청에서 지정한 100대 명산", color: AppColor.subText, font: AppFont.description)

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
    }

    override func setupHierarchy() {
        [mapView, currentLocationButton, titleLabel, descriptionLabel, collectionView].forEach {
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

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

// MARK: - Binding Methods
extension MapView {
    func updateMapRegion(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(region, animated: true)
    }
}
