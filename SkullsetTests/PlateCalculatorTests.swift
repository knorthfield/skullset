import Testing
@testable import Skullset

struct PlateCalculatorTests {
    private let kg = WeightUnit.kg.defaultPlates
    private let lb = WeightUnit.lb.defaultPlates

    @Test func emptyBar() {
        #expect(PlateCalculator.platesPerSide(for: 20, unit: .kg, plates: kg) == [])
    }

    @Test func kilograms() {
        #expect(PlateCalculator.platesPerSide(for: 60, unit: .kg, plates: kg) == [20])
        #expect(PlateCalculator.platesPerSide(for: 62.5, unit: .kg, plates: kg) == [20, 1.25])
        #expect(PlateCalculator.platesPerSide(for: 51, unit: .kg, plates: kg) == [15, 0.25, 0.25])
        #expect(PlateCalculator.platesPerSide(for: 62, unit: .kg, plates: kg) == [20, 1])
        #expect(PlateCalculator.platesPerSide(for: 120, unit: .kg, plates: kg) == [25, 25])
    }

    @Test func pounds() {
        #expect(PlateCalculator.platesPerSide(for: 135, unit: .lb, plates: lb) == [45])
        #expect(PlateCalculator.platesPerSide(for: 137.5, unit: .lb, plates: lb) == [45, 1.25])
        #expect(PlateCalculator.platesPerSide(for: 225, unit: .lb, plates: lb) == [45, 45])
    }

    @Test func usesFewestPlates() {
        #expect(PlateCalculator.platesPerSide(for: 64, unit: .kg, plates: [20, 1.25, 1]) == [20, 1, 1])
    }

    @Test func impossibleWeightIsNil() {
        #expect(PlateCalculator.platesPerSide(for: 61, unit: .kg, plates: [20, 2.5, 1.25]) == nil)
        #expect(PlateCalculator.platesPerSide(for: 19, unit: .kg, plates: kg) == nil)
    }

    @Test func roundsToLoadableWeight() {
        let plates = [20, 10, 5, 2.5, 1.25]
        #expect(PlateCalculator.loadable(61, unit: .kg, plates: plates, rounding: .up) == 62.5)
        #expect(PlateCalculator.loadable(61, unit: .kg, plates: plates, rounding: .down) == 60)
        #expect(PlateCalculator.loadable(61, unit: .kg, plates: plates, rounding: .nearest) == 60)
        #expect(PlateCalculator.loadable(10, unit: .kg, plates: plates, rounding: .down) == 20)
    }
}
