import SwiftUI

struct SettingsView: View {
    @AppStorage("unit") private var unit: WeightUnit = .kg
    @AppStorage("plates.kg") private var kilogramPlates = ""
    @AppStorage("plates.lb") private var poundPlates = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(HealthStore.self) private var health

    var body: some View {
        NavigationStack {
            Form {
                Picker("Units", selection: $unit) {
                    ForEach(WeightUnit.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                Section {
                    ForEach(unit.allPlates, id: \.self) { plate in
                        Toggle(unit.format(plate), isOn: isSelected(plate))
                            .disabled(selectedPlates == [plate])
                    }
                } header: {
                    Text("Plates")
                } footer: {
                    Text("Weights are rounded so they can be loaded with these plates.")
                }

                if health.isAvailable {
                    Section {
                        if health.hasRequestedAccess {
                            Text("To change access, open the Health app and go to Sharing › Apps › Skullset.")
                                .foregroundStyle(.secondary)
                        } else {
                            Button("Connect Apple Health") {
                                Task { await health.requestAuthorization() }
                            }
                        }
                    } header: {
                        Text("Apple Health")
                    } footer: {
                        Text("Skullset reads your bodyweight and saves your workouts.")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var storedPlates: Binding<String> {
        unit == .kg ? $kilogramPlates : $poundPlates
    }

    private var selectedPlates: [Double] {
        unit.selectedPlates(from: storedPlates.wrappedValue)
    }

    private func isSelected(_ plate: Double) -> Binding<Bool> {
        Binding {
            selectedPlates.contains(plate)
        } set: { isOn in
            let plates = isOn ? selectedPlates + [plate] : selectedPlates.filter { $0 != plate }
            storedPlates.wrappedValue = unit.storageString(for: plates)
        }
    }
}
