//
//  ImageDataManager.swift
//  Presentation
//
//  Created by 김영훈 on 10/4/25.
//

import UIKit

final class ImageDataManager {
    
    enum Format {
        case jpeg(quality: CGFloat)
        case png
    }
    
    private let width: CGFloat
    
    init(width: CGFloat) {
        self.width = width
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func resizeAspectFit(_ image: UIImage, maxSize: CGSize) -> UIImage? {
        let widthRatio = maxSize.width / image.size.width
        let heightRatio = maxSize.height / image.size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: image.size.width * scaleFactor,
                             height: image.size.height * scaleFactor)
        return resizeImage(image, targetSize: newSize)
    }
    
    func process(_ image: UIImage, format: Format) -> Data? {
        let targetHeight = width * 0.75
        let targetSize = CGSize(width: width, height: targetHeight)
        
        guard let resizedImage = resizeAspectFit(image, maxSize: targetSize) else {
            return nil
        }
        
        switch format {
        case .jpeg(let quality):
            return resizedImage.jpegData(compressionQuality: quality)
        case .png:
            return resizedImage.pngData()
        }
    }
}
