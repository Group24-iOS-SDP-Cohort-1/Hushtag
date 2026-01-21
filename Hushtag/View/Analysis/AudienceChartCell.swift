//
//  AudienceChartCell.swift
//  Hushtag
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit
import SwiftUI

class AudienceChartCell: UICollectionViewCell {

    @IBOutlet weak var chartContainer: UIView!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var followersChangeLabel: UILabel!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var postsLabel: UILabel!
    
    private var hostingController: UIHostingController<AudienceGenderChart>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with data: Analysis) {
            // A. Update the standard labels
            followersLabel.text = data.followers
            postsLabel.text = "\(data.post)"
            
            if data.ageGroup.count >= 2 {
                ageLabel.text = "\(data.ageGroup[0])-\(data.ageGroup[1]) years"
            }

            // B. Embed the Chart
            setupChart(genderData: data.gender)
        
        
        let currentTotal = parseMetric(data.followers)     // "40k" -> 40000.0
        let changeAmount = parseMetric(data.incFollowers)
        
        let previousTotal = currentTotal - changeAmount
        
        if previousTotal != 0 {
                let percentChange = (changeAmount / previousTotal) * 100
                
                if percentChange > 0 {
                    // POSITIVE: Force the "+" sign and use Green
                    followersChangeLabel.text = String(format: "+%.0f%%", percentChange)
                    followersChangeLabel.textColor = UIColor.systemGreen
                } else if percentChange < 0 {
                    // NEGATIVE: The "-" sign is automatic in the number. Use Red.
                    // String(format: "%.0f") turns -25.0 into "-25"
                    followersChangeLabel.text = String(format: "%.0f%%", percentChange)
                    followersChangeLabel.textColor = UIColor.systemRed
                } else {
                    // ZERO: Grey
                    followersChangeLabel.text = "0%"
                    followersChangeLabel.textColor = UIColor.gray
                }
            } else {
                // Edge case: If previous total was 0 (new account), growth is 100% or undefined
                followersChangeLabel.text = "N/A"
                followersChangeLabel.textColor = .gray
            }
        
        
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.applyLiquidGlassEffect()
        layer.cornerRadius = 12
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        chartContainer.backgroundColor = .clear
    }
    
    
    
    private func setupChart(genderData: [String: String]) {
            let chartView = AudienceGenderChart(genderData: genderData)

            if let existingController = hostingController {
                // Optimization: If chart already exists, just update data
                existingController.rootView = chartView
            } else {
                // Create new Hosting Controller
                let controller = UIHostingController(rootView: chartView)
                controller.view.backgroundColor = .clear
                
                // Add to the container view
                chartContainer.addSubview(controller.view)
                
                // Auto Layout (Pin edges to container)
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

    
    
    private func parseMetric(_ value: String) -> Double {
        let clean = value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if clean.hasSuffix("k") {
            let number = clean.dropLast()
            return (Double(number) ?? 0) * 1_000
        } else if clean.hasSuffix("m") {
            let number = clean.dropLast()
            return (Double(number) ?? 0) * 1_000_000
        }
        return Double(clean) ?? 0
    }
    
    
}
