//
//  ActivityLogView.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Domain
import SnapKit

final class ActivityLogView: BaseView {
    
    // 전체 스크롤 뷰
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 산 이름
    private let titleLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleM)
    // 등산 날짜
    private let dateLabel = UILabel.create(color: AppColor.subText, font: AppFont.body)
    
    // 요약 박스
    private let summaryBoxView = BoxView(title: "요약")
    // 소요시간
    private let summaryTimeView = ItemView(subtitle: "소요시간")
    // 이동 거리
    private let summaryDistanceView = ItemView(subtitle: "이동 거리")
    // 걸음 수
    private let summaryStepView = ItemView(subtitle: "걸음 수")
    // 구분선
    private lazy var summaryLeftLineView = createVerticalLineView()
    private lazy var summaryRightLineView = createVerticalLineView()
    
    // 시간 박스
    private let timeBoxView = BoxView(title: "등산 시간")
    // 시작 시간
    private let startTimeView = ItemView(subtitle: "시작 시간")
    // 완료 시간
    private let endTimeView = ItemView(subtitle: "완료 시간")
    // 총 소요 시간
    private let totalTimeView = ItemView(subtitle: "총 소요 시간")
    // 운동 시간
    private let exerciseTimeView = ItemView(subtitle: "운동 시간")
    // 휴식 시간
    private let restTimeView = ItemView(subtitle: "휴식 시간")
    // 구분선
    private lazy var timeLeftLineView = createVerticalLineView()
    private lazy var timeRightLineView = createVerticalLineView()
    private lazy var timeCenterLineView = createVerticalLineView()
    private lazy var timeHorizontalLineView = createHorizontalLineView()
    
    // 시간별 활동 박스
    private let activityBoxView = BoxView(title: "시간별 활동")
    // 시간별 활동 차트 (걸음 수 + 이동 거리)
    private lazy var activityChartView = ActivityChartContainerView()
    // 차트 로딩 indicator
    private let chartLoadingIndicator = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = AppColor.primary
        return indicator
    }()
    
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
        chartLoadingIndicator.startAnimating()
    }
    
    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, dateLabel, summaryBoxView, timeBoxView, activityBoxView].forEach {
            contentView.addSubview($0)
        }

        [summaryTimeView, summaryDistanceView, summaryStepView, summaryLeftLineView, summaryRightLineView].forEach {
            summaryBoxView.addSubview($0)
        }

        [startTimeView, endTimeView, totalTimeView, exerciseTimeView, restTimeView, timeLeftLineView, timeRightLineView, timeCenterLineView, timeHorizontalLineView].forEach {
            timeBoxView.addSubview($0)
        }

        activityBoxView.addSubview(chartLoadingIndicator)
        // activityChartView는 setChartLoading(false)에서 추가
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
            make.width.equalTo(summaryTimeView)
        }
        
        summaryStepView.snp.makeConstraints { make in
            make.verticalEdges.width.equalTo(summaryTimeView)
            make.leading.equalTo(summaryDistanceView.snp.trailing).offset(AppSpacing.compact)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.width.equalTo(summaryTimeView)
        }
        
        summaryLeftLineView.snp.makeConstraints { make in
            make.centerX.equalTo(summaryTimeView.snp.trailing).offset(AppSpacing.compact / 2)
            make.verticalEdges.equalTo(summaryTimeView)
        }
        
        summaryRightLineView.snp.makeConstraints { make in
            make.centerX.equalTo(summaryDistanceView.snp.trailing).offset(AppSpacing.compact / 2)
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
            make.width.equalTo(startTimeView)
        }
        
        totalTimeView.snp.makeConstraints { make in
            make.verticalEdges.width.equalTo(startTimeView)
            make.leading.equalTo(endTimeView.snp.trailing)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.width.equalTo(startTimeView)
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

        activityBoxView.snp.makeConstraints { make in
            make.top.equalTo(timeBoxView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().inset(AppSpacing.regular)
            make.height.greaterThanOrEqualTo(200)
        }

        chartLoadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(activityBoxView)
        }
    }
}

// MARK: - Binding Methods
extension ActivityLogView {
    
    // 산 이름
    func setMountainName(name: String) {
        titleLabel.text = name
    }
    
    // 등산 시간
    func setStat(activityStat: ActivityStat) {
        if let startTime = activityStat.startTime {
            dateLabel.text = AppFormatter.dateFormatter.string(from: startTime)
        } else {
            dateLabel.text = "기록 없음"
        }
        
        summaryTimeView.setTitle(title: formatMinutes(activityStat.totalTimeMinutes))
        summaryDistanceView.setTitle(title: activityStat.totalDistance.formatted() + "m")
        summaryStepView.setTitle(title: activityStat.totalSteps.formatted())
        
        if let startTime = activityStat.startTime {
            startTimeView.setTitle(title: AppFormatter.timeFormatter.string(from: startTime))
        } else {
            startTimeView.setTitle(title: "기록 없음")
        }
        
        if let endTime = activityStat.endTime {
            endTimeView.setTitle(title: AppFormatter.timeFormatter.string(from: endTime))
        } else {
            endTimeView.setTitle(title: "기록 없음")
        }
        
        totalTimeView.setTitle(title: formatMinutes(activityStat.totalTimeMinutes))
        exerciseTimeView.setTitle(title: formatMinutes(activityStat.exerciseMinutes))
        restTimeView.setTitle(title: formatMinutes(activityStat.restMinutes))
    }
    
    // 걸음 수, 이동 거리 차트
    func setActivityLogs(activityLogs: [ActivityLog]) {
        activityChartView.setLogs(logs: activityLogs)
    }

    // 차트 로딩 상태
    func setChartLoading(_ isLoading: Bool) {
        if isLoading {
            chartLoadingIndicator.startAnimating()
        } else {
            chartLoadingIndicator.stopAnimating()

            // 차트 뷰를 처음 추가하고 레이아웃 설정
            if activityChartView.superview == nil {
                activityBoxView.addSubview(activityChartView)
                activityChartView.snp.makeConstraints { make in
                    make.top.equalTo(activityBoxView.lineView.snp.top).offset(AppSpacing.compact)
                    make.bottom.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
                }
            }

            activityChartView.isHidden = false
        }
    }

    // 시간 표기
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
