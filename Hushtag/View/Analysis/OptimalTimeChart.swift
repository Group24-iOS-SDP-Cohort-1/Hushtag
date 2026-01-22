import SwiftUI
import Charts

struct OptimalTimeChart: View {

    // Data
    let data: [AnalysisDateData]

    // Highlighted best dates
    let topDates: Set<Date>

    let purpleColor = UIColor(named: "AccentColor")

    // Sort data chronologically by weekday (Mon → Sun)
    var chronologicalData: [AnalysisDateData] {
        data.sorted {
            Calendar.current.component(.weekday, from: $0.date) <
            Calendar.current.component(.weekday, from: $1.date)
        }
    }

    var body: some View {
        VStack {
            Chart(chronologicalData) { item in
                BarMark(
                    x: .value(
                        "Day",
                        item.date.formatted(.dateTime.weekday(.abbreviated)).uppercased()
                    ),
                    y: .value(
                        "Engagement",
                        Double(item.audienceEngagementRate) ?? 0
                    ),
                    width: .fixed(24)
                )
                .cornerRadius(4)
                .foregroundStyle(
                    topDates.contains(item.date)
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
