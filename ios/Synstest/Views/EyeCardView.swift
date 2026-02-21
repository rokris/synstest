import SwiftUI

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
                    Text("Startverdi (R0)")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(r0.diopterString)
                        .font(.subheadline.monospacedDigit())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(.fill.tertiary, in: Capsule())
                }
                Slider(value: $r0, in: -6...6, step: 0.25)

                Text("Øyets naturlige brillestyrke før korreksjon")
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

                    Text("Beregnes automatisk for nærøye ved Monovision")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    Slider(value: $lens, in: -8...8, step: 0.25)

                    Text("Hvor mye styrke laseren/linsen korrigerer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}
