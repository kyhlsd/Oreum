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
            guard let self else { return }
            self.hide()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
    
    // MARK: - Private Methods

    private func show() {
        guard let superview = superview else { return }

        snp.remakeConstraints { make in
            make.top.equalTo(superview.snp.top)
            make.horizontalEdges.equalToSuperview()
            if #available(iOS 26.0, *) {
                make.bottom.equalTo(superview.safeAreaLayoutGuide.snp.top).offset(-44)
            } else {
                make.bottom.equalTo(superview.safeAreaLayoutGuide.snp.top).offset(-40)
            }
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            superview.layoutIfNeeded()
        }
    }

    private func hide() {
        guard let superview = superview else { return }

        snp.remakeConstraints { make in
            make.top.equalTo(superview.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(superview.snp.top)
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            superview.layoutIfNeeded()
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
        label.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
        }
    }
    
}
