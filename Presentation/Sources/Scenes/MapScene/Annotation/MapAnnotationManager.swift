//
//  MapAnnotationManager.swift
//  Presentation
//
//  Created by Claude on 10/11/25.
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

        // 기존 annotation과 새 annotation 비교
        let currentAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }

        // 제거할 annotation 찾기
        let annotationsToRemove = currentAnnotations.filter { currentAnnotation in
            !clusteredAnnotations.contains { newAnnotation in
                isSameAnnotation(currentAnnotation, newAnnotation)
            }
        }

        // 추가할 annotation 찾기
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
