//
//  MountainClusterManager.swift
//  Presentation
//
//  Created by Claude on 10/11/25.
//

import MapKit
import Domain
import CoreLocation

// MARK: - Custom Cluster Annotation
final class CustomClusterAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var mountains: [MountainDistance]

    var count: Int {
        return mountains.count
    }

    init(coordinate: CLLocationCoordinate2D, mountains: [MountainDistance]) {
        self.coordinate = coordinate
        self.mountains = mountains
        super.init()
    }
}

// MARK: - Mountain Cluster Manager
final class MountainClusterManager {

    /// Grid-based clustering 알고리즘
    func cluster(mountains: [MountainDistance], mapView: MKMapView) -> [MKAnnotation] {
        guard !mountains.isEmpty else { return [] }

        // altitude에 따라 그리드 셀 크기 조정
        let altitude = mapView.camera.altitude
        // altitude가 낮을수록(확대) 작은 셀, 높을수록(축소) 큰 셀
        let cellSize: CGFloat = max(30.0, min(altitude / 2000.0, 80.0))

        // 그리드에 산 배치
        var grid: [String: [MountainDistance]] = [:]

        for mountain in mountains {
            let coordinate = CLLocationCoordinate2D(
                latitude: mountain.mountainLocation.latitude,
                longitude: mountain.mountainLocation.longitude
            )
            let point = mapView.convert(coordinate, toPointTo: mapView)

            // 그리드 인덱스 계산
            let gridX = Int(point.x / cellSize)
            let gridY = Int(point.y / cellSize)
            let gridKey = "\(gridX),\(gridY)"

            if grid[gridKey] == nil {
                grid[gridKey] = []
            }
            grid[gridKey]?.append(mountain)
        }

        // 각 그리드 셀에서 annotation 생성
        var annotations: [MKAnnotation] = []

        for (_, mountainsInCell) in grid {
            if mountainsInCell.count > 1 {
                // 클러스터 생성
                let centerCoordinate = calculateCenterCoordinate(for: mountainsInCell)
                let cluster = CustomClusterAnnotation(coordinate: centerCoordinate, mountains: mountainsInCell)
                annotations.append(cluster)
            } else if let mountain = mountainsInCell.first {
                // 개별 annotation 생성
                let annotation = MountainAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: mountain.mountainLocation.latitude,
                    longitude: mountain.mountainLocation.longitude
                )
                annotation.mountainDistance = mountain
                annotations.append(annotation)
            }
        }

        return annotations
    }

    /// 여러 산의 중심 좌표 계산
    private func calculateCenterCoordinate(for mountains: [MountainDistance]) -> CLLocationCoordinate2D {
        var totalLatitude: Double = 0
        var totalLongitude: Double = 0

        for mountain in mountains {
            totalLatitude += mountain.mountainLocation.latitude
            totalLongitude += mountain.mountainLocation.longitude
        }

        let count = Double(mountains.count)
        return CLLocationCoordinate2D(
            latitude: totalLatitude / count,
            longitude: totalLongitude / count
        )
    }
}

// MARK: - CLLocationCoordinate2D Extension
extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}
