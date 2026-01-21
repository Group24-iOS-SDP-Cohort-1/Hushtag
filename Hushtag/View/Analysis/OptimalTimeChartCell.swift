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
            setupChart(data: [], topDays: [])
            return
        }

        func engagementValue(_ value: String) -> Double {
            Double(value.replacingOccurrences(of: "%", with: "")) ?? 0
        }

        let sortedData = timeData.sorted {
            engagementValue($0.audienceEngagementRate) >
            engagementValue($1.audienceEngagementRate)
        }

        let topTwo = Array(sortedData.prefix(2))

        let timeStrings = topTwo.map { item -> String in
            let hour = item.time.hour ?? 0
            let minute = item.time.minute ?? 0
            let hourStr = String(format: "%02d:%02d", hour, minute)
            let dayStr = String(item.day.prefix(3))
            return "\(hourStr) \(dayStr)"
        }

        titleLabel.text = "Best time : " + timeStrings.joined(separator: ", ")

        let topDayNames = Set(topTwo.map { $0.day })
        setupChart(data: timeData, topDays: topDayNames)

        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.applyLiquidGlassEffect()
        layer.cornerRadius = 12
        layer.masksToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        chartContainer.backgroundColor = .clear
    }

    
    
    private func setupChart(data: [AnalysisDateData], topDays: Set<String>) {
        let chartView = OptimalTimeChart(data: data, topDays: topDays)
            
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
