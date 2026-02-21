import SwiftUI

struct MonovisionToggleView: View {
    @Environment(SynsViewModel.self) private var vm

    var body: some View {
        @Bindable var vm = vm

        VStack(alignment: .leading, spacing: 12) {
            Label("Monovision / Presbyond", systemImage: "eye.trianglebadge.exclamationmark")
                .font(.headline)

            Toggle("Aktiver Monovision / Presbyond", isOn: $vm.isMonovision)

            if vm.isMonovision {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dominant øye")
                            .font(.subheadline.weight(.medium))
                        Picker("Dominant øye", selection: $vm.dominantEye) {
                            ForEach(DominantEye.allCases) { eye in
                                Text(eye.displayName).tag(eye)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mål residual nærøye")
                            .font(.subheadline.weight(.medium))

                        HStack {
                            Stepper(
                                value: $vm.nearTarget,
                                in: -4...0,
                                step: 0.25
                            ) {
                                Text(vm.nearTarget.diopterString)
                                    .font(.subheadline.monospacedDigit())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 3)
                                    .background(.fill.tertiary, in: Capsule())
                            }
                        }
                    }
                }

                // Info badge
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Dominant øye (\(vm.dominantLabel)) kan justeres fritt. Nærøye (\(vm.nearEyeLabel)) beregnes automatisk til \(vm.nearTarget.diopterString).")
                        .font(.caption)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))

                // Eye summary pill
                HStack {
                    Text("Venstre: \(vm.leftEye.residual.diopterString) \(vm.isLeftNearEye ? "(nærøye)" : "(dominant)")")
                        .foregroundStyle(.red)
                    Text("·")
                    Text("Høyre: \(vm.rightEye.residual.diopterString) \(vm.isRightNearEye ? "(nærøye)" : "(dominant)")")
                        .foregroundStyle(.green)
                }
                .font(.caption.monospacedDigit())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.fill.tertiary, in: Capsule())
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
