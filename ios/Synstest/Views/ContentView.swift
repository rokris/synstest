import SwiftUI

struct ContentView: View {
    @State private var vm = SynsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Intro
                    introSection

                    // Settings section
                    settingsSection

                    // Monovision
                    MonovisionToggleView()

                    // Results table
                    ResultsTableView(
                        leftResults: vm.leftResults,
                        rightResults: vm.rightResults
                    )

                    // Charts
                    DefocusChartsView()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Synsanalyse")
            .navigationBarTitleDisplayMode(.large)
        }
        .environment(vm)
    }

    // MARK: - Intro section

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hva er dette?")
                .font(.subheadline.weight(.semibold))

            Text("Denne kalkulatoren simulerer hvordan øynene dine ser på ulike avstander etter refraktiv kirurgi (LASIK, PRK, SMILE). Juster startverdien, linseverdien og akkommodasjon for å se rest-defokus.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Monovision/Presbyond: En teknikk der ett øye korrigeres for avstand (dominant) og det andre for nærarbeid, nyttig for personer over 40–45 år.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 1)
        )
    }

    // MARK: - Settings section

    private var settingsSection: some View {
        @Bindable var vm = vm

        return VStack(alignment: .leading, spacing: 16) {
            Label("Innstillinger", systemImage: "gearshape")
                .font(.headline)

            // Eye cards — right eye first
            EyeCardView(
                title: "Høyre øye",
                icon: "eye.fill",
                tintColor: .green,
                r0: $vm.rightR0,
                lens: $vm.rightLens,
                isLensDisabled: vm.isRightNearEye,
                effectiveLens: vm.rightEye.lensCorrection
            )

            EyeCardView(
                title: "Venstre øye",
                icon: "eye.fill",
                tintColor: .red,
                r0: $vm.leftR0,
                lens: $vm.leftLens,
                isLensDisabled: vm.isLeftNearEye,
                effectiveLens: vm.leftEye.lensCorrection
            )

            // Accommodation slider (shared)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Akkommodasjon (A)")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(vm.accommodation.diopterString)
                        .font(.subheadline.monospacedDigit())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(.fill.tertiary, in: Capsule())
                }
                Slider(value: $vm.accommodation, in: 0...12, step: 0.25)

                Text("Øyets evne til å fokusere på nært hold (reduseres med alderen: ~8 D ved 30 år, ~1 D ved 60 år)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ContentView()
}
