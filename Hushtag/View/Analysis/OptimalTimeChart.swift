import SwiftUI
import Charts

struct OptimalTimeChart: View {

    let data: [ViewerActivity]

    let purpleColor = UIColor(named: "AccentColor")

    // Use local timezone
    var calendar: Calendar {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }

    // Aggregate views by weekday
    var weekdayViews: [(day: String, views: Int)] {

        var map: [Int: Int] = [:]

        for item in data {
            let weekday = calendar.component(.weekday, from: item.day)
            map[weekday, default: 0] += item.views
        }

        let orderedWeekdays = [1,2,3,4,5,6,7]

        return orderedWeekdays.map { weekday in

            let views = map[weekday] ?? 0

            let name =
            calendar.shortWeekdaySymbols[weekday - 1].uppercased()

            return (name, views)
        }
    }

    // Determine best 2 days
    var bestDays: Set<String> {

        let sorted = weekdayViews.sorted { $0.views > $1.views }

        return Set(sorted.prefix(2).map { $0.day })
    }

    var body: some View {

        VStack {

            Chart(weekdayViews, id: \.day) { item in

                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Views", item.views),
                    width: .fixed(24)
                )
                .cornerRadius(4)
                .foregroundStyle(
                    bestDays.contains(item.day)
                    ? Color(uiColor: purpleColor ?? .white)
                    : Color.gray.opacity(0.5)
                )
            }

            .chartYAxis {
                AxisMarks(position: .leading, values: [0]) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }

            .chartXAxis {
                AxisMarks(position: .bottom) {
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }

            .chartLegend(.hidden)

            .chartYScale(range: .plotDimension(padding: 5))
        }
        .padding(.horizontal, 10)
    }
}
