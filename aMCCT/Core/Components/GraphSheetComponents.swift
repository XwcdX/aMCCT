import Charts
import SwiftUI

enum GraphChartStyle {
    case line
    case bar
    case area
}

struct GraphSheetHeaderView: View {
    var body: some View {
        Text("Brain level progress")
            .font(.title2.weight(.bold))
            .foregroundStyle(.baseBlacktoWhite)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GraphSummaryView: View {
    let average: Double
    let periodLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Average")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.baseBlacktoWhite.opacity(0.65))

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(Int(average.rounded()))")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundStyle(.baseBlacktoWhite)

                Text("/ 100")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.baseBlacktoWhite.opacity(0.5))
            }

            Text(periodLabel)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.baseBlacktoWhite.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.baseBlacktoWhite.opacity(0.10))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

struct GraphRangeSelectorView: View {
    @Binding var selection: GraphSheetRange

    var body: some View {
        SegmentedControl(
            selection: $selection,
            accessibilityLabel: "Graph range",
            GraphSheetRange.day,
            GraphSheetRange.week,
            GraphSheetRange.month,
            GraphSheetRange.year
        )
    }
}

struct GraphChartSectionView: View {
    let points: [GraphSheetPoint]
    let selectedRange: GraphSheetRange
    let currentAverage: Double
    let title: String
    let subtitle: String
    let yAxisLabel: String
    let yValueLabel: String
    let yDomain: ClosedRange<Double>
    let lineColors: [Color]
    let chartStyle: GraphChartStyle
    let showWeeklyAverageLine: Bool
    let weeklyAverageLabel: String
    let onPointSelected: (GraphSheetPoint?) -> Void

