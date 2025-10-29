//
//  TimeChartView.swift
//  Presentation
//
//  Created by 김영훈 on 10/29/25.
//

import SwiftUI
import Charts
import SnapKit
import Domain

final class TimeChartDataSource: ObservableObject {
    @Published var averageStat: AverageActivityStat?
    @Published var activityStat: ActivityStat?

    init(averageStat: AverageActivityStat? = nil, activityStat: ActivityStat? = nil) {
        self.averageStat = averageStat
        self.activityStat = activityStat
    }
}

final class TimeChartContainerView: BaseView {

    private var dataSource: TimeChartDataSource
    private lazy var hostingController: UIHostingController<TimeChartView> = {
        let chartView = TimeChartView(dataSource: dataSource)
        let hosting = UIHostingController(rootView: chartView)
        hosting.sizingOptions = .intrinsicContentSize
        hosting.view?.backgroundColor = .clear
        return hosting
    }()

    init(averageStat: AverageActivityStat? = nil, activityStat: ActivityStat? = nil) {
        self.dataSource = TimeChartDataSource(averageStat: averageStat, activityStat: activityStat)
        super.init(frame: .zero)
    }

    func setStats(averageStat: AverageActivityStat, activityStat: ActivityStat) {
        // hostingController를 강제로 초기화하고 뷰 추가
        if hostingController.view.superview == nil {
            addSubview(hostingController.view)
            hostingController.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            dataSource.averageStat = averageStat
            dataSource.activityStat = activityStat
        }
    }

    // MARK: - Setups
    override func setupView() {
        backgroundColor = .clear
    }

    override func setupHierarchy() {
        // 차트는 setStats가 호출될 때 추가됨
    }

    override func setupLayout() {
        // 차트는 setStats가 호출될 때 레이아웃 설정됨
    }
}

// MARK: - ChartView (SwiftUI)
struct TimeChartView: View {

    @ObservedObject var dataSource: TimeChartDataSource

    private let chartHeight = 120.0
    private let activeColor = Color(uiColor: AppColor.forestGreen)
    private let restColor = Color.gray
    private let textFont = Font(AppFont.description)
    private let subTextColor = Color(uiColor: AppColor.subText)

    // MARK: - Computed Properties
    private var averageActiveMinutes: Int {
        dataSource.averageStat?.averageExerciseMinutes ?? 0
    }

    private var averageRestMinutes: Int {
        dataSource.averageStat?.averageRestMinutes ?? 0
    }

    private var currentActiveMinutes: Int {
        dataSource.activityStat?.exerciseMinutes ?? 0
    }

    private var currentRestMinutes: Int {
        dataSource.activityStat?.restMinutes ?? 0
    }

    private var averageSpeed: Double {
        dataSource.averageStat?.averageSpeed ?? 0
    }

    private var currentSpeed: Double {
        guard let activityStat = dataSource.activityStat,
              activityStat.exerciseMinutes > 0 else {
            return 0
        }
        return Double(activityStat.totalDistance) / Double(activityStat.exerciseMinutes)
    }

    private var maxValue: Int {
        max(
            averageActiveMinutes + averageRestMinutes,
            currentActiveMinutes + currentRestMinutes
        )
    }

    var body: some View {
        guard dataSource.averageStat != nil,
              dataSource.activityStat != nil else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(spacing: 8) {
                // 범례
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(activeColor)
                            .frame(width: 8, height: 8)
                        Text("운동 시간")
                            .font(.caption)
                            .foregroundColor(subTextColor)
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(restColor)
                            .frame(width: 8, height: 8)
                        Text("휴식 시간")
                            .font(.caption)
                            .foregroundColor(subTextColor)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // 차트
                Chart {
                    // 평균 기록
                    BarMark(
                        x: .value("시간", averageActiveMinutes),
                        y: .value("유형", "평균")
                    )
                    .foregroundStyle(activeColor)
                    .annotation(position: .overlay) {
                        if averageActiveMinutes > 0 {
                            Text("\(averageActiveMinutes)분")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }

                    BarMark(
                        x: .value("시간", averageRestMinutes),
                        y: .value("유형", "평균")
                    )
                    .foregroundStyle(restColor)
                    .annotation(position: .overlay) {
                        if averageRestMinutes > 0 {
                            Text("\(averageRestMinutes)분")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }

                    // 이번 기록
                    BarMark(
                        x: .value("시간", currentActiveMinutes),
                        y: .value("유형", "이번")
                    )
                    .foregroundStyle(activeColor)
                    .annotation(position: .overlay) {
                        if currentActiveMinutes > 0 {
                            Text("\(currentActiveMinutes)분")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }

                    BarMark(
                        x: .value("시간", currentRestMinutes),
                        y: .value("유형", "이번")
                    )
                    .foregroundStyle(restColor)
                    .annotation(position: .overlay) {
                        if currentRestMinutes > 0 {
                            Text("\(currentRestMinutes)분")
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
                .frame(height: chartHeight)
                .chartXAxis(.hidden)
                .chartXScale(domain: 0...(maxValue + 10))
                .chartLegend(.hidden)
                .padding(.horizontal)

                // 속도 표시
                HStack {
                    Text("평균 속도: ")
                        .font(textFont)
                        .foregroundColor(subTextColor)
                    Text(String(format: "%.1f m/m", averageSpeed))
                        .font(textFont)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(" | ")
                        .font(textFont)
                        .foregroundColor(subTextColor)
                    Spacer()
                    Text("이번 속도: ")
                        .font(textFont)
                        .foregroundColor(subTextColor)
                    Text(String(format: "%.1f m/m", currentSpeed))
                        .font(textFont)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
        )
    }
}

