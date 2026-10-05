import Foundation
import UserNotifications

/// Reminds the user to train after one rest day, at 8:00 am.
/// If they miss that day, they get a reminder on the next two days too.
enum WorkoutReminder {
    private static let daysAfterWorkout = [2, 3, 4]
    private static let hour = 8

    private static var notificationIDs: [String] {
        daysAfterWorkout.indices.map { "workout-reminder-\($0)" }
    }

    static func reminderDates(after finishedAt: Date, calendar: Calendar = .current) -> [Date] {
        let finishDay = calendar.startOfDay(for: finishedAt)
        return daysAfterWorkout.compactMap { days in
            calendar.date(byAdding: .day, value: days, to: finishDay)
                .flatMap { calendar.date(bySettingHour: hour, minute: 0, second: 0, of: $0) }
        }
    }

    static func schedule(for day: WorkoutDay, after finishedAt: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: notificationIDs)

        let content = UNMutableNotificationContent()
        content.title = "Workout \(day.rawValue) today"
        content.body = day.lifts.map(\.name).formatted(.list(type: .and, width: .narrow))
        content.sound = .default

        for (id, date) in zip(notificationIDs, reminderDates(after: finishedAt)) {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }
    }
}
