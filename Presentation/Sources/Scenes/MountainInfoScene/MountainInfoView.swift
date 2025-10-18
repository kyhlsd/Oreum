//
//  MountainInfoView.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit
import Domain
import SnapKit
import Kingfisher

final class MountainInfoView: BaseView {

    // 전체 스크롤 뷰
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // 사진 이미지 뷰
    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColor.cardBackground
        imageView.kf.indicatorType = .activity
        return imageView
    }()

    // 사진 없을 때 표기 뷰
    private let emptyView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.isHidden = true
        return view
    }()
    // Placeholder 사진 이미지 뷰
    private let photoImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.photo
        imageView.tintColor = AppColor.subText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // 이미지 없음 표기 레이블
    private let photoLabel = {
        let label = UILabel.create("이미지가 없습니다", color: AppColor.subText, font: AppFont.titleM)
        label.textAlignment = .center
        return label
    }()

    // 정보 레이블
    private let infoView = BoxView(title: "정보")
    // 주소
    private let addressView = ImageItemView(icon: AppIcon.address, subtitle: "주소")
    // 높이
    private let heightView = ImageItemView(icon: AppIcon.mountain, subtitle: "높이")
    
    // 날씨 박스 뷰
    private let weatherView = BoxView()
    // 날씨 스크롤 뷰
    private let weatherScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let weatherContentView = UIView()
    // 날씨 스택 뷰
    private let weatherStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = AppSpacing.small
        return stackView
    }()
    // 날씨 정보 오류 레이블
    private let emptyWeatherLabel = {
        let label = UILabel.create("날씨 정보를 불러올 수 없습니다", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    // 날씨 로딩 뷰
    private let weatherLoadingIndicator = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // 산 소개 박스
    private let introductionView = BoxView(title: "산 소개")
    // 산 소개 텍스트뷰
    private let introductionTextView = {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.textContainerInset = UIEdgeInsets(top: AppSpacing.compact, left: AppSpacing.compact, bottom: AppSpacing.compact, right: AppSpacing.compact)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()

    // MARK: - Setups
    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [imageView, emptyView, infoView, weatherView, introductionView].forEach {
            contentView.addSubview($0)
        }

        [photoImageView, photoLabel].forEach {
            emptyView.addSubview($0)
        }

        [addressView, heightView].forEach {
            infoView.addSubview($0)
        }

        introductionView.addSubview(introductionTextView)

        weatherView.addSubview(weatherScrollView)
        weatherScrollView.addSubview(weatherContentView)
        weatherContentView.addSubview(weatherStackView)
        weatherView.addSubview(emptyWeatherLabel)
        weatherView.addSubview(weatherLoadingIndicator)
    }

    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
        }

        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }

        photoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }

        photoLabel.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(AppSpacing.compact)
            make.centerX.equalToSuperview()
        }

        infoView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }

        addressView.snp.makeConstraints { make in
            make.top.equalTo(infoView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(48)
        }

        heightView.snp.makeConstraints { make in
            make.top.equalTo(addressView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }

        weatherView.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }

        introductionView.snp.makeConstraints { make in
            make.top.equalTo(weatherView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().inset(AppSpacing.regular)
        }

        introductionTextView.snp.makeConstraints { make in
            make.top.equalTo(introductionView.lineView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }

        weatherScrollView.snp.makeConstraints { make in
            make.top.equalTo(weatherView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalToSuperview().inset(AppSpacing.compact)
            make.height.greaterThanOrEqualTo(100)
        }

        weatherContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        weatherStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyWeatherLabel.snp.makeConstraints { make in
            make.center.equalTo(weatherScrollView)
        }

        weatherLoadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(weatherScrollView)
        }
    }

    override func setupView() {
        backgroundColor = AppColor.background
        weatherLoadingIndicator.startAnimating()
    }
}

// MARK: - Binding Methods
extension MountainInfoView {
    
    // 산 이름
    func setMountainName(_ name: String) {
        weatherView.configure("\(name) 날씨")
    }
    
    // 산 주소
    func setAddress(_ address: String) {
        addressView.setTitle(title: address)
    }

    // 산 높이
    func setHeight(_ height: String) {
        heightView.setTitle(title: height)
    }

    // 산 소개
    func setIntroduction(_ attributedText: NSAttributedString) {
        introductionTextView.attributedText = attributedText
    }

    // 산 이미지
    func setImage(_ url: URL?) {
        if let url = url {
            imageView.kf.setImage(
                with: url,
                options: [
                    .processor(DownsamplingImageProcessor(size: CGSize(width: DeviceSize.width, height: DeviceSize.width * 0.75))),
                    .scaleFactor(DeviceSize.scale)
                ]
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.emptyView.isHidden = true
                case .failure:
                    self?.emptyView.isHidden = false
                }
            }
        } else {
            emptyView.isHidden = false
        }
    }

    // 날씨 오류 발생 시
    func showWeatherLoadingError() {
        weatherLoadingIndicator.stopAnimating()
        emptyWeatherLabel.isHidden = false
        weatherScrollView.isHidden = true
    }
    
    // 날씨
    func setWeeklyForecast(_ forecasts: [DailyForecast]) {
        weatherLoadingIndicator.stopAnimating()
        weatherStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if forecasts.isEmpty {
            emptyWeatherLabel.isHidden = false
            weatherScrollView.isHidden = true
            return
        }

        emptyWeatherLabel.isHidden = true
        weatherScrollView.isHidden = false

        forecasts.forEach { forecast in
            let forecastItemView = createForecastItemView(forecast: forecast)
            weatherStackView.addArrangedSubview(forecastItemView)
        }
    }

    // 날씨 뷰 생성
    private func createForecastItemView(forecast: DailyForecast) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = AppColor.boxBackground
        containerView.layer.cornerRadius = AppRadius.radius
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = AppColor.border.cgColor

        let dateString = AppFormatter.weekdayFormatter.string(from: forecast.date)

        let dateLabel = UILabel.create("\(dateString)", color: AppColor.primaryText, font: AppFont.body)
        dateLabel.textAlignment = .center

        let weatherIcon = UIImageView()
        weatherIcon.contentMode = .scaleAspectFit

        // 강수 형태에 따른 아이콘 및 색상 설정
        switch forecast.pty {
        case 1: // 비
            weatherIcon.image = UIImage(systemName: "cloud.rain")
            weatherIcon.tintColor = UIColor.systemBlue
        case 2, 4: // 비/눈
            weatherIcon.image = UIImage(systemName: "cloud.sleet")
            weatherIcon.tintColor = UIColor.systemTeal
        case 3: // 눈
            weatherIcon.image = UIImage(systemName: "cloud.snow")
            weatherIcon.tintColor = UIColor.systemCyan
        default: // 맑음
            if forecast.pop >= 50 {
                weatherIcon.image = UIImage(systemName: "cloud")
                weatherIcon.tintColor = UIColor.systemGray
            } else {
                weatherIcon.image = UIImage(systemName: "sun.max.fill")
                weatherIcon.tintColor = UIColor.systemOrange
            }
        }

        let tempLabel = UILabel.create("\(Int(forecast.minTemp))° / \(Int(forecast.maxTemp))°", color: AppColor.subText, font: AppFont.description)
        tempLabel.textAlignment = .center

        let popLabel = UILabel.create("\(forecast.pop)%", color: AppColor.subText, font: AppFont.description)
        popLabel.textAlignment = .center

        [dateLabel, weatherIcon, tempLabel, popLabel].forEach {
            containerView.addSubview($0)
        }

        containerView.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(AppSpacing.small)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
        }

        weatherIcon.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(AppSpacing.compact)
            make.centerX.equalToSuperview()
            make.size.equalTo(32)
        }

        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherIcon.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
        }

        popLabel.snp.makeConstraints { make in
            make.top.equalTo(tempLabel.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.bottom.equalToSuperview().inset(AppSpacing.small)
        }

        return containerView
    }
}
