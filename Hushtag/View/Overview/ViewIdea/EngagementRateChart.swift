////
////  EngagementRateChart.swift
////  Hushtag
////
////  Created by SDC-USER on 07/01/26.
////
//
//import SwiftUI
//import Charts
//
//struct EngagementLineChart: View {
//
//    let data: [Video]
//
//    var averagedPoints: [(date: Date, rate: Double)] {
//        let calendar = Calendar.current
//
//        // 1. Flatten all engagement points
//        let allPoints = data.flatMap { $0.engagementRate ?? [] }
//
//        // 2. Group by day
//        let grouped = Dictionary(grouping: allPoints) {
//            calendar.startOfDay(for: $0.date)
//        }
//
//        // 3. Average per day
//        return grouped.map { (date, points) in
//            let avg = points.map(\.rate).reduce(0, +) / Double(points.count)
//            return (date: date, rate: avg)
//        }
//        .sorted { $0.date < $1.date }
//    }
//
//    var body: some View {
//        Chart {
//            ForEach(averagedPoints, id: \.date) { point in
//                LineMark(
//                    x: .value("Date", point.date),
//                    y: .value("Avg Engagement Rate", point.rate)
//                )
//                .interpolationMethod(.catmullRom)
//
//                PointMark(
//                    x: .value("Date", point.date),
//                    y: .value("Avg Engagement Rate", point.rate)
//                )
//            }
//        }
//        .chartYScale(domain: .automatic)
//        .chartXAxis {
//            AxisMarks(values: .stride(by: .day)) {
//                AxisGridLine()
//                AxisTick()
//                AxisValueLabel(format: .dateTime.day().month())
//            }
//        }
//        .chartLegend(.hidden)
//        .frame(width: 369, height: 140)
//        .chartPlotStyle { plotArea in
//            plotArea
//                .padding(.horizontal, 0)
//                .padding(.vertical, 0)
//        }
//        .offset(y: -37)
//        .chartXAxisLabel("Past Week", position: .bottom, spacing: 0)
//        .chartYAxisLabel("Avg Engagement Rate", position: .trailing, spacing: 0)
//
//
//    }
//    
//}
