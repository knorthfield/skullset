import SwiftUI
import UserNotifications

enum RestTimer {
    static let duration: TimeInterval = 180
    private static let notificationID = "rest"

    static func requestPermission() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    static func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Rest over"
        content.body = "Time for your next set."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        )
    }

    static func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}

struct RestTimerBar: View {
    let startedAt: Date
    let onDismiss: () -> Void

    var body: some View {
        TimelineView(.periodic(from: startedAt, by: 1)) { context in
            let elapsed = max(0, context.date.timeIntervalSince(startedAt))
            let isOver = elapsed >= RestTimer.duration
            HStack {
                Image(systemName: isOver ? "bell.fill" : "timer")
                Text(isOver ? "Rest over" : "Rest")
                Spacer()
                Text(Duration.seconds(elapsed).formatted(.time(pattern: .minuteSecond)))
                    .monospacedDigit()
                    .fontWeight(.semibold)
                Button("Hide", systemImage: "xmark", action: onDismiss)
                    .labelStyle(.iconOnly)
                    .padding(.leading, 8)
            }
            .foregroundStyle(isOver ? .white : .primary)
            .padding()
            .background(isOver ? AnyShapeStyle(.red) : AnyShapeStyle(.regularMaterial), in: .capsule)
            .padding(.horizontal)
        }
    }
}
