//
//  MountainClusterManager.swift
//  Presentation
//
//  Created by 김영훈 on 10/11/25.
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

// MARK: - Quadtree Boundary
private struct QuadtreeBoundary {
    let minLatitude: Double
    let maxLatitude: Double
    let minLongitude: Double
    let maxLongitude: Double

    var centerLatitude: Double {
        return (minLatitude + maxLatitude) / 2.0
    }

    var centerLongitude: Double {
        return (minLongitude + maxLongitude) / 2.0
    }

    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= minLatitude &&
               coordinate.latitude <= maxLatitude &&
               coordinate.longitude >= minLongitude &&
               coordinate.longitude <= maxLongitude
    }

    func intersects(with region: MKCoordinateRegion) -> Bool {
        let regionMinLat = region.center.latitude - region.span.latitudeDelta / 2.0
        let regionMaxLat = region.center.latitude + region.span.latitudeDelta / 2.0
        let regionMinLon = region.center.longitude - region.span.longitudeDelta / 2.0
        let regionMaxLon = region.center.longitude + region.span.longitudeDelta / 2.0

        return !(maxLatitude < regionMinLat ||
                 minLatitude > regionMaxLat ||
                 maxLongitude < regionMinLon ||
                 minLongitude > regionMaxLon)
    }
}

// MARK: - Quadtree Node
private class QuadtreeNode {
    let boundary: QuadtreeBoundary
    let capacity: Int
    let depth: Int

    var mountains: [MountainDistance] = []
    var isDivided: Bool = false

    var northWest: QuadtreeNode?
    var northEast: QuadtreeNode?
    var southWest: QuadtreeNode?
    var southEast: QuadtreeNode?

    init(boundary: QuadtreeBoundary, capacity: Int = 4, depth: Int = 0) {
        self.boundary = boundary
        self.capacity = capacity
        self.depth = depth
    }

    func insert(mountain: MountainDistance) -> Bool {
        guard boundary.contains(coordinate: mountain.coordinate) else {
            return false
        }

        if mountains.count < capacity {
            mountains.append(mountain)
            return true
        }

        if !isDivided {
            subdivide()

            // 기존 산들을 자식 노드로 재분배
            let existingMountains = mountains
            mountains.removeAll()

            for existingMountain in existingMountains {
                _ = (northWest?.insert(mountain: existingMountain) == true) ||
                    (northEast?.insert(mountain: existingMountain) == true) ||
                    (southWest?.insert(mountain: existingMountain) == true) ||
                    (southEast?.insert(mountain: existingMountain) == true)
            }
        }

        // 자식 노드 중 하나에 삽입 시도
        if northWest?.insert(mountain: mountain) == true {
            return true
        }
        if northEast?.insert(mountain: mountain) == true {
            return true
        }
        if southWest?.insert(mountain: mountain) == true {
            return true
        }
        if southEast?.insert(mountain: mountain) == true {
            return true
        }

        return false
    }

    private func subdivide() {
        let centerLat = boundary.centerLatitude
        let centerLon = boundary.centerLongitude

        // NorthWest
        let nwBoundary = QuadtreeBoundary(
            minLatitude: centerLat,
            maxLatitude: boundary.maxLatitude,
            minLongitude: boundary.minLongitude,
            maxLongitude: centerLon
        )
        northWest = QuadtreeNode(boundary: nwBoundary, capacity: capacity, depth: depth + 1)

        // NorthEast
        let neBoundary = QuadtreeBoundary(
            minLatitude: centerLat,
            maxLatitude: boundary.maxLatitude,
            minLongitude: centerLon,
            maxLongitude: boundary.maxLongitude
        )
        northEast = QuadtreeNode(boundary: neBoundary, capacity: capacity, depth: depth + 1)

        // SouthWest
        let swBoundary = QuadtreeBoundary(
            minLatitude: boundary.minLatitude,
            maxLatitude: centerLat,
            minLongitude: boundary.minLongitude,
            maxLongitude: centerLon
        )
        southWest = QuadtreeNode(boundary: swBoundary, capacity: capacity, depth: depth + 1)

        // SouthEast
        let seBoundary = QuadtreeBoundary(
            minLatitude: boundary.minLatitude,
            maxLatitude: centerLat,
            minLongitude: centerLon,
            maxLongitude: boundary.maxLongitude
        )
        southEast = QuadtreeNode(boundary: seBoundary, capacity: capacity, depth: depth + 1)

        isDivided = true
    }

