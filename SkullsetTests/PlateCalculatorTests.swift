import Testing
@testable import Skullset

struct PlateCalculatorTests {
    @Test func emptyBar() {
        #expect(PlateCalculator.platesPerSide(for: 20, unit: .kg).isEmpty)
    }

    @Test func kilograms() {
        #expect(PlateCalculator.platesPerSide(for: 60, unit: .kg) == [20])
        #expect(PlateCalculator.platesPerSide(for: 62.5, unit: .kg) == [20, 1.25])
        #expect(PlateCalculator.platesPerSide(for: 51, unit: .kg) == [15, 0.25, 0.25])
        #expect(PlateCalculator.platesPerSide(for: 62, unit: .kg) == [20, 1])
        #expect(PlateCalculator.platesPerSide(for: 120, unit: .kg) == [25, 25])
    }

    @Test func pounds() {
        #expect(PlateCalculator.platesPerSide(for: 135, unit: .lb) == [45])
        #expect(PlateCalculator.platesPerSide(for: 137.5, unit: .lb) == [45, 1.25])
        #expect(PlateCalculator.platesPerSide(for: 225, unit: .lb) == [45, 45])
    }
}
