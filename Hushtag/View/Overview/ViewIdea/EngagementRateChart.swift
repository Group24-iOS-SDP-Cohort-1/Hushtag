import SwiftUI
import Charts

struct EngagementBarChart: View {
    
    let data: [Video]
    @State private var selected: (index: Int, title: String, rate: Double)?
    @State private var tooltipPosition: CGPoint = .zero
    // Calculate engagement rate for each video
    var engagementRates: [(index: Int, title: String, rate: Double)] {
        
        data.enumerated().map { i, video in
            let likes = Double(video.likes)
            let comments = Double(video.comments)
            let views = Double(video.views)
            
            let rate = views > 0
            ? ((likes + 2 * comments) / views)
            : 0
            
            return (index: i, title: video.title, rate: rate)
        }
    }
    
    var body: some View {
        ZStack {
            
            Chart {
                ForEach(engagementRates, id: \.index) { item in
                    
                    BarMark(
                        x: .value("Video", item.index),
                        y: .value("Engagement Rate (%)", item.rate),
                        width: .fixed(15)
                    )
                    .cornerRadius(6)
                }
            }
            
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let title = value.as(String.self) {
                            Text(title.prefix(6) + "…") // short labels
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    guard let plotFrame = proxy.plotFrame else { return }
                                    
                                    let origin = geo[plotFrame].origin
                                    let xPos = value.location.x - origin.x
                                    
                                    if let index: Int = proxy.value(atX: xPos),
                                       let match = engagementRates.first(where: { $0.index == index }) {
                                        selected = match
                                    }
                                }
                                .onEnded { _ in
                                    selected = nil
                                }
                        )
                }
            }
            .frame(width: 369, height: 200)
            .chartLegend(.hidden)
            .chartXAxisLabel("Videos", position: .bottom, spacing: 0)
            .chartYAxisLabel("Engagement Rate", position: .trailing, spacing: 0)
            .chartXScale(range: .plotDimension(padding: 10))
        }
    }
}
