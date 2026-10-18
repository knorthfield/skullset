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
    /// After two weeks or more off, the weight goes down 10% for each week after the first, to at most 50%.
    static func nextWeight(
        for lift: Lift,
        lastWeight: Double,
        lastReps: [Int?],
        lastUnit: WeightUnit,
        unit: WeightUnit,
        plates: [Double],
        daysSinceLastSession: Int
    ) -> Double {
        let converted = lastUnit.convert(lastWeight, to: unit)

        if lift.isBodyweight { return (converted * 2).rounded() / 2 }

        let weeksOff = daysSinceLastSession / 7
        if weeksOff >= 2 {
            let factor = max(0.5, 1 - 0.1 * Double(weeksOff - 1))
            return PlateCalculator.loadable(converted * factor, unit: unit, plates: plates, rounding: .down)
        }

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
