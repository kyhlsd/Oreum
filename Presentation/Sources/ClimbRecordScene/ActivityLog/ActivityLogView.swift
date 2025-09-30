//
//  ActivityLogView.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Combine
import Domain
import SnapKit

final class ActivityLogView: BaseView {
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let titleLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleM)
    
    private let dateLabel = UILabel.create(color: AppColor.subText, font: AppFont.body)
    
    private let summaryBoxView = BoxView(title: "요약")
    private let summaryTimeView = ItemView(subtitle: "소요시간")
    private let summaryDistanceView = ItemView(subtitle: "이동 거리")
    private let summaryStepView = ItemView(subtitle: "걸음 수")
    private lazy var summaryLeftLineView = createVerticalLineView()
    private lazy var summaryRightLineView = createVerticalLineView()
    
    private let timeBoxView = BoxView(title: "등산 시간")
    private let startTimeView = ItemView(subtitle: "시작 시간")
    private let endTimeView = ItemView(subtitle: "완료 시간")
    private let totalTimeView = ItemView(subtitle: "총 소요시간")
    private let exerciseTimeView = ItemView(subtitle: "운동 시간")
    private let restTimeView = ItemView(subtitle: "휴식 시간")
    private lazy var timeLeftLineView = createVerticalLineView()
    private lazy var timeRightLineView = createVerticalLineView()
    private lazy var timeCenterLineView = createVerticalLineView()
    private lazy var timeHorizontalLineView = createHorizontalLineView()
    
    private let distanceBoxView = BoxView(title: "시간별 거리(m)")
    private let distanceChartView = ActivityChartContainerView(metric: .distance)
    
    private let stepBoxView = BoxView(title: "시간별 걸음 수")
    private let stepChartView = ActivityChartContainerView(metric: .step)
    
    private func createVerticalLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = AppColor.border
        view.snp.makeConstraints { make in
            make.width.equalTo(1)
        }
        return view
    }
    
    private func createHorizontalLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = AppColor.border
        view.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        return view
    }
    
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
    }
    
    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, dateLabel, summaryBoxView, timeBoxView, distanceBoxView, stepBoxView].forEach {
            contentView.addSubview($0)
        }
        
        [summaryTimeView, summaryDistanceView, summaryStepView, summaryLeftLineView, summaryRightLineView].forEach {
            summaryBoxView.addSubview($0)
        }
        
        [startTimeView, endTimeView, totalTimeView, exerciseTimeView, restTimeView, timeLeftLineView, timeRightLineView, timeCenterLineView, timeHorizontalLineView].forEach {
            timeBoxView.addSubview($0)
        }
        
        distanceBoxView.addSubview(distanceChartView)
        
        stepBoxView.addSubview(stepChartView)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(AppSpacing.regular)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.lastBaseline.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(AppSpacing.compact)
        }
        
        summaryBoxView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
        
        summaryTimeView.snp.makeConstraints { make in
            make.top.equalTo(summaryBoxView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.leading.bottom.equalToSuperview().inset(AppSpacing.compact)
        }
        
        summaryDistanceView.snp.makeConstraints { make in
            make.verticalEdges.width.equalTo(summaryTimeView)
            make.leading.equalTo(summaryTimeView.snp.trailing).offset(AppSpacing.compact)
        }
        
        summaryStepView.snp.makeConstraints { make in
            make.verticalEdges.width.equalTo(summaryTimeView)
            make.leading.equalTo(summaryDistanceView.snp.trailing).offset(AppSpacing.compact)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
        }
        
        summaryLeftLineView.snp.makeConstraints { make in
            make.centerX.equalTo(summaryTimeView.snp.trailing)
            make.verticalEdges.equalTo(summaryTimeView)
        }
        
        summaryRightLineView.snp.makeConstraints { make in
            make.centerX.equalTo(summaryDistanceView.snp.trailing)
            make.verticalEdges.equalTo(summaryDistanceView)
        }
        
        timeBoxView.snp.makeConstraints { make in
            make.top.equalTo(summaryBoxView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
        
        startTimeView.snp.makeConstraints { make in
            make.top.equalTo(timeBoxView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.leading.equalToSuperview().offset(AppSpacing.compact)
            make.bottom.equalTo(timeHorizontalLineView.snp.centerY).offset(-AppSpacing.compact)
        }
        
        endTimeView.snp.makeConstraints { make in
            make.verticalEdges.width.equalTo(startTimeView)
            make.leading.equalTo(startTimeView.snp.trailing)
        }
        
        totalTimeView.snp.makeConstraints { make in
            make.verticalEdges.width.equalTo(startTimeView)
            make.leading.equalTo(endTimeView.snp.trailing)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
        }
        
        exerciseTimeView.snp.makeConstraints { make in
            make.leading.height.equalTo(startTimeView)
            make.top.equalTo(timeHorizontalLineView.snp.centerY).offset(AppSpacing.compact)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
            make.trailing.equalTo(timeBoxView.snp.centerX)
        }
        
        restTimeView.snp.makeConstraints { make in
            make.leading.equalTo(timeBoxView.snp.centerX)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.verticalEdges.equalTo(exerciseTimeView)
        }
        
        timeLeftLineView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(startTimeView)
            make.centerX.equalTo(startTimeView.snp.trailing)
        }
        
        timeRightLineView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(endTimeView)
            make.centerX.equalTo(endTimeView.snp.trailing)
        }
        
        timeCenterLineView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(exerciseTimeView)
            make.centerX.equalTo(exerciseTimeView.snp.trailing)
        }
        
        timeHorizontalLineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
        }
        
        distanceBoxView.snp.makeConstraints { make in
            make.top.equalTo(timeBoxView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
        
        distanceChartView.snp.makeConstraints { make in
            make.top.equalTo(distanceBoxView.lineView.snp.top).offset(AppSpacing.compact)
            make.bottom.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
        }
        
        stepBoxView.snp.makeConstraints { make in
            make.top.equalTo(distanceBoxView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().inset(AppSpacing.regular)
        }
        
        stepChartView.snp.makeConstraints { make in
            make.top.equalTo(stepBoxView.lineView.snp.top).offset(AppSpacing.compact)
            make.bottom.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
        }
    }
}

// MARK: - Binding Methods
extension ActivityLogView {
    
    func setData(climbRecord: ClimbRecord) {
        titleLabel.text = climbRecord.mountain.name
        if let date = climbRecord.timeLog.first?.time {
            dateLabel.text = AppFormatter.dateFormatter.string(from: date)
        }
        
        summaryTimeView.setTitle(title: climbRecord.totalDuration)
        let totalDistance = climbRecord.timeLog.last?.distance.formatted() ?? "0"
        summaryDistanceView.setTitle(title: totalDistance + "m")
        let totalStep = climbRecord.timeLog.last?.step.formatted() ?? "0"
        summaryStepView.setTitle(title: totalStep)
        
        if let startDate = climbRecord.timeLog.first?.time {
            startTimeView.setTitle(title: AppFormatter.timeFormatter.string(from: startDate))
        }
        if let endDate = climbRecord.timeLog.last?.time {
            endTimeView.setTitle(title: AppFormatter.timeFormatter.string(from: endDate))
        }
        totalTimeView.setTitle(title: climbRecord.totalDuration)
        
        let restAndExercise = calculateRestAndExerciseTime(from: climbRecord.timeLog)
        let restTime = formatMinutes(restAndExercise.restMinutes)
        let exerciseTime = formatMinutes(restAndExercise.exerciseMinutes)
        restTimeView.setTitle(title: restTime)
        exerciseTimeView.setTitle(title: exerciseTime)
        
        distanceChartView.setLogs(logs: climbRecord.timeLog)
        
        stepChartView.setLogs(logs: climbRecord.timeLog)
    }
}

// MARK: - Calculate Methods
extension ActivityLogView {
    
    private func calculateRestAndExerciseTime(from logs: [ActivityLog]) -> (restMinutes: Int, exerciseMinutes: Int) {
        var restMinutes = 0
        var exerciseMinutes = 0
        
        for log in logs {
            if log.distance < 100 {
                restMinutes += 5
            } else {
                exerciseMinutes += 5
            }
        }
        
        return (restMinutes, exerciseMinutes)
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)시간 \(mins)분"
        } else {
            return "\(mins)분"
        }
    }
}