    func query(region: MKCoordinateRegion, maxDepth: Int) -> [[MountainDistance]] {
        var results: [[MountainDistance]] = []

        guard boundary.intersects(with: region) else {
            return results
        }

        // 분할되지 않은 리프 노드 - 현재 노드의 산들 반환
        if !isDivided {
            if !mountains.isEmpty {
                results.append(mountains)
            }
            return results
        }

        // maxDepth 도달 - 현재 노드 이하의 모든 산들을 하나의 클러스터로 수집
        if depth >= maxDepth {
            let allMountains = collectAllMountains()
            if !allMountains.isEmpty {
                results.append(allMountains)
            }
            return results
        }

        // 자식 노드 재귀 탐색
        for child in [northWest, northEast, southWest, southEast] {
            if let child = child {
                results.append(contentsOf: child.query(region: region, maxDepth: maxDepth))
            }
        }

        return results
    }

    // 현재 노드 이하의 모든 산들을 수집
    private func collectAllMountains() -> [MountainDistance] {
        var allMountains: [MountainDistance] = mountains

        if isDivided {
            for child in [northWest, northEast, southWest, southEast] {
                if let child = child {
                    allMountains.append(contentsOf: child.collectAllMountains())
                }
            }
        }

        return allMountains
    }
}

// MARK: - Mountain Cluster Manager
final class MountainClusterManager {

    // Quadtree-based clustering 알고리즘
    func cluster(mountains: [MountainDistance], mapView: MKMapView) -> [MKAnnotation] {
        guard !mountains.isEmpty else { return [] }

        // 전체 산의 경계 계산
        let boundary = calculateBoundary(for: mountains)

        // Quadtree 생성 및 산 삽입
        let quadtree = QuadtreeNode(boundary: boundary, capacity: 2, depth: 0)
        for mountain in mountains {
            _ = quadtree.insert(mountain: mountain)
        }

        // altitude에 따라 maxDepth 결정
        let altitude = mapView.camera.altitude
        let maxDepth = calculateMaxDepth(for: altitude)

        // 현재 보이는 영역에서 클러스터 쿼리
        let region = mapView.region
        let clusters = quadtree.query(region: region, maxDepth: maxDepth)

        // altitude에 따른 최대 클러스터 거리 계산 (미터)
        let maxClusterDistance = calculateMaxClusterDistance(for: altitude)

        // Annotation 생성
        var annotations: [MKAnnotation] = []

        for cluster in clusters {
            // 거리 기반으로 서브 클러스터로 분리 (1개짜리는 그대로 유지)
            let subClusters = cluster.count >= 2
                ? separateByDistance(cluster, maxDistance: maxClusterDistance)
                : [cluster]

            for subCluster in subClusters {
                if subCluster.count >= 2 {
                    // 2개 이상일 때 클러스터 annotation 생성
                    let centerCoordinate = calculateCenterCoordinate(for: subCluster)
                    let clusterAnnotation = CustomClusterAnnotation(
                        coordinate: centerCoordinate,
                        mountains: subCluster
                    )
                    annotations.append(clusterAnnotation)
                } else if let mountain = subCluster.first {
                    // 1개는 개별 annotation으로 생성
                    annotations.append(createIndividualAnnotation(for: mountain))
                }
            }
        }

        return annotations
    }

    // 전체 산의 경계 계산
    private func calculateBoundary(for mountains: [MountainDistance]) -> QuadtreeBoundary {
        let latitudes = mountains.map { $0.mountainLocation.latitude }
        let longitudes = mountains.map { $0.mountainLocation.longitude }

        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0

        // 약간의 패딩 추가 (10%)
        let latPadding = (maxLat - minLat) * 0.1
        let lonPadding = (maxLon - minLon) * 0.1

        return QuadtreeBoundary(
            minLatitude: minLat - latPadding,
            maxLatitude: maxLat + latPadding,
            minLongitude: minLon - lonPadding,
            maxLongitude: maxLon + lonPadding
        )
    }

