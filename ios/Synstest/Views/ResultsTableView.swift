import SwiftUI

struct ResultsTableView: View {
    let leftResults: [DistanceResult]
    let rightResults: [DistanceResult]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Resultater", systemImage: "tablecells")
                .font(.headline)

            // Table header
            HStack(spacing: 0) {
                headerCell("Øye", width: .flexible)
                headerCell("Residual", width: .flexible)
                headerCell("Avstand", width: .flexible)
                headerCell("Krav (1/d)", width: .flexible)
                headerCell("Rest-defokus", width: .flexible)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Right eye rows
            ForEach(Array(rightResults.enumerated()), id: \.offset) { index, result in
                resultRow(
                    eye: "Høyre",
                    showResidual: index == 0,
                    result: result
                )
            }

            Divider()

            // Left eye rows
            ForEach(Array(leftResults.enumerated()), id: \.offset) { index, result in
                resultRow(
                    eye: "Venstre",
                    showResidual: index == 0,
                    result: result
                )
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    // MARK: - Subviews

    private func headerCell(_ text: String, width: Flexibility) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func resultRow(eye: String, showResidual: Bool, result: DistanceResult) -> some View {
        let eyeColor: Color = eye == "Høyre" ? .green : .red

        return HStack(spacing: 0) {
            Text(eye)
                .font(.caption.weight(.semibold))
                .foregroundStyle(eyeColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(showResidual ? result.residual.diopterString : "")
                .font(.caption.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result.distance.name)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result.demand.diopterString)
                .font(.caption.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result.restDefocus.diopterString)
                .font(.callout.weight(.bold).monospacedDigit())
                .foregroundStyle(abs(result.restDefocus) < 0.5 ? .green : .red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    private enum Flexibility {
        case flexible
    }
}
