//
//  UIViewController+Extension.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Toast

extension UIViewController {
    
    func presentDefaultAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    func presentCancellableAlert(title: String, message: String, completionHanlder: @escaping (() -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completionHanlder()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    func showDefaultToast(message: String) {
        view.makeToast(message, duration: 1, position: .bottom)
    }
}
