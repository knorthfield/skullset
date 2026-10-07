import SwiftData
import SwiftUI

struct WorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(HealthStore.self) private var health
    @AppStorage("unit") private var unit: WeightUnit = .kg
    @AppStorage("restStartedAt") private var restStartedAt: Double = 0
    @AppStorage("plates.kg") private var kilogramPlates = ""
    @AppStorage("plates.lb") private var poundPlates = ""
    @Query(sort: \Workout.startedAt, order: .reverse) private var workouts: [Workout]
    @State private var isShowingSettings = false

    private var current: Workout? { workouts.first { $0.finishedAt == nil } }

    private var finished: [Workout] { workouts.filter { $0.finishedAt != nil } }

    private func plates(for unit: WeightUnit) -> [Double] {
        unit.selectedPlates(from: unit == .kg ? kilogramPlates : poundPlates)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let current {
                    List {
                        ForEach(current.orderedEntries) { entry in
                            Section {
                                LiftCard(
                                    entry: entry,
                                    unit: current.unit,
                                    plates: plates(for: current.unit),
                                    bodyweightKilograms: health.latestBodyweightKilograms,
                                    onSetLogged: { setLogged(in: current) }
                                )
                            }
                        }
                        Section {
                            Button("Finish Workout") { finish(current) }
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                                .disabled(!hasLoggedSets(current))
                        }
                    }
                    .navigationTitle("Workout \(current.day.rawValue)")
                } else {
                    Color.clear
                }
            }
            .safeAreaInset(edge: .bottom) {
                if restStartedAt > 0 {
                    RestTimerBar(startedAt: Date(timeIntervalSince1970: restStartedAt)) {
                        stopRestTimer()
                    }
                    .padding(.bottom, 8)
                }
            }
            .toolbar {
                Button("Settings", systemImage: "gearshape") { isShowingSettings = true }
            }
            .sheet(isPresented: $isShowingSettings) { SettingsView() }
        }
        .task {
            ensureCurrentWorkout()
            await health.refresh()
        }
        .onChange(of: unit) { replanUnstartedWorkout() }
        .onChange(of: kilogramPlates) { replanUnstartedWorkout() }
        .onChange(of: poundPlates) { replanUnstartedWorkout() }
    }

    private func hasLoggedSets(_ workout: Workout) -> Bool {
        workout.entries.contains { $0.reps.contains { $0 != nil } }
    }

    private func replanUnstartedWorkout() {
        guard let current, !hasLoggedSets(current) else { return }
        current.unit = unit
        for entry in current.entries {
            entry.weight = plannedWeight(for: entry.lift)
        }
        try? context.save()
    }

    /// There is always one unfinished workout, so the next session is ready to log.
    private func ensureCurrentWorkout() {
        guard current == nil else { return }
        let day = Progression.nextDay(after: finished.first?.day)
        let workout = Workout(day: day, unit: unit)
        context.insert(workout)
        for (order, lift) in day.lifts.enumerated() {
            workout.entries.append(LiftEntry(lift: lift, order: order, weight: plannedWeight(for: lift)))
        }
        try? context.save()
    }

    private func plannedWeight(for lift: Lift) -> Double {
        for workout in finished {
            if let entry = workout.entries.first(where: { $0.lift == lift }) {
                return Progression.nextWeight(
                    for: lift,
                    lastWeight: entry.weight,
                    lastReps: entry.reps,
                    lastUnit: workout.unit,
                    unit: unit,
                    plates: plates(for: unit)
                )
            }
        }
        return Progression.startingWeight(for: lift, unit: unit)
    }

    private func setLogged(in workout: Workout) {
        let loggedSets = workout.entries.flatMap(\.reps).compactMap { $0 }.count
        if loggedSets == 1 { workout.startedAt = .now }
        restStartedAt = Date.now.timeIntervalSince1970
        Task { await RestTimer.scheduleNotification() }
    }

    private func stopRestTimer() {
        restStartedAt = 0
        RestTimer.cancelNotification()
    }

    private func finish(_ workout: Workout) {
        workout.finishedAt = .now
        if let kilograms = health.latestBodyweightKilograms {
            workout.bodyweight = WeightUnit.kg.convert(kilograms, to: workout.unit)
        }
        try? context.save()
        stopRestTimer()
        let (startedAt, finishedAt, day) = (workout.startedAt, workout.finishedAt!, workout.day)
        Task { await health.save(startedAt: startedAt, finishedAt: finishedAt, day: day) }
        ensureCurrentWorkout()
        WorkoutReminder.schedule(for: Progression.nextDay(after: day), after: finishedAt)
    }
}
