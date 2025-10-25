//
//  NetworkStatusBannerView.swift
//  Presentation
//
//  Created by Claude on 10/25/25.
//

import UIKit
import SnapKit

final class NetworkStatusBannerView: BaseView {

    private let label = UILabel.create(color: .white, font: AppFont.description)
    private var heightConstraint: Constraint?
    private let bannerHeight = 20.0
    private var hideWorkItem: DispatchWorkItem?

    // 네트워크 끊김
    func showDisconnected() {
        // 예약된 숨김 작업 취소
        hideWorkItem?.cancel()
        hideWorkItem = nil

        backgroundColor = .systemRed
        label.text = "네트워크 연결이 끊어졌습니다"

        show()
    }

    // 네트워크 연결됨
    func showConnected() {
        // 이전 숨김 작업 취소
        hideWorkItem?.cancel()

        backgroundColor = .systemGreen
        label.text = "네트워크가 연결되었습니다"

        show()

        // 2초 후 자동으로 숨김
        let workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
    
    // MARK: - Private Methods

    private func show() {
        heightConstraint?.update(offset: bannerHeight)

        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }

    private func hide() {
        heightConstraint?.update(offset: 0)

        UIView.animate(withDuration: 0.3) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    // MARK: - Setups
    override func setupView() {
        clipsToBounds = true
    }

    override func setupHierarchy() {
        addSubview(label)
    }

    override func setupLayout() {
        snp.makeConstraints { make in
            heightConstraint = make.height.equalTo(0).constraint
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}
