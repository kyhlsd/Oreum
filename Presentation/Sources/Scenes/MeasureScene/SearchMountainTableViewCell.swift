//
//  SearchMountainTableViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Domain

final class SearchMountainTableViewCell: BaseTableViewCell {

    private let itemView = ItemView()

    override func setupView() {
        backgroundColor = .clear
        selectionStyle = .default
        
        itemView.setAlignment(.left)
    }
    
    override func setupHierarchy() {
        contentView.addSubview(itemView)
    }
    
    override func setupLayout() {
        itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(AppSpacing.compact)
        }
    }

    func setData(mountain: Mountain) {
        itemView.setTitle(title: mountain.name)
        itemView.setSubtitle(subtitle: mountain.address)
    }
}
