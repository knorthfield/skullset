import Foundation
import HealthKit

/// Today's step count and the daily target. The app and the widget share them through an App Group.
enum DailySteps {
    static var defaults: UserDefaults { UserDefaults(suiteName: "group.com.krisnorthfield.skullset")! }
    static let targetKey = "steps.target"
    static let defaultTarget = 10_000
    private static let countKey = "steps.count"
    private static let dateKey = "steps.date"

    static var target: Int { defaults.object(forKey: targetKey) as? Int ?? defaultTarget }

    /// Health cannot be read while the phone is locked, so then this returns the last count saved today.
    static func today(from store: HKHealthStore, now: Date = .now) async -> Int? {
        let startOfDay = Calendar.current.startOfDay(for: now)
        let query = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(
                type: HKQuantityType(.stepCount),
                predicate: HKQuery.predicateForSamples(withStart: startOfDay, end: now)
            ),
            options: .cumulativeSum
        )
        let count: Int
        do {
            count = Int(try await query.result(for: store)?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
        } catch let error as HKError where error.code == .errorNoData {
            count = 0
        } catch {
            return savedCount(on: now, in: defaults)
        }
        save(count, at: now, in: defaults)
        return count
    }

    static func save(_ count: Int, at date: Date, in defaults: UserDefaults) {
        defaults.set(count, forKey: countKey)
        defaults.set(date, forKey: dateKey)
    }

    static func savedCount(on date: Date, in defaults: UserDefaults, calendar: Calendar = .current) -> Int? {
        guard let savedAt = defaults.object(forKey: dateKey) as? Date,
              calendar.isDate(savedAt, inSameDayAs: date) else { return nil }
        return defaults.integer(forKey: countKey)
    }
}
