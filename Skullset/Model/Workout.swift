import Foundation
import SwiftData

@Model
final class Workout {
    var startedAt: Date
    var finishedAt: Date?
    var day: WorkoutDay
    var unit: WeightUnit
    var bodyweight: Double?
    @Relationship(deleteRule: .cascade, inverse: \LiftEntry.workout)
    var entries: [LiftEntry] = []

    init(startedAt: Date = .now, day: WorkoutDay, unit: WeightUnit) {
        self.startedAt = startedAt
        self.day = day
        self.unit = unit
    }

    var orderedEntries: [LiftEntry] {
        entries.sorted { $0.order < $1.order }
    }
}

@Model
final class LiftEntry {
    var lift: Lift
    var order: Int
    /// For chin-ups this is added weight on top of bodyweight.
    var weight: Double
    /// One value per set. `nil` means the set is not done yet.
    var reps: [Int?]
    var workout: Workout?

    init(lift: Lift, order: Int, weight: Double) {
        self.lift = lift
        self.order = order
        self.weight = weight
        self.reps = Array(repeating: nil, count: lift.setCount)
    }

    var totalReps: Int { reps.compactMap { $0 }.reduce(0, +) }
}
