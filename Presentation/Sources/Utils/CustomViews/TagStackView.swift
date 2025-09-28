//
//  TagStackView.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import UIKit

final class TagStackView: UIStackView {
    
    private lazy var firstVisitLabel = createTagLabel(text: "정복", textColor: AppColor.firstVisitForeground, backgroundColor: AppColor.firstVisitBackground)
    
    private lazy var famousLabel = createTagLabel(text: "명산", textColor: AppColor.famousForeground, backgroundColor: AppColor.famousBackground)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
        spacing = 4
        alignment = .center
        
        firstVisitLabel.setContentHuggingPriority(.required, for: .horizontal)
        famousLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(isFirstVisit: Bool, isFamous: Bool) {
        clear()
        
        if isFirstVisit {
            addArrangedSubview(firstVisitLabel)
        }
        
        if isFamous {
            addArrangedSubview(famousLabel)
        }
    }
    
    private func clear() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    private func createTagLabel(text: String, textColor: UIColor, backgroundColor: UIColor) -> UILabel {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        label.text = text
        label.font = AppFont.tag
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.layer.cornerRadius = AppRadius.radius
        label.clipsToBounds = true
        return label
    }
}
