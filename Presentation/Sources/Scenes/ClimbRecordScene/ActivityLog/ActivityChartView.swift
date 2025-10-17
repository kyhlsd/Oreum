//
//  ActivityChartView.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import SwiftUI
import Charts
import SnapKit
import Domain

enum ActivityChartMetric {
    case step
    case distance
}

final class ActivityChartDataSource: ObservableObject {
    @Published var logs: [ActivityLog]
    let metric: ActivityChartMetric
    
    init(logs: [ActivityLog] = [], metric: ActivityChartMetric) {
        self.logs = logs
        self.metric = metric
    }
}

final class ActivityChartContainerView: BaseView {
    
    private var dataSource: ActivityChartDataSource
    private var hostingController: UIHostingController<ActivityChartView>?
    
    init(logs: [ActivityLog] = [], metric: ActivityChartMetric) {
        self.dataSource = ActivityChartDataSource(logs: logs, metric: metric)
        super.init(frame: .zero)
    }
    
    func setLogs(logs: [ActivityLog]) {
        dataSource.logs = logs
    }
    
    // MARK: - Setups
    override func setupView() {
        let chartView = ActivityChartView(dataSource: dataSource)
        let hosting = UIHostingController(rootView: chartView)
        hostingController = hosting
        
        guard let hcView = hosting.view else { return }
        hcView.backgroundColor = .clear
    }
    
    override func setupHierarchy() {
        guard let hcView = hostingController?.view else { return }
        addSubview(hcView)
    }
    
    override func setupLayout() {
        guard let hcView = hostingController?.view else { return }
        hcView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

// MARK: - ChartView (SwiftUI)
struct ActivityChartView: View {
    
    @ObservedObject var dataSource: ActivityChartDataSource
    
    private let perItemWidth = 12.0
    private let minChartWidth = 250.0
    private let chartHeight = 200.0
    private let yMinValue = 0.0
    
    var body: some View {
        let yMaxValue = calculateYMax()
        let xMinValue = dataSource.logs.first?.time ?? Date()
        let xMaxValue = (dataSource.logs.last?.time ?? Date())
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                Chart(dataSource.logs, id: \.id) { log in
                    LineMark(
                        x: .value("시간", log.time),
                        y: .value(dataSource.metric == .step ? "걸음 수" : "이동거리(m)",
                                  dataSource.metric == .step ? log.step : log.distance)
                    )
                    .foregroundStyle(dataSource.metric == .step ? .green : .blue)
                    .interpolationMethod(.monotone)
                    
                    AreaMark(
                        x: .value("시간", log.time),
                        y: .value(dataSource.metric == .step ? "걸음 수" : "이동거리(m)",
                                  dataSource.metric == .step ? log.step : log.distance)
                    )
                    .foregroundStyle((dataSource.metric == .step ? Color.green : Color.blue).opacity(0.3))
                    
                    PointMark(
                        x: .value("시간", log.time),
                        y: .value(dataSource.metric == .step ? "걸음 수" : "이동거리(m)",
                                  dataSource.metric == .step ? log.step : log.distance)
                    )
                    .foregroundStyle(dataSource.metric == .step ? Color.green : Color.blue)
                    .symbolSize(24)
                }
                .frame(width: chartWidth(), height: chartHeight)
                .chartXAxis {
                    AxisMarks(values: generateXAxisValues()) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(elapsedTimeString(from: date))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartYScale(domain: yMinValue...(yMaxValue + 20))
                .chartXScale(domain: xMinValue...(xMaxValue + 32))
            }
        }
        .frame(height: chartHeight)
    }
    
    // MARK: - Private Methods
    private func chartWidth() -> CGFloat {
        return max(CGFloat(dataSource.logs.count) * perItemWidth, minChartWidth)
    }
    
    // 걸음 수, 이동 거리 최댓값에 따라 차트 Y 최댓값 설정
    private func calculateYMax() -> Double {
        let min = 100.0
        guard !dataSource.logs.isEmpty else { return min }
        
        let maxValue = (dataSource.metric == .step
                        ? dataSource.logs.map { Double($0.step) }.max()
                        : dataSource.logs.map { Double($0.distance) }.max() ?? min) ?? min
        
        var yMax = maxValue * 1.1
        
        let remainder = yMax.truncatingRemainder(dividingBy: 100)
        if remainder != 0 {
            yMax += 100 - remainder
        }
        
        return yMax
    }
    
    // 30분 간격으로 X Label 표기할 [Date] 생성
    private func generateXAxisValues() -> [Date] {
        guard let start = dataSource.logs.first?.time,
              let last = dataSource.logs.last?.time else { return [] }

        var values: [Date] = []
        var current = start
        let calendar = Calendar.current

        while current <= last {
            values.append(current)
            if let next = calendar.date(byAdding: .minute, value: 30, to: current) {
                current = next
            } else {
                break
            }
        }

        return values
    }
    
    // Date -> 30분, 60분 형식으로 변환
    private func elapsedTimeString(from date: Date) -> String {
        guard let start = dataSource.logs.first?.time else { return "" }

        let elapsedMinutes = Int(date.timeIntervalSince(start) / 60)
        
        let roundedMinutes = ((elapsedMinutes + 29) / 30) * 30
        
        return "\(roundedMinutes)분"
    }
}

