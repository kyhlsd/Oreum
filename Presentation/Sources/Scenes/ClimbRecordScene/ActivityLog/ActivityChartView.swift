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

final class ActivityChartDataSource: ObservableObject {
    @Published var logs: [ActivityLog]

    init(logs: [ActivityLog] = []) {
        self.logs = logs
    }
}

final class ActivityChartContainerView: BaseView {

    private var dataSource: ActivityChartDataSource
    private var hostingController: UIHostingController<ActivityChartView>?

    init(logs: [ActivityLog] = []) {
        self.dataSource = ActivityChartDataSource(logs: logs)
        super.init(frame: .zero)
    }
    
    func setLogs(logs: [ActivityLog]) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            dataSource.logs = logs
        }
    }
    
    // MARK: - Setups
    override func setupView() {
        let chartView = ActivityChartView(dataSource: dataSource)
        let hosting = UIHostingController(rootView: chartView)
        hosting.sizingOptions = .intrinsicContentSize
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
    private let stepColor = Color.green
    private let distanceColor = Color(uiColor: AppColor.mossGreen)

    var body: some View {
        let xMinValue = dataSource.logs.first?.time ?? Date()
        let xMaxValue = (dataSource.logs.last?.time ?? Date())
        let rawMaxStep = Double(dataSource.logs.map { $0.step }.max() ?? 100)
        let rawMaxDistance = dataSource.logs.map { Double($0.distance) }.max() ?? 100.0
        let maxStep = roundToNiceNumber(rawMaxStep)
        let maxDistance = roundToNiceNumber(rawMaxDistance)

        VStack(spacing: 8) {
            // 범례
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(stepColor)
                        .frame(width: 8, height: 8)
                    Text("걸음 수")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 4) {
                    Circle()
                        .fill(distanceColor)
                        .frame(width: 8, height: 8)
                    Text("이동 거리(m)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Chart {
                        ForEach(dataSource.logs, id: \.id) { log in
                            createStepMarks(log: log, maxStep: maxStep)
                            createDistanceMarks(log: log, maxDistance: maxDistance)
                        }
                    }
                    .frame(width: chartWidth(), height: chartHeight)
                    .drawingGroup()
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
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .stride(by: 25)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    let stepValue = Int(doubleValue * maxStep / 100)
                                    Text("\(stepValue)")
                                        .font(.caption2)
                                        .foregroundColor(stepColor)
                                }
                            }
                        }
                        AxisMarks(position: .trailing, values: .stride(by: 25)) { value in
                            AxisTick()
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    let distanceValue = Int(doubleValue * maxDistance / 100)
                                    Text("\(distanceValue)m")
                                        .font(.caption2)
                                        .foregroundColor(distanceColor)
                                }
                            }
                        }
                    }
                    .chartYScale(domain: 0...110)
                    .chartXScale(domain: xMinValue...(xMaxValue + 32))
                    .chartLegend(.hidden)
                }
            }
        }
        .frame(height: chartHeight + 30)
    }
    
    // MARK: - Private Methods
    private func chartWidth() -> CGFloat {
        return max(CGFloat(dataSource.logs.count) * perItemWidth, minChartWidth)
    }

    @ChartContentBuilder
    private func createStepMarks(log: ActivityLog, maxStep: Double) -> some ChartContent {
        LineMark(
            x: .value("시간", log.time),
            y: .value("걸음 수", Double(log.step) / maxStep * 100),
            series: .value("타입", "걸음 수")
        )
        .foregroundStyle(stepColor)
        .lineStyle(StrokeStyle(lineWidth: 3))
        .interpolationMethod(.monotone)

        PointMark(
            x: .value("시간", log.time),
            y: .value("걸음 수", Double(log.step) / maxStep * 100)
        )
        .foregroundStyle(stepColor)
        .symbolSize(40)
        .symbol(.circle)
    }

    @ChartContentBuilder
    private func createDistanceMarks(log: ActivityLog, maxDistance: Double) -> some ChartContent {
        LineMark(
            x: .value("시간", log.time),
            y: .value("이동 거리", Double(log.distance) / maxDistance * 100),
            series: .value("타입", "이동 거리")
        )
        .foregroundStyle(distanceColor)
        .lineStyle(StrokeStyle(lineWidth: 3))
        .interpolationMethod(.monotone)

        PointMark(
            x: .value("시간", log.time),
            y: .value("이동 거리", Double(log.distance) / maxDistance * 100)
        )
        .foregroundStyle(distanceColor)
        .symbolSize(35)
        .symbol(.square)
    }

    // 깔끔한 숫자로 반올림
    private func roundToNiceNumber(_ value: Double) -> Double {
        guard value > 0 else { return 100 }

        let magnitude = pow(10, floor(log10(value)))
        let normalized = value / magnitude

        let nice: Double
        if normalized <= 1 {
            nice = 1
        } else if normalized <= 2 {
            nice = 2
        } else if normalized <= 5 {
            nice = 5
        } else {
            nice = 10
        }

        return nice * magnitude
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

