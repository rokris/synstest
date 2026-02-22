import SwiftUI

private struct SliderTickMarks: View {
    private let ticks: [Int] = [-8, -6, -4, -2, 0, 2, 4, 6, 8]

    var body: some View {
        VStack(spacing: 0) {
            // Horizontal rule with vertical tick lines
            GeometryReader { geo in
                // Match the slider's internal thumb inset
                let inset: CGFloat = 11
                let usable = geo.size.width - inset * 2
                // Total steps from -8 to +8 in steps of 0.5 = 32
                let totalSteps = 32
                let bottomY: CGFloat = geo.size.height

                Path { path in
                    // Horizontal line
                    path.move(to: CGPoint(x: inset, y: bottomY))
                    path.addLine(to: CGPoint(x: inset + usable, y: bottomY))

                    // Vertical ticks for every 0.5 from -8 to +8
                    for i in 0...totalSteps {
                        let value = -8.0 + Double(i) * 0.5
                        let x = inset + usable * CGFloat(i) / CGFloat(totalSteps)
                        let tickHeight: CGFloat
                        if value.truncatingRemainder(dividingBy: 2) == 0 {
                            // Labeled ticks (even integers): tallest
                            tickHeight = 10
                        } else if value.truncatingRemainder(dividingBy: 1) == 0 {
                            // Odd integers: medium
                            tickHeight = 6
                        } else {
                            // Half steps (0.5): shortest
                            tickHeight = 3
                        }
                        path.move(to: CGPoint(x: x, y: bottomY))
                        path.addLine(to: CGPoint(x: x, y: bottomY - tickHeight))
                    }
                }
                .stroke(Color.secondary.opacity(0.5), lineWidth: 0.5)
            }
            .frame(height: 11)

            // Labels
            HStack {
                ForEach(ticks, id: \.self) { value in
                    Text(value > 0 ? "+\(value)" : "\(value)")
                        .font(.system(size: 9, weight: value == 0 ? .semibold : .regular).monospacedDigit())
                        .foregroundStyle(value == 0 ? .primary : .secondary)
                    if value != ticks.last {
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 7)
    }
}

struct EyeCardView: View {
    let title: String
    let icon: String
    let tintColor: Color

    @Binding var r0: Double
    @Binding var lens: Double
    let isLensDisabled: Bool
    let effectiveLens: Double  // actual lens value (may be auto-calculated)

    @Environment(SynsViewModel.self) private var vm

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(tintColor)

            // R0 slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Brillestyrke (R0)")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(r0.diopterString)
                        .font(.subheadline.monospacedDigit())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(.fill.tertiary, in: Capsule())
                }
                Slider(value: $r0, in: -8...8, step: 0.25)
                SliderTickMarks()

                Text("Øyets naturlige brillestyrke (+ = langsynthet, − = nærsynt)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Lens slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Linseverdi (Korreksjon)")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(effectiveLens.diopterString)
                        .font(.subheadline.monospacedDigit())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(.fill.tertiary, in: Capsule())
                }

                if isLensDisabled {
                    Slider(value: .constant(effectiveLens), in: -8...8, step: 0.25)
                        .disabled(true)
                        .tint(.secondary)
                    SliderTickMarks()

                    Text("Beregnes automatisk for nærøye ved Monovision")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Slider(value: $lens, in: -8...8, step: 0.25)
                    SliderTickMarks()

                    Text("Korreksjon via kirurgi/linser")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(tintColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(tintColor.opacity(0.2), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 3)
                .foregroundStyle(tintColor)
        }
    }
}
