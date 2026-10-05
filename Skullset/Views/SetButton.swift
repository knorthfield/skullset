import SwiftUI

/// Stronglifts-style set circle. Tap to log 5 reps, tap again to count down, then clear.
/// The AMRAP set opens a picker so more than 5 reps can be logged.
struct SetButton: View {
    @Binding var reps: Int?
    let isAMRAP: Bool
    @State private var isPickingReps = false

    var body: some View {
        Button(action: tap) {
            Text(label)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .frame(width: 56, height: 56)
                .foregroundStyle(foreground)
                .background(background, in: .circle)
                .overlay { Circle().strokeBorder(.secondary.opacity(reps == nil ? 0.4 : 0), lineWidth: 2) }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact, trigger: reps)
        .sheet(isPresented: $isPickingReps) {
            RepsPicker(reps: $reps)
                .presentationDetents([.height(320)])
        }
    }

    private var label: String {
        if let reps { return "\(reps)" }
        return isAMRAP ? "\(Lift.repsPerSet)+" : "\(Lift.repsPerSet)"
    }

    private var foreground: Color {
        reps == nil ? .secondary : .white
    }

    private var background: Color {
        guard let reps else { return .clear }
        return reps >= Lift.repsPerSet ? .accentColor : .red
    }

    private func tap() {
        if isAMRAP {
            isPickingReps = true
        } else if let current = reps {
            reps = current > 0 ? current - 1 : nil
        } else {
            reps = Lift.repsPerSet
        }
    }
}

private struct RepsPicker: View {
    @Binding var reps: Int?
    @State private var selection: Int
    @Environment(\.dismiss) private var dismiss

    init(reps: Binding<Int?>) {
        _reps = reps
        _selection = State(initialValue: reps.wrappedValue ?? Lift.repsPerSet)
    }

    var body: some View {
        NavigationStack {
            Picker("Reps", selection: $selection) {
                ForEach(0...30, id: \.self) { Text("\($0) reps").tag($0) }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Last set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        reps = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        reps = selection
                        dismiss()
                    }
                }
            }
        }
    }
}
