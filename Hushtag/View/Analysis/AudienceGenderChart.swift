// File: AudienceGenderChart.swift
import SwiftUI
import Charts

// 1. A simple model for the chart bars
struct GenderMetric: Identifiable {
    let id = UUID()
    let gender: String
    let value: Double
    let color: Color
}

// 2. The Chart View
struct AudienceGenderChart: View {
    var genderData: [String: String]
    
    // Convert API data to Chart data
    var chartData: [GenderMetric] {
        var metrics: [GenderMetric] = []
        
        let purpleColor = UIColor(named: "AccentColor")
        
        // Parse Male Data
        if let mStr = genderData["M"], let mVal = Double(mStr), let mColour = purpleColor?.withAlphaComponent(0.7) {
            metrics.append(GenderMetric(gender: "M", value: mVal, color: Color(uiColor: mColour)))
        }
        
        // Parse Female Data
        if let fStr = genderData["F"], let fVal = Double(fStr), let fColour = purpleColor?.withAlphaComponent(1.0) {
            metrics.append(GenderMetric(gender: "F", value: fVal, color: Color(uiColor: fColour)))
        }
        
        return metrics
    }
    
    var body: some View {
        // The actual Chart component
        Chart(chartData) { item in
            BarMark(
                x: .value("Percent", item.value),
                y: .value("Gender", item.gender),
                height: .fixed(35)
            )
            .foregroundStyle(item.color)
            .annotation(position: .bottom, alignment: .leading) {
                Text("\(String(format: "%.1f", item.value))%")
                    .font(.caption2)
                    .bold()
                    .offset(x: 20)
            }
            .cornerRadius(4)
        }
        .chartLegend(.hidden)
        
        .chartYScale(domain: .automatic, range: .plotDimension(padding: 10))
        
        
        .chartXAxis {
            AxisMarks(position: .bottom, values: [0]) { _ in
                AxisGridLine()
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray)
                    .offset(x: -20)
                    .offset(y: 27)
            }
        }
        .frame(height: 150)
        .padding(.leading, 25,)
        .padding(.bottom, 10)
    }
}
