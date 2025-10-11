//
//  ClusterCalloutView.swift
//  Presentation
//
//  Created by Claude on 10/11/25.
//

import UIKit
import Domain
import SnapKit

final class ClusterCalloutView: BaseView {

    var onMountainSelected: ((MountainDistance) -> Void)?

    private lazy var tableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MountainCell")
        return tableView
    }()

    private var mountains = [MountainDistance]()
    private var cellHeight = 36.0

    func configure(with mountains: [MountainDistance]) {
        self.mountains = mountains.sorted { $0.mountainLocation.name < $1.mountainLocation.name }
        tableView.reloadData()
    }

    override var intrinsicContentSize: CGSize {
        // 높이 계산: 최대 5개까지만 표시, 나머지는 스크롤
        let maxVisibleRows = min(mountains.count, 5)
        let height = CGFloat(maxVisibleRows) * cellHeight
        let width = 160.0
        return CGSize(width: width, height: height)
    }
    
    override func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = AppRadius.radius
    }

    override func setupHierarchy() {
        addSubview(tableView)
    }

    override func setupLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ClusterCalloutView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mountains.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MountainCell", for: indexPath)
        let mountain = mountains[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = mountain.mountainLocation.name
        content.textProperties.font = AppFont.body
        content.textProperties.color = AppColor.primaryText

        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        cell.selectionStyle = .default

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let mountain = mountains[indexPath.row]
        onMountainSelected?(mountain)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
