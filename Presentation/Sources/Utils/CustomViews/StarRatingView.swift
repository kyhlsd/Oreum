//
//  StarRatingView.swift
//  Presentation
//
//  Created by 김영훈 on 9/29/25.
//

import UIKit
import Combine

final class StarRatingView: BaseView {
    
    private let stackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()
    
    private var stars = [UIButton]()
    
    private let empty = UIImage(systemName: "star")
    private let filled = UIImage(systemName: "star.fill")
    
    @Published private(set) var rating = 0
    @Published private(set) var isEditable = true
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBindings()
    }
    
    func setRating(rating: Int, animated: Bool) {
        let clamped = max(0, min(5, rating))
        self.rating = clamped
    }
    
    func setEditable(_ isEditable: Bool) {
        self.isEditable = isEditable
    }
    
    private func setupBindings() {
        $rating
            .sink { [weak self] _ in
                self?.updateStarSelectioinStates(animated: true)
            }
            .store(in: &cancellables)
        
        $isEditable
            .sink { [weak self] isEditable in
                self?.stars.forEach { $0.isUserInteractionEnabled = isEditable }
            }
            .store(in: &cancellables)
    }
    
    private func updateStarSelectioinStates(animated: Bool) {
        for (index, star) in stars.enumerated() {
            let shouldBeSelected = index < rating
            star.tintColor = shouldBeSelected ? .systemYellow : .systemGray
            let image = shouldBeSelected ? filled : empty
            
            if animated {
                UIView.transition(with: star, duration: 0.12, options: .transitionCrossDissolve, animations: {
                    star.setImage(image, for: .normal)
                }, completion: nil)
            } else {
                star.setImage(image, for: .normal)
            }
        }
    }
    
    override func setupView() {
        for i in 0...4 {
            let star = UIButton()
            star.tintColor = .systemGray
            
            star.setImage(empty, for: .normal)
            star.setImage(filled, for: .selected)
            
            star.tap
                .sink { [weak self] in
                    guard let self, self.isEditable else { return }
                    rating = i + 1
                    updateStarSelectioinStates(animated: false)
                }
                .store(in: &cancellables)
            
            stackView.addArrangedSubview(star)
            stars.append(star)
        }
    }
    
    override func setupHierarchy() {
        addSubview(stackView)
    }
    
    override func setupLayout() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
