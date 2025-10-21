//
//  ChartView.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import SwiftUI
import Charts

/// Custom chart view for visualizing water intake history
struct WaterIntakeChartView: View {
    let data: [(date: Date, amount: Double)]
    let goalLine: Double
    let period: HistoryPeriod

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Water Intake")
                .font(.headline)

            Chart {
                // Goal line
                RuleMark(y: .value("Goal", goalLine))
                    .foregroundStyle(Color.green.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Goal")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }

                // Water intake bars
                ForEach(data, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.8),
                                Color.cyan.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("\(Int(amount / 1000))L")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .font(.caption2)
                }
            }
            .frame(height: 250)
        }
        .padding()
        .cardStyle()
    }

    // MARK: - X-Axis Configuration

    private var xAxisStride: Int {
        switch period {
        case .week:
            return 1
        case .month:
            return 5
        case .threeMonths:
            return 15
        }
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let sampleData = (0..<7).map { day in
        let date = calendar.date(byAdding: .day, value: -day, to: Date())!
        let amount = Double.random(in: 1500...2500)
        return (date: date, amount: amount)
    }

    return WaterIntakeChartView(
        data: sampleData,
        goalLine: 2000,
        period: .week
    )
    .padding()
}
