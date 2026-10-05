/// Greyskull LP rules (phrakture's variant).
enum Progression {
    static func nextDay(after lastDay: WorkoutDay?) -> WorkoutDay {
        lastDay?.other ?? .a
    }

    static func startingWeight(for lift: Lift, unit: WeightUnit) -> Double {
        lift.isBodyweight ? 0 : unit.barWeight
    }

    /// The weight for the next session of `lift`, from its last logged weight and reps,
    /// rounded so it can be loaded with `plates`.
    static func nextWeight(
        for lift: Lift,
        lastWeight: Double,
        lastReps: [Int?],
        lastUnit: WeightUnit,
        unit: WeightUnit,
        plates: [Double]
    ) -> Double {
        let converted = lastUnit.convert(lastWeight, to: unit)

        if lift.isBodyweight { return (converted * 2).rounded() / 2 }

        let done = lastReps.map { $0 ?? 0 }
        let target = lift.setCount * Lift.repsPerSet
        let increment = unit.increment(for: lift)

        if done.reduce(0, +) >= target {
            let amrap = done.last ?? 0
            let jump = amrap >= 10 ? increment * 2 : increment
            let base = lastUnit == unit ? converted : PlateCalculator.loadable(converted, unit: unit, plates: plates, rounding: .nearest)
            return PlateCalculator.loadable(base + jump, unit: unit, plates: plates, rounding: .up)
        }

        return PlateCalculator.loadable(converted * 0.9, unit: unit, plates: plates, rounding: .down)
    }
}
