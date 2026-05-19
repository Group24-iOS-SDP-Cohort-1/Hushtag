import SwiftUI
import UIKit

class AudienceChartCell: UICollectionViewCell {
    @IBOutlet var chartContainer: UIView!

    @IBOutlet var followersLabel: UILabel!

    @IBOutlet var followersChangeLabel: UILabel!

    @IBOutlet var ageLabel: UILabel!

    @IBOutlet var postsLabel: UILabel!

    private var hostingController: UIHostingController<AudienceGenderChart>?

    func configure(with data: AudienceDemographic) {
        // A. Update the standard labels
        let followers =
            data.subscribersGained - data.subscribersLost

        followersLabel.text = followers.formattedCount()

        ageLabel.text =
            "\(data.topAgeGroup) years"

        // optional
        postsLabel.text = "-"

        // B. Embed the Chart
        setupChart(male: data.malePercentage, female: data.femalePercentage)

        let change =
            Double(data.subscribersGained -
                data.subscribersLost)

        if change >= 0 {
            followersChangeLabel.text =
                "+\(Int(change))%"
            followersChangeLabel.textColor =
                .systemGreen
        } else {
            followersChangeLabel.text =
                "\(Int(change))%"
            followersChangeLabel.textColor =
                .systemRed
        }

        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.applyLiquidGlassEffect()
        layer.cornerRadius = 12
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        chartContainer.backgroundColor = .clear
    }

    private func setupChart(
        male: Double,
        female: Double
    ) {
        let chartView = AudienceGenderChart(
            malePercentage: male,
            femalePercentage: female
        )

        if let existingController = hostingController {
            existingController.rootView = chartView
            existingController.view.backgroundColor = .clear
            existingController.view.isOpaque = false
        } else {
            let controller =
                UIHostingController(rootView: chartView)

            controller.view.backgroundColor = .clear
            controller.view.isOpaque = false

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

    private func parseMetric(_ value: String) -> Double {
        let clean = value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if clean.hasSuffix("k") {
            let number = clean.dropLast()
            return (Double(number) ?? 0) * 1000
        } else if clean.hasSuffix("m") {
            let number = clean.dropLast()
            return (Double(number) ?? 0) * 1_000_000
        }
        return Double(clean) ?? 0
    }
}
