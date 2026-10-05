import SwiftData
import SwiftUI

struct WorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(HealthStore.self) private var health
    @AppStorage("unit") private var unit: WeightUnit = .kg
    @AppStorage("restStartedAt") private var restStartedAt: Double = 0
    @Query(sort: \Workout.startedAt, order: .reverse) private var workouts: [Workout]
    @State private var isShowingSettings = false

    private var current: Workout? { workouts.first { $0.finishedAt == nil } }

    private var finished: [Workout] { workouts.filter { $0.finishedAt != nil } }

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
            await health.requestAuthorization()
            await RestTimer.requestPermission()
        }
        .onChange(of: unit) {
            if let current, !hasLoggedSets(current) {
                context.delete(current)
                try? context.save()
            }
            ensureCurrentWorkout()
        }
    }

    private func hasLoggedSets(_ workout: Workout) -> Bool {
        workout.entries.contains { $0.reps.contains { $0 != nil } }
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
                    unit: unit
                )
            }
        }
        return Progression.startingWeight(for: lift, unit: unit)
    }

    private func setLogged(in workout: Workout) {
        let loggedSets = workout.entries.flatMap(\.reps).compactMap { $0 }.count
        if loggedSets == 1 { workout.startedAt = .now }
        restStartedAt = Date.now.timeIntervalSince1970
        RestTimer.scheduleNotification()
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
    }
}
