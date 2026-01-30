//
//  Array+Extension.swift
//  Presentation
//
//  Created by 김영훈 on 1/31/26.
//

extension Array {
    func uniq<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var set = Set<T>()
        return filter { set.insert($0[keyPath: keyPath]).inserted }
    }
}