    private var yAxisTicks: [Double] {
        let minY = yDomain.lowerBound
        let maxY = yDomain.upperBound
        guard maxY > minY else { return [minY] }

        let step = (maxY - minY) / 4
        return [0, 1, 2, 3, 4].map { minY + (Double($0) * step) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.baseBlacktoWhite)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.baseBlacktoWhite.opacity(0.72))
            }

            if points.isEmpty {
                emptyState
            } else {
                chart
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.baseBlacktoWhite.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }

    private var chart: some View {
        Chart {
            ForEach(points) { point in
                if chartStyle == .line {
                    LineMark(
                        x: .value("Index", point.index),
                        y: .value(yValueLabel, point.level)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(
                        LinearGradient(
                            colors: lineColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                } else if chartStyle == .bar {
                    BarMark(
                        x: .value("Index", point.index),
                        y: .value(yValueLabel, point.level)
                    )
                    .cornerRadius(4)
                    .foregroundStyle(
                        LinearGradient(
                            colors: lineColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                } else {
                    AreaMark(
                        x: .value("Index", point.index),
                        y: .value(yValueLabel, point.level)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [lineColors.first?.opacity(0.45) ?? .orange.opacity(0.45), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }

                PointMark(
                    x: .value("Index", point.index),
                    y: .value(yValueLabel, point.level)
                )
                .symbolSize(chartStyle == .line ? 72 : (chartStyle == .bar ? 0 : 64))
                .foregroundStyle(chartStyle == .line ? Color.white : (lineColors.first ?? .orange))
                .opacity(chartStyle == .bar ? 0 : 1)
            }

            if showWeeklyAverageLine, selectedRange == .week {
                RuleMark(y: .value(weeklyAverageLabel, currentAverage))
                    .foregroundStyle(Color.gray.opacity(0.55))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
            }
        }
        .chartYScale(domain: yDomain)
        .chartXAxisLabel(selectedRange == .day ? "Hour" : "Date")
        .chartYAxisLabel(yAxisLabel)
        .chartXAxis {
            AxisMarks(values: points.map(\.index)) { value in
                AxisGridLine().foregroundStyle(.clear)
                AxisTick().foregroundStyle(.white.opacity(0.25))
                AxisValueLabel {
                    if let index = value.as(Int.self), let label = points.first(where: { $0.index == index })?.label {
                        Text(label)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.baseBlacktoWhite.opacity(0.72))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: yAxisTicks) { value in
                AxisGridLine().foregroundStyle(.white.opacity(0.08))
                AxisTick().foregroundStyle(.white.opacity(0.25))
                AxisValueLabel {
                    if let numberValue = value.as(Double.self) {
                        Text("\(Int(numberValue.rounded()))")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.baseBlacktoWhite.opacity(0.72))
                    }
                }
            }
        }
        .chartOverlay { proxy in
            chartSelectionLayer(proxy: proxy)
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.black.opacity(0.10))
                .cornerRadius(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(.baseBlacktoWhite.opacity(0.65))

            Text("No chart data")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.baseBlacktoWhite)

            Text("Ready for injected data.")
                .font(.caption)
                .foregroundStyle(.baseBlacktoWhite.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func chartSelectionLayer(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            guard let plotAreaFrame = proxy.plotFrame else { return }
                            let plotFrame = geometry[plotAreaFrame]
                            let xPosition = gesture.location.x - plotFrame.origin.x
                            guard xPosition >= 0, xPosition <= plotFrame.width else { return }
                            guard let index = proxy.value(atX: xPosition, as: Int.self) else { return }
                            onPointSelected(points.first { $0.index == index })
                        }
                )
        }
    }
}

struct GraphWeeklyAverageLegendView: View {
    let average: Double

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Average over last 7 days")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.baseBlacktoWhite.opacity(0.55))

                Text("\(Int(average.rounded()))")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.baseBlacktoWhite)
            }

            Spacer()

            Capsule()
                .fill(Color.gray.opacity(0.55))
                .frame(width: 72, height: 3)
        }
        .padding(.horizontal, 4)
    }
}

struct GraphSelectedPointView: View {
    let selectedPoint: GraphSheetPoint?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected point")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.baseBlacktoWhite.opacity(0.55))

            if let selectedPoint {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedPoint.detail)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.baseBlacktoWhite)

                        Text("Value updates when you tap a point")
                            .font(.caption)
                            .foregroundStyle(.baseBlacktoWhite.opacity(0.55))
                    }

                    Spacer()

                    Text("\(Int(selectedPoint.level.rounded()))")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.baseBlacktoWhite)
                }
            } else {
                Text("Tap a point on the chart to see the exact value for that hour, day, month, or year.")
                    .font(.subheadline)
                    .foregroundStyle(.baseBlacktoWhite.opacity(0.65))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.baseBlacktoWhite.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

struct GraphAboutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About aMCC")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.baseBlacktoWhite)

            Text("The anterior mid-cingulate cortex (aMCC) is the brain’s hub for willpower, perseverance, and disciplined action. It strengthens through repeated exposure to meaningful challenge, especially tasks that feel uncomfortable and effortful, while avoidance may weaken it.")
                .font(.subheadline)
                .foregroundStyle(.baseBlacktoWhite.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)

            Text("By helping evaluate effort, manage discomfort, and override short-term temptations, the aMCC supports long-term, goal-directed behavior. In essence, consistently choosing difficulty over comfort builds the neurological foundation for resilience and grit.")
                .font(.subheadline)
                .foregroundStyle(.baseBlacktoWhite.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.baseBlacktoWhite.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}

struct GraphCulpritAppsView: View {
    let apps: [CulpritApp]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Application Culprits")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.baseBlacktoWhite)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(apps) { app in
                        VStack(spacing: 8) {
                            Circle()
                                .fill(Color.baseBlacktoWhite.opacity(0.10))
                                .frame(width: 52, height: 52)
                                .overlay {
                                    Image(systemName: app.symbolName)
                                        .font(.system(size: 19, weight: .semibold))
                                        .foregroundStyle(.baseBlacktoWhite)
                                }

                            Text(app.name)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.baseBlacktoWhite.opacity(0.78))
                                .lineLimit(1)
                        }
                        .frame(width: 72)
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.baseBlacktoWhite.opacity(0.08))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
}
