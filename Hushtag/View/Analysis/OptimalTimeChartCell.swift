import UIKit
import SwiftUI

class OptimalTimeChartCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chartContainer: UIView!
    private var hostingController: UIHostingController<OptimalTimeChart>?

    func configure(with activity: [ViewerActivity]) {

        guard !activity.isEmpty else {
            titleLabel.text = "Best time : N/A"
            setupChart(activity: [])
            return
        }

        let calendar = Calendar.current

        // Aggregate views by weekday
        var weekdayViews: [Int: Int] = [:]

        for item in activity {
            let weekday = calendar.component(.weekday, from: item.day)
            weekdayViews[weekday, default: 0] += item.views
        }

        // Convert to array
        let orderedWeekdays = [1, 2, 3, 4, 5, 6, 7]

        let weekdayData = orderedWeekdays.map { weekday -> (day: String, views: Int) in

            let name =
            calendar.shortWeekdaySymbols[weekday - 1]

            let views = weekdayViews[weekday] ?? 0

            return (name, views)
        }

        // Find best 2 days
        let bestDays = weekdayData
            .sorted { $0.views > $1.views }
            .prefix(2)
            .map { $0.day }

        titleLabel.text = "Best time : " + bestDays.joined(separator: ", ")

        setupChart(activity: activity)

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
        activity: [ViewerActivity]
    ) {

        let chartView = OptimalTimeChart(
            data: activity
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
