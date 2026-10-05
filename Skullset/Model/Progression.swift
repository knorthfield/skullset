/// Greyskull LP rules (phrakture's variant).
enum Progression {
    static func nextDay(after lastDay: WorkoutDay?) -> WorkoutDay {
        lastDay?.other ?? .a
    }

    static func startingWeight(for lift: Lift, unit: WeightUnit) -> Double {
        lift.isBodyweight ? 0 : unit.barWeight
    }

    /// The weight for the next session of `lift`, from its last logged weight and reps.
    static func nextWeight(
        for lift: Lift,
        lastWeight: Double,
        lastReps: [Int?],
        lastUnit: WeightUnit,
        unit: WeightUnit
    ) -> Double {
        let converted = lastUnit == unit
            ? lastWeight
            : unit.roundToLoadable(lastUnit.convert(lastWeight, to: unit))

        if lift.isBodyweight { return converted }

        let done = lastReps.map { $0 ?? 0 }
        let target = lift.setCount * Lift.repsPerSet
        let increment = unit.increment(for: lift)

        if done.reduce(0, +) >= target {
            let amrap = done.last ?? 0
            return converted + (amrap >= 10 ? increment * 2 : increment)
        }

        let deloaded = unit.roundToLoadable(converted * 0.9, rule: .down)
        return max(deloaded, unit.barWeight)
    }
}
