//
//  RecentSearchCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 10/6/25.
//

import UIKit
import Combine

final class RecentSearchCollectionViewCell: BaseCollectionViewCell {

    // 삭제 버튼 누를 때
    var onDeleteTapped: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // 전체 컨테이너 뷰
    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppRadius.medium
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        return view
    }()

    // 검색어 레이블
    private let wordLabel = {
        let label = UILabel.create(color: AppColor.primaryText, font: AppFont.tag)
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    // 삭제 버튼
    private lazy var deleteButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = AppColor.subText
        button.tap
            .sink { [weak self] in
                self?.onDeleteTapped?()
            }
            .store(in: &cancellables)
        return button
    }()
    
    // 검색어 표기
    func configure(with text: String) {
        wordLabel.text = text
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        onDeleteTapped = nil
    }
    
    // MARK: - Setups
    override func setupHierarchy() {
        contentView.addSubview(containerView)
        [wordLabel, deleteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(32)
            make.width.lessThanOrEqualTo(200)
        }

        wordLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(AppSpacing.small)
            make.leading.equalToSuperview().inset(AppSpacing.compact)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-AppSpacing.small)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.small)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
    }

}
