import SwiftUI
import Charts

struct OptimalTimeChart: View {
    // 1. Accept Data
    var data: [AnalysisDateData]
    
    // 2. Accept the pre-calculated winners (No sorting needed here!)
    var topDays: Set<String>
    
    let purpleColor = UIColor(named: "AccentColor")
    
    // 3. Sort for Display (Chronological Mon -> Sun) stays here
    // We still need this because the Chart must display Mon-Sun, regardless of which is "Best"
    var chronologicalData: [AnalysisDateData] {
        let allDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dataMap = Dictionary(uniqueKeysWithValues: data.map { ($0.day, $0) })
        
        return allDays.map { day in
            dataMap[day] ?? AnalysisDateData(
                day: day,
                date: "",
                time: TimeData(hour: 0, minute: 0),
                audienceEngagementRate: "0.0"
            )
        }
    }

    var body: some View {
        VStack {
            Chart(chronologicalData) { item in
                BarMark(
                    x: .value("Day", String(item.day.prefix(3)).uppercased()),
                    y: .value("Engagement", Double(item.audienceEngagementRate) ?? 0.0),
                    width: .fixed(24)
                )
                .cornerRadius(4)
                .foregroundStyle(
                    // 4. Use the passed 'topDays' set directly
                    topDays.contains(item.day)
                    ? Color(uiColor: purpleColor ?? .white)
                    : Color.gray.opacity(0.5)
                )
            }
            .chartYScale(domain: .automatic)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(Color.gray)
                        .offset(y: 5)
                }
            }
            //.chartYAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0]) { _ in
                    AxisGridLine() // This draws the vertical line at 0
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
            .chartLegend(.hidden)
            .chartYScale(range: .plotDimension(padding: 5))
        }
        .padding(.horizontal, 10)
    }
}
