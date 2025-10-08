//
//  UIButton+Extension.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import UIKit
import Combine

extension UIButton {
    
    var tap: AnyPublisher<Void, Never> {
        return controlEventPublisher(for: .touchUpInside)
    }
    
    private func controlEventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        let subject = PassthroughSubject<Void, Never>()
        addAction(UIAction { _ in subject.send() }, for: events)
        return subject.eraseToAnyPublisher()
    }
}
