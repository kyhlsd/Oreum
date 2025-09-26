//
//  ClimbRecordListViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
// 임시
import Domain

final class ClimbRecordListViewController: UIViewController {

    let mainView = ClimbRecordListView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ViewTest
        mainView.setSearchBarBorder(isFirstResponder: true)
        mainView.setGuideLabelText("산을 눌러서 자세한 정보를 확인하세요")
        mainView.setClimbRecords(items: ClimbRecord.dummy)
    }

}
