import SwiftData
import SwiftUI

@main
struct SkullsetApp: App {
    @State private var health = HealthStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Workout", systemImage: "dumbbell.fill") { WorkoutView() }
                Tab("History", systemImage: "clock.arrow.circlepath") { HistoryView() }
                Tab("Progress", systemImage: "chart.xyaxis.line") { ProgressChartsView() }
            }
            .environment(health)
        }
        .modelContainer(for: Workout.self)
    }
}
