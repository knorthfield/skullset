import Foundation
import Testing
@testable import Skullset

struct DailyStepsTests {
    private let defaults = UserDefaults(suiteName: UUID().uuidString)!

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))!
    }

    @Test func usesSavedCountOnTheSameDay() {
        DailySteps.save(6_512, at: date(18, 9), in: defaults)
        #expect(DailySteps.savedCount(on: date(18, 23), in: defaults, calendar: calendar) == 6_512)
    }

    @Test func ignoresSavedCountFromYesterday() {
        DailySteps.save(6_512, at: date(17, 23), in: defaults)
        #expect(DailySteps.savedCount(on: date(18, 0), in: defaults, calendar: calendar) == nil)
    }

    @Test func hasNoCountWhenNothingIsSaved() {
        #expect(DailySteps.savedCount(on: date(18, 9), in: defaults, calendar: calendar) == nil)
    }
}
