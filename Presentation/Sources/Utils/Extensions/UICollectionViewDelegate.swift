//
//  UICollectionViewDelegate.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import UIKit

extension UICollectionView {
    
    func register<T: Identifying>(cellClass: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: Identifying>(for indexPath: IndexPath, cellClass: T.Type) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue a cell with identifier \(cellClass.identifier) matching type \(cellClass.self)")
        }
        return cell
    }
    
}
