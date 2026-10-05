import Testing
@testable import Skullset

struct ProgressionTests {
    private func next(
        _ lift: Lift, _ weight: Double, _ reps: [Int?],
        from: WeightUnit = .kg, to: WeightUnit = .kg, plates: [Double]? = nil
    ) -> Double {
        Progression.nextWeight(
            for: lift, lastWeight: weight, lastReps: reps,
            lastUnit: from, unit: to, plates: plates ?? to.defaultPlates
        )
    }

    @Test func alternatesDays() {
        #expect(Progression.nextDay(after: nil) == .a)
        #expect(Progression.nextDay(after: .a) == .b)
        #expect(Progression.nextDay(after: .b) == .a)
    }

    @Test func addsIncrementOnSuccess() {
        #expect(next(.squat, 60, [5, 5, 5]) == 62.5)
        #expect(next(.benchPress, 50, [5, 5, 6]) == 51)
        #expect(next(.benchPress, 100, [5, 5, 5], from: .lb, to: .lb) == 102.5)
        #expect(next(.squat, 100, [5, 5, 5], from: .lb, to: .lb) == 105)
    }

    @Test func doublesIncrementWhenLastSetHitsTen() {
        #expect(next(.squat, 60, [5, 5, 10]) == 65)
        #expect(next(.overheadPress, 40, [5, 5, 12]) == 42)
    }

    @Test func deloadsTenPercentOnFailure() {
        #expect(next(.squat, 100, [5, 5, 4]) == 90)
        #expect(next(.overheadPress, 41, [5, 4, 3]) == 36.5)
        #expect(next(.squat, 100, [5, 5, nil]) == 90)
    }

    @Test func deloadNeverGoesBelowBar() {
        #expect(next(.overheadPress, 21, [3, 3, 3]) == 20)
    }

    @Test func deadliftIsOneSet() {
        #expect(next(.deadlift, 100, [5]) == 102.5)
        #expect(next(.deadlift, 100, [4]) == 90)
    }

    @Test func chinUpsKeepTheirWeight() {
        #expect(next(.chinUp, 0, [5, 5, 12]) == 0)
        #expect(next(.chinUp, 5, [2, 1, 0]) == 5)
    }

    @Test func jumpsAreRoundedUpToYourPlates() {
        #expect(next(.benchPress, 50, [5, 5, 5], plates: [20, 10, 5, 2.5, 1.25]) == 52.5)
        #expect(next(.benchPress, 50, [5, 5, 5], plates: [20, 10, 5, 2.5, 0.25]) == 51)
    }

    @Test func deloadRoundsDownToYourPlates() {
        #expect(next(.squat, 70, [3, 3, 3], plates: [20, 10, 5, 2.5]) == 60)
    }

    @Test func convertsUnitsToLoadableWeight() {
        #expect(next(.squat, 100, [5, 5, 5], from: .kg, to: .lb) == 225)
        #expect(next(.squat, 225, [5, 5, 5], from: .lb, to: .kg) == 104.5)
    }
}
