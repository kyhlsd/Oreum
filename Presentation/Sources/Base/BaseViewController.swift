//
//  BaseViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit

protocol BaseViewController: AnyObject where Self: UIViewController {
    
    associatedtype ViewModel: BaseViewModel
    associatedtype View: BaseView
    
    var mainView: View { get }
    var viewModel: ViewModel { get }
    
    func bind()
    
}
