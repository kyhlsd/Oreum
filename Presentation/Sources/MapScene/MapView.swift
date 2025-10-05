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

    private let titleLabel = UILabel.create("내 주변 명산", color: AppColor.primaryText, font: AppFont.titleM)

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(80))
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
        [mapView, titleLabel, collectionView].forEach {
            addSubview($0)
        }
    }

    override func setupLayout() {
        mapView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(300)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.bottom).offset(AppSpacing.regular)
            make.leading.equalToSuperview().inset(AppSpacing.regular)
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
