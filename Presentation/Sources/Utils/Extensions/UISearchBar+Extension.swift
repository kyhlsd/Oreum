//
//  UISearchBar+Extension.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import UIKit
import Combine

extension UISearchBar {
    var textDidChange: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UISearchTextField.textDidChangeNotification, object: self.searchTextField)
            .compactMap { ($0.object as? UISearchTextField)?.text }
            .eraseToAnyPublisher()
    }
}
