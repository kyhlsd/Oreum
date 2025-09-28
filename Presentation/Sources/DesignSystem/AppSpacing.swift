//
//  AppSpacing.swift
//  Common
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit

enum AppSpacing {
    // 일반적인 패딩 (20pt)
    static let regular: CGFloat = 20
    
    // 작은 카드나 컴팩트한 요소 (12pt)
    static let compact: CGFloat = 12
    
    // 최소한의 패딩 (8pt)
    static let small: CGFloat = 8
    
    // 배지나 태그 (좌우 8pt, 상하 4pt)
    static let badge = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    // 헤더 섹션 (상하 0pt, 좌우 16pt)
    static let header = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    // 컨텐츠 섹션 (상하 16pt, 좌우 16pt)
    static let content = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
}

/*
p-0   = 0px
p-0.5 = 2px
p-1   = 4px
p-1.5 = 6px
p-2   = 8px
p-2.5 = 10px
p-3   = 12px
p-3.5 = 14px
p-4   = 16px
p-5   = 20px
p-6   = 24px
p-8   = 32px
p-10  = 40px
p-12  = 48px
*/
