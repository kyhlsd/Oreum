//
//  BaseTableViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 10/1/25.
//

import UIKit

class BaseTableViewCell: UITableViewCell, Identifying {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupHierarchy()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {}
    func setupHierarchy() {}
    func setupLayout() {}
}
