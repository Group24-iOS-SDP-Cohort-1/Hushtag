//
//  OptimalTimeChartCell.swift
//  Hushtag
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit
import SwiftUI

class OptimalTimeChartCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartContainer: UIView!
    private var hostingController: UIHostingController<OptimalTimeChart>?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with timeData: [AnalysisDateData]) {

        guard !timeData.isEmpty else {
            titleLabel.text = "Best time : N/A"
            setupChart(data: [], topDates: [])
            return
        }

        // Convert engagement rate safely
        func engagementValue(_ value: String) -> Double {
            Double(value.replacingOccurrences(of: "%", with: "")) ?? 0
        }

        // Sort by engagement
        let sortedData = timeData.sorted {
            engagementValue($0.audienceEngagementRate) >
            engagementValue($1.audienceEngagementRate)
        }

        // Pick top 2
        let topTwo = Array(sortedData.prefix(2))

        // Title text
        let timeStrings = topTwo.map { item -> String in
            let time = item.date.formatted(date: .omitted, time: .shortened)
            let day = item.date.formatted(.dateTime.weekday(.abbreviated))
            return "\(time) \(day)"
        }

        titleLabel.text = "Best time : " + timeStrings.joined(separator: ", ")

        // Highlight dates
        let topDates = Set(topTwo.map { $0.date })
        setupChart(data: timeData, topDates: topDates)

        // UI styling
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.applyLiquidGlassEffect()

        layer.cornerRadius = 12
        layer.masksToBounds = false

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        chartContainer.backgroundColor = .clear
    }

    private func setupChart(
        data: [AnalysisDateData],
        topDates: Set<Date>
    ) {
        let chartView = OptimalTimeChart(
            data: data,
            topDates: topDates
        )

        if let existingController = hostingController {
            existingController.rootView = chartView
        } else {
            let controller = UIHostingController(rootView: chartView)
            controller.view.backgroundColor = .clear

            chartContainer.addSubview(controller.view)
            controller.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: chartContainer.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor)
            ])

            hostingController = controller
        }
    }
}
