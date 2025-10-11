//
//  MapAnnotationViewBuilder.swift
//  Presentation
//
//  Created by Claude on 10/11/25.
//

import UIKit
import MapKit
import Combine
import Domain

// Annotation View 생성 및 스타일링을 담당하는 빌더
final class MapAnnotationViewBuilder {

    private var cancellables = Set<AnyCancellable>()
    let mountainInfoButtonTapped = PassthroughSubject<(String, Int), Never>()
    let clusterMountainSelected = PassthroughSubject<MountainDistance, Never>()

    // 클러스터 annotation view 구성
    func configureClusterView(
        _ annotationView: MKAnnotationView?,
        cluster: CustomClusterAnnotation
    ) {
        guard let annotationView = annotationView else { return }

        // "+N개" 형태로 표시
        configureAnnotationView(annotationView, with: "+\(cluster.count)개")
        configureClusterCalloutView(for: annotationView, with: cluster.mountains)
    }

    // 일반 산 annotation view 구성
    func configureMountainView(
        _ annotationView: MKAnnotationView?,
        mountainDistance: MountainDistance
    ) {
        guard let annotationView = annotationView else { return }

        configureAnnotationView(annotationView, with: mountainDistance.mountainLocation.name)
        configureCalloutView(for: annotationView, with: mountainDistance)
    }

    // MARK: - Private Methods

    private func configureAnnotationView(_ annotationView: MKAnnotationView, with title: String) {
        guard let combinedImage = createAnnotationImage(with: title) else { return }

        let imageSize = CGSize(width: 40, height: 60)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: AppColor.primaryText
        ]
        let textSize = (title as NSString).size(withAttributes: textAttributes)
        let padding: CGFloat = 8
        let backgroundHeight = textSize.height + padding
        let totalHeight = imageSize.height + backgroundHeight + 4

        annotationView.image = combinedImage
        annotationView.centerOffset = CGPoint(x: 0, y: -totalHeight / 2)
    }

    private func configureClusterCalloutView(for annotationView: MKAnnotationView, with mountains: [MountainDistance]) {
        let calloutView = ClusterCalloutView()
        calloutView.configure(with: mountains)
        calloutView.mountainSelected
            .sink { [weak self] mountain in
                self?.clusterMountainSelected.send(mountain)
            }
            .store(in: &cancellables)
        annotationView.detailCalloutAccessoryView = calloutView
    }

    private func configureCalloutView(for annotationView: MKAnnotationView, with mountainDistance: MountainDistance) {
        let calloutView = MountainAnnotationCalloutView()
        calloutView.configure(with: mountainDistance)
        calloutView.infoButton.tap
            .sink { [weak self] in
                self?.mountainInfoButtonTapped.send((
                    mountainDistance.mountainLocation.name,
                    mountainDistance.mountainLocation.height
                ))
            }
            .store(in: &cancellables)
        annotationView.detailCalloutAccessoryView = calloutView
    }

    private func createAnnotationImage(with title: String) -> UIImage? {
        guard let originalImage = UIImage(named: "MapPin", in: .module, with: nil) else { return nil }

        let imageSize = CGSize(width: 40, height: 60)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: AppColor.primaryText
        ]
        let textSize = (title as NSString).size(withAttributes: textAttributes)
        let padding: CGFloat = 8
        let backgroundWidth = textSize.width + padding * 2
        let backgroundHeight = textSize.height + padding
        let totalWidth = max(imageSize.width, backgroundWidth)
        let totalHeight = imageSize.height + backgroundHeight + 4

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        return renderer.image { context in
            let imageX = (totalWidth - imageSize.width) / 2
            originalImage.draw(in: CGRect(x: imageX, y: 0, width: imageSize.width, height: imageSize.height))

            let backgroundX = (totalWidth - backgroundWidth) / 2
            let backgroundY = imageSize.height - 8
            let backgroundRect = CGRect(x: backgroundX, y: backgroundY, width: backgroundWidth, height: backgroundHeight)
            let path = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 8)
            UIColor.white.setFill()
            path.fill()

            let textX = backgroundX + padding
            let textY = backgroundY + padding / 2
            (title as NSString).draw(at: CGPoint(x: textX, y: textY), withAttributes: textAttributes)
        }
    }
}