    // altitude에 따른 maxDepth 계산
    private func calculateMaxDepth(for altitude: Double) -> Int {
        // altitude가 낮을수록(확대) 더 깊은 depth로 클러스터링 최소화
        // altitude가 높을수록(축소) 얕은 depth로 클러스터링 적용
        switch altitude {
        case 0..<20000:
            return 50
        case 20000..<50000:
            return 45
        case 50000..<100000:
            return 40
        case 100000..<120000:
            return 35
        case 120000..<140000:
            return 30
        case 140000..<160000:
            return 25
        case 160000..<180000:
            return 20
        case 180000..<200000:
            return 15
        case 200000..<250000:
            return 12
        case 250000..<300000:
            return 10
        case 300000..<400000:
            return 8
        case 400000..<500000:
            return 6
        case 500000..<700000:
            return 4
        case 700000..<1500000:
            return 3
        default:
            return 2
        }
    }

    // 여러 산의 중심 좌표 계산
    private func calculateCenterCoordinate(for mountains: [MountainDistance]) -> CLLocationCoordinate2D {
        let count = Double(mountains.count)
        let totalLatitude = mountains.reduce(0.0) { $0 + $1.mountainLocation.latitude }
        let totalLongitude = mountains.reduce(0.0) { $0 + $1.mountainLocation.longitude }

        return CLLocationCoordinate2D(
            latitude: totalLatitude / count,
            longitude: totalLongitude / count
        )
    }

    // 개별 산 annotation 생성
    private func createIndividualAnnotation(for mountain: MountainDistance) -> MountainAnnotation {
        let annotation = MountainAnnotation()
        annotation.coordinate = mountain.coordinate
        annotation.mountainDistance = mountain
        return annotation
    }

    // altitude에 따른 최대 클러스터 거리 계산 (미터)
    private func calculateMaxClusterDistance(for altitude: Double) -> Double {
        // altitude가 낮을수록(확대) 더 짧은 거리만 클러스터링
        // altitude가 높을수록(축소) 더 먼 거리도 클러스터링
        switch altitude {
        case 0..<20000:
            return 50  // 50m 이내만 클러스터
        case 20000..<50000:
            return 100  // 100m
        case 50000..<100000:
            return 500  // 500m
        case 100000..<120000:
            return 1000  // 1km
        case 120000..<140000:
            return 1500  // 1.5km
        case 140000..<160000:
            return 2000  // 2km
        case 160000..<180000:
            return 3000  // 3km
        case 180000..<200000:
            return 5000  // 5km
        case 200000..<250000:
            return 10000  // 10km
        case 250000..<300000:
            return 15000  // 15km
        case 300000..<400000:
            return 25000  // 25km
        case 400000..<500000:
            return 40000  // 40km
        case 500000..<700000:
            return 60000  // 60km
        case 700000..<1000000:
            return 80000  // 80km
        default:
            return 120000  // 120km
        }
    }

    // 거리 기반으로 클러스터를 서브 클러스터로 분리
    private func separateByDistance(_ mountains: [MountainDistance], maxDistance: Double) -> [[MountainDistance]] {
        var subClusters: [[MountainDistance]] = []
        var remaining = mountains

        while !remaining.isEmpty {
            var currentCluster: [MountainDistance] = [remaining.removeFirst()]

            var i = 0
            while i < remaining.count {
                let mountain = remaining[i]

                // 현재 클러스터의 모든 산과의 거리를 확인
                var isNearby = false
                for clusterMountain in currentCluster {
                    let distance = mountain.coordinate.distance(to: clusterMountain.coordinate)
                    if distance <= maxDistance {
                        isNearby = true
                        break
                    }
                }

                if isNearby {
                    currentCluster.append(mountain)
                    remaining.remove(at: i)
                } else {
                    i += 1
                }
            }

            subClusters.append(currentCluster)
        }

        return subClusters
    }
}

// MARK: - MountainDistance Extension
private extension MountainDistance {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: mountainLocation.latitude,
            longitude: mountainLocation.longitude
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
