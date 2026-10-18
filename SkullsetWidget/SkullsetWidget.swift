import HealthKit
import SwiftUI
import WidgetKit

struct StepsEntry: TimelineEntry {
    let date: Date
    /// Nil until the user connects Apple Health in the app.
    let steps: Int?
    let target: Int
}

struct StepsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepsEntry {
        StepsEntry(date: .now, steps: 6_512, target: DailySteps.defaultTarget)
    }

    func getSnapshot(in context: Context, completion: @escaping (StepsEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepsEntry>) -> Void) {
        // WidgetKit calls the completion once, from any thread.
        nonisolated(unsafe) let completion = completion
        Task {
            let entry = StepsEntry(date: .now, steps: await todaySteps(), target: DailySteps.target)
            completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60))))
        }
    }

    private func todaySteps() async -> Int? {
        let store = HKHealthStore()
        let status = try? await store.statusForAuthorizationRequest(toShare: [], read: [HKQuantityType(.stepCount)])
        guard status == .unnecessary else { return nil }
        return await DailySteps.today(from: store)
    }
}

struct StepsWidgetView: View {
    let entry: StepsEntry

    private var progress: Double {
        guard let steps = entry.steps else { return 0 }
        return min(Double(steps) / Double(entry.target), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.tint.opacity(0.2), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.tint, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                if let steps = entry.steps {
                    Text(steps.formatted())
                        .font(.title3.bold())
                        .minimumScaleFactor(0.5)
                    Text("of \(entry.target.formatted())")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("—")
                        .font(.title3.bold())
                    Text("Open Skullset to connect Health")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(14)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct StepsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Steps", provider: StepsProvider()) { entry in
            StepsWidgetView(entry: entry)
        }
        .configurationDisplayName("Steps")
        .description("Today's steps and your daily target.")
        .supportedFamilies([.systemSmall])
    }
}
