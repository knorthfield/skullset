import SwiftUI

struct LiftCard: View {
    @Bindable var entry: LiftEntry
    let unit: WeightUnit
    let bodyweightKilograms: Double?
    let onSetLogged: () -> Void
    @State private var isEditingWeight = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.lift.name).font(.headline)
                    Text("\(entry.lift.setCount)×\(Lift.repsPerSet)+")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(weightLabel) { isEditingWeight = true }
                    .buttonStyle(.bordered)
                    .font(.headline)
                    .monospacedDigit()
            }

            if let detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                ForEach(entry.reps.indices, id: \.self) { index in
                    SetButton(reps: repsBinding(at: index), isAMRAP: index == entry.reps.count - 1)
                }
            }
        }
        .padding(.vertical, 6)
        .sheet(isPresented: $isEditingWeight) {
            WeightEditor(weight: $entry.weight, lift: entry.lift, unit: unit)
                .presentationDetents([.height(260)])
        }
    }

    private var weightLabel: String {
        entry.lift.isBodyweight && entry.weight == 0 ? "Bodyweight" : unit.format(entry.weight)
    }

    private var detail: String? {
        if entry.lift.isBodyweight {
            guard let bodyweightKilograms else { return nil }
            let bodyweight = unit.roundToLoadable(WeightUnit.kg.convert(bodyweightKilograms, to: unit))
            return "Bodyweight \(unit.format(bodyweight)) + \(unit.format(entry.weight))"
        }
        let plates = PlateCalculator.platesPerSide(for: entry.weight, unit: unit)
        let platesText = plates.isEmpty
            ? "Empty bar"
            : plates.map { $0.formatted(.number.precision(.fractionLength(0...2))) }.joined(separator: " + ")
        return "Each side: \(platesText)"
    }

    private func repsBinding(at index: Int) -> Binding<Int?> {
        Binding {
            entry.reps[index]
        } set: { newValue in
            entry.reps[index] = newValue
            if newValue != nil { onSetLogged() }
        }
    }
}

private struct WeightEditor: View {
    @Binding var weight: Double
    let lift: Lift
    let unit: WeightUnit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(unit.format(weight))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: weight))
                HStack(spacing: 32) {
                    stepButton("minus", by: -step)
                        .disabled(weight - step < minimum)
                    stepButton("plus", by: step)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(lift.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var step: Double { unit.increment(for: lift) }

    private var minimum: Double { Progression.startingWeight(for: lift, unit: unit) }

    private func stepButton(_ systemImage: String, by amount: Double) -> some View {
        Button {
            withAnimation { weight += amount }
        } label: {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .frame(width: 64, height: 64)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .buttonRepeatBehavior(.enabled)
    }
}
