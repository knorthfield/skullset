import Foundation
import HealthKit
import Observation

struct BodyweightSample: Identifiable {
    let date: Date
    let kilograms: Double
    var id: Date { date }
}

/// Reads bodyweight from and saves workouts to Apple Health. Every call fails quietly,
/// so the app works the same when Health is not available or permission is refused.
@MainActor
@Observable
final class HealthStore {
    private let store = HKHealthStore()
    private let bodyMass = HKQuantityType(.bodyMass)

    private(set) var latestBodyweightKilograms: Double?

    private var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async {
        guard isAvailable else { return }
        try? await store.requestAuthorization(toShare: [.workoutType()], read: [bodyMass])
        latestBodyweightKilograms = await bodyweightSamples(limit: 1).first?.kilograms
    }

    /// Newest first.
    func bodyweightSamples(limit: Int = HKObjectQueryNoLimit) async -> [BodyweightSample] {
        guard isAvailable else { return [] }
        let query = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: bodyMass)],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: limit
        )
        let samples = (try? await query.result(for: store)) ?? []
        return samples.map {
            BodyweightSample(date: $0.endDate, kilograms: $0.quantity.doubleValue(for: .gramUnit(with: .kilo)))
        }
    }

    func save(startedAt: Date, finishedAt: Date, day: WorkoutDay) async {
        guard isAvailable else { return }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        do {
            try await builder.beginCollection(at: startedAt)
            try await builder.addMetadata(["Skullset Workout": "Workout \(day.rawValue)"])
            try await builder.endCollection(at: finishedAt)
            _ = try await builder.finishWorkout()
        } catch {
            builder.discardWorkout()
        }
    }
}
