//
//  MapAnnotationManager.swift
//  Presentation
//
//  Created by 김영훈 on 10/11/25.
//

import MapKit
import Domain

final class MapAnnotationManager {

    private let clusterManager = MountainClusterManager()
    private var allMountainsData: [MountainDistance] = []

    // 산 데이터 업데이트
    func updateMountains(_ mountains: [MountainDistance]) {
        self.allMountainsData = mountains
    }

    // 클러스터링을 수행하고 업데이트가 필요한 annotation들을 반환
    func updateAnnotations(on mapView: MKMapView) -> (toAdd: [MKAnnotation], toRemove: [MKAnnotation]) {
        guard !allMountainsData.isEmpty else {
            let currentAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
            return ([], currentAnnotations)
        }

        // 클러스터링 수행
        let clusteredAnnotations = clusterManager.cluster(
            mountains: allMountainsData,
            mapView: mapView
        )

        // 현재 위치는 미포함
        let currentAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }

        // 클러스터링된 어노테이션 중 현재 어노테이션이 없으면 해당 어노테이션 제거
        let annotationsToRemove = currentAnnotations.filter { currentAnnotation in
            !clusteredAnnotations.contains { newAnnotation in
                isSameAnnotation(currentAnnotation, newAnnotation)
            }
        }

        // 현재 어노테이션 중 클러스터링된 어노테이션인 없으면 해당 어노테이션 추가
        let annotationsToAdd = clusteredAnnotations.filter { newAnnotation in
            !currentAnnotations.contains { currentAnnotation in
                isSameAnnotation(currentAnnotation, newAnnotation)
            }
        }

        return (annotationsToAdd, annotationsToRemove)
    }

    // 두 annotation이 동일한지 비교
    private func isSameAnnotation(_ annotation1: MKAnnotation, _ annotation2: MKAnnotation) -> Bool {
        if let cluster1 = annotation1 as? CustomClusterAnnotation,
           let cluster2 = annotation2 as? CustomClusterAnnotation {
            return cluster1.count == cluster2.count &&
                   abs(cluster1.coordinate.latitude - cluster2.coordinate.latitude) < 0.0001 &&
                   abs(cluster1.coordinate.longitude - cluster2.coordinate.longitude) < 0.0001
        }

        if let mountain1 = annotation1 as? MountainAnnotation,
           let mountain2 = annotation2 as? MountainAnnotation {
            return mountain1.mountainDistance?.mountainLocation.name == mountain2.mountainDistance?.mountainLocation.name
        }

        return false
    }
}

// MARK: - MountainAnnotation
final class MountainAnnotation: MKPointAnnotation {
    var mountainDistance: MountainDistance?
}
