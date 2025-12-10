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
        // Initialization code
    }
    
    func configure(with timeData: [AnalysisDateData]) {
            
            // 1. Update the Label
            // Find the absolute best day based on engagement string -> Double
        
        let sortedData = timeData.sorted {
            (Double($0.audienceEngagementRate) ?? 0.0) > (Double($1.audienceEngagementRate) ?? 0.0)
        }
        let topTwo = sortedData.prefix(2)
        
        if !topTwo.isEmpty {
            // Map them to strings like "14:00 Mon"
            let timeStrings = topTwo.map { item -> String in
                let hourStr = String(format: "%02d:%02d", item.time.hour, item.time.minute)
                let dayStr = String(item.day.prefix(3)) // Shorten "Monday" -> "Mon"
                return "\(hourStr) \(dayStr)"
            }
                    
                    // Join them with a comma: "14:00 Mon, 10:30 Sat"
            titleLabel.text = "Best time : " + timeStrings.joined(separator: ", ")
        } else {
            titleLabel.text = "Best time : N/A"
        }
        
        /*
            if let best = timeData.max(by: {
                (Double($0.audienceEngagementRate) ?? 0) < (Double($1.audienceEngagementRate) ?? 0)
            }) {
                let hourStr = String(format: "%02d:00", best.time.hour)
                let dayStr = String(best.day.prefix(3))
                titleLabel.text = "Best time : \(hourStr) \(dayStr)"
            }
         */
            
            // 2. Load the Chart
        
        let topDayNames = Set(topTwo.map { $0.day })
        
        setupChart(data: timeData, topDays: topDayNames)
        
        
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 8
        backgroundColor = .clear
        contentView.backgroundColor = .white
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
