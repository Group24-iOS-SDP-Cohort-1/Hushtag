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
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var postsLabel: UILabel!
    
    private var hostingController: UIHostingController<AudienceGenderChart>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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

    
}
