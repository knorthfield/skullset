import Foundation
import Testing
@testable import Skullset

struct WorkoutReminderTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/London")!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    @Test func remindsAfterOneRestDayThenTwoMoreDays() {
        // Tuesday evening → Thursday, Friday and Saturday mornings.
        let dates = WorkoutReminder.reminderDates(after: date(2026, 10, 6, 19, 30), calendar: calendar)
        #expect(dates == [date(2026, 10, 8, 8), date(2026, 10, 9, 8), date(2026, 10, 10, 8)])
    }

    @Test func countsFromTheCalendarDayOfTheWorkout() {
        let dates = WorkoutReminder.reminderDates(after: date(2026, 10, 7, 0, 5), calendar: calendar)
        #expect(dates.first == date(2026, 10, 9, 8))
    }

    @Test func staysAtEightAcrossDaylightSavingChange() {
        // Clocks go back on Sunday 25 October 2026.
        let dates = WorkoutReminder.reminderDates(after: date(2026, 10, 23, 18), calendar: calendar)
        #expect(dates == [date(2026, 10, 25, 8), date(2026, 10, 26, 8), date(2026, 10, 27, 8)])
        #expect(dates.allSatisfy { calendar.component(.hour, from: $0) == 8 })
    }
}
