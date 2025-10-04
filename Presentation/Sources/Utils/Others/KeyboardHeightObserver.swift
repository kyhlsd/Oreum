//
//  KeyboardHeightObserver.swift
//  Presentation
//
//  Created by 김영훈 on 9/29/25.
//

import UIKit

final class KeyboardHeightObserver {
    
    var didKeyboardHeightChange: ((CGFloat) -> Void)?
    private var willShowObserver: NSObjectProtocol?
    private var willHideObserver: NSObjectProtocol?
    private let center = NotificationCenter.default
    
    init() {
        willShowObserver = center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main, using: { [weak self] notification in
            self?.keyboardWillChange(notification: notification)
        })
        
        willHideObserver = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.didKeyboardHeightChange?(0)
        })
    }
    
    deinit {
        if let willShowObserver {
            center.removeObserver(willShowObserver)
        }
        
        if let willHideObserver {
            center.removeObserver(willHideObserver)
        }
    }
    
    private func keyboardWillChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = frameValue.cgRectValue.height
        didKeyboardHeightChange?(keyboardHeight)
    }
}
