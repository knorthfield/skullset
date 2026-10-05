enum PlateCalculator {
    /// Plates for one side of the bar, heaviest first. Any weight that cannot be loaded is left off.
    static func platesPerSide(for weight: Double, unit: WeightUnit) -> [Double] {
        var remaining = (weight - unit.barWeight) / 2
        var result: [Double] = []
        for plate in unit.plates {
            while remaining >= plate - 0.001 {
                result.append(plate)
                remaining -= plate
            }
        }
        return result
    }
}
