enum PlateCalculator {
    /// All plate sizes are whole multiples of this, in both units.
    private static let plateUnit = 0.25

    enum Rounding { case up, down, nearest }

    /// The fewest plates for one side of the bar, heaviest first.
    /// `nil` when the weight cannot be loaded exactly. Assumes enough of each plate size.
    static func platesPerSide(for weight: Double, unit: WeightUnit, plates: [Double]) -> [Double]? {
        let perSide = (weight - unit.barWeight) / 2 / plateUnit
        let target = Int(perSide.rounded())
        guard target >= 0, abs(perSide - Double(target)) < 0.001 else { return nil }

        let sizes = plates.map { Int(($0 / plateUnit).rounded()) }.filter { $0 > 0 }
        // fewest[n] is the fewest plates that make n; lastPlate[n] is one plate in that answer.
        var fewest = [0] + Array(repeating: Int.max, count: target)
        var lastPlate = Array(repeating: 0, count: target + 1)
        if target > 0 {
            for amount in 1...target {
                for size in sizes where size <= amount && fewest[amount - size] != Int.max {
                    if fewest[amount - size] + 1 < fewest[amount] {
                        fewest[amount] = fewest[amount - size] + 1
                        lastPlate[amount] = size
                    }
                }
            }
        }
        guard fewest[target] != Int.max else { return nil }

        var result: [Double] = []
        var amount = target
        while amount > 0 {
            result.append(Double(lastPlate[amount]) * plateUnit)
            amount -= lastPlate[amount]
        }
        return result.sorted(by: >)
    }

    /// The closest weight to `weight`, in the given direction, that the plates can make.
    /// Never less than the bar.
    static func loadable(_ weight: Double, unit: WeightUnit, plates: [Double], rounding: Rounding) -> Double {
        let step = plateUnit * 2
        let bar = unit.barWeight
        guard weight > bar else { return bar }
        let steps = (weight - bar) / step
        let below = bar + steps.rounded(.down) * step
        let above = bar + steps.rounded(.up) * step

        func isLoadable(_ candidate: Double) -> Bool {
            platesPerSide(for: candidate, unit: unit, plates: plates) != nil
        }
        func search(from start: Double, by delta: Double) -> Double? {
            var candidate = start
            for _ in 0..<1000 where candidate >= bar {
                if isLoadable(candidate) { return candidate }
                candidate += delta
            }
            return nil
        }

        switch rounding {
        case .up:
            return search(from: above, by: step) ?? bar
        case .down:
            return search(from: below, by: -step) ?? bar
        case .nearest:
            let down = search(from: below, by: -step) ?? bar
            guard let up = search(from: above, by: step) else { return down }
            return up - weight < weight - down ? up : down
        }
    }
}
