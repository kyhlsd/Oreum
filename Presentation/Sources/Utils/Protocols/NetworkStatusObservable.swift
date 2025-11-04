//
//  NetworkStatusObservable.swift
//  Presentation
//
//  Created by 김영훈 on 10/25/25.
//

import UIKit
import Combine
import Core
import Data
import SnapKit

protocol NetworkStatusObservable: AnyObject {
    var networkStatusBanner: NetworkStatusBannerView? { get set }
    var networkStatusCancellable: AnyCancellable? { get set }

    func setupNetworkStatusObserver()
    func removeNetworkStatusObserver()
}

extension NetworkStatusObservable where Self: UIViewController {

    func setupNetworkStatusObserver() {
        // 배너 뷰 생성
        let banner = NetworkStatusBannerView()
        networkStatusBanner = banner

        view.addSubview(banner)
        banner.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.snp.top)
        }

        // 현재 네트워크 상태 즉시 체크
        let currentStatus = NetworkManager.shared.isConnected
        if !currentStatus {
            networkStatusBanner?.showDisconnected()
        }

        // Notification 구독
        networkStatusCancellable = NotificationCenter.default
            .publisher(for: .networkStatusChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self,
                      let isConnected = notification.userInfo?["isConnected"] as? Bool else {
                    return
                }

                if isConnected {
                    self.networkStatusBanner?.showConnected()
                } else {
                    self.networkStatusBanner?.showDisconnected()
                }
            }
    }

    func removeNetworkStatusObserver() {
        networkStatusCancellable?.cancel()
        networkStatusCancellable = nil
        networkStatusBanner?.removeFromSuperview()
        networkStatusBanner = nil
    }
}
