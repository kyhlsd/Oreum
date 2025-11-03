//
//  GetRecordStatsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/31/25.
//

import Foundation

public protocol GetRecordStatsUseCase {
    func execute(records: [ClimbRecord]) -> RecordStat
}

public final class GetRecordStatsUseCaseImpl: GetRecordStatsUseCase {

    public init() {}

    public func execute(records: [ClimbRecord]) -> RecordStat {
        // 고유한 산 개수
        let uniqueMountains = Set(records.map { $0.mountain.id })
        let mountainCount = uniqueMountains.count

        // 등산 횟수
        let climbCount = records.count

        // 총 높이
        let totalHeight = records.compactMap { $0.mountain.height }.reduce(0, +)

        return RecordStat(
            mountainCount: mountainCount,
            climbCount: climbCount,
            totalHeight: totalHeight
        )
    }
}
