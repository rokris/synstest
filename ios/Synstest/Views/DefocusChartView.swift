import SwiftUI
import Charts

// MARK: - Chart data point

struct DefocusDataPoint: Identifiable {
    let id = UUID()
    let distanceName: String
    let distanceIndex: Int  // 0 = Far, 1 = Mid, 2 = Near
    let restDefocus: Double
}

// MARK: - Single eye chart

struct DefocusChartView: View {
    let title: String
    let color: Color
    let results: [DistanceResult]
    let dofRange: Double

    private var dataPoints: [DefocusDataPoint] {
        let count = results.count
        return results.enumerated().map { index, result in
            DefocusDataPoint(
                distanceName: result.distance.name,
                distanceIndex: count - 1 - index,
                restDefocus: result.restDefocus
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "eye.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)

            Chart {
                // DOF zone (depth of field)
                RectangleMark(
                    xStart: .value("DOF Start", -dofRange),
                    xEnd: .value("DOF End", dofRange),
                    yStart: .value("Y Start", -0.5),
                    yEnd: .value("Y End", Double(ViewingDistance.all.count - 1) + 0.5)
                )
                .foregroundStyle(.blue.opacity(0.1))

                // DOF boundary lines
                RuleMark(x: .value("DOF Left", -dofRange))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.blue.opacity(0.3))

                RuleMark(x: .value("DOF Right", dofRange))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.blue.opacity(0.3))

                // Zero line
                RuleMark(x: .value("Zero", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .foregroundStyle(.secondary.opacity(0.5))

                // Data line
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(color)
                    .symbolSize(60)

                    // Distance name annotation (leading side)
                    PointMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .leading, spacing: 6) {
                        Text(point.distanceName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    // Value annotation (trailing side)
                    PointMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .trailing, spacing: 6) {
                        Text(point.restDefocus.diopterString)
                            .font(.caption2.monospacedDigit().weight(.semibold))
                            .foregroundStyle(abs(point.restDefocus) < 0.5 ? .green : .red)
                    }
                }
            }
            .chartXScale(domain: -6...6)
            .chartYScale(domain: -0.5...2.5)
            .chartXAxis {
                AxisMarks(values: stride(from: -6.0, through: 6.0, by: 2.0).map { $0 }) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(v > 0 ? "+\(Int(v))" : "\(Int(v))")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 200)
            .padding(8)
            .background(.background, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
    }
}

// MARK: - Combined charts view

struct DefocusChartsView: View {
    @Environment(SynsViewModel.self) private var vm

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Visuell fremstilling av rest-defokus", systemImage: "chart.xyaxis.line")
                .font(.headline)

            // Chart legend
            chartLegend

            // Charts — full width, right eye first
            DefocusChartView(
                title: "Høyre øye",
                color: .green,
                results: vm.rightResults,
                dofRange: vm.dofRange
            )

            DefocusChartView(
                title: "Venstre øye",
                color: .red,
                results: vm.leftResults,
                dofRange: vm.dofRange
            )
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    private var chartLegend: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "square.fill")
                    .foregroundStyle(.blue.opacity(0.15))
                    .font(.caption2)
                Text("DOF (Depth of Field): ±\(vm.dofRange, specifier: "%.2f") D")
                    .font(.caption)
            }

            Text("Verdier nær 0 D = skarpt syn. Myopi (−) / Plano (0) / Hyperopi (+)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
    }
}
