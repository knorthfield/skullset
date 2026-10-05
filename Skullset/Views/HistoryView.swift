import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Workout> { $0.finishedAt != nil }, sort: \Workout.startedAt, order: .reverse)
    private var workouts: [Workout]

    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Workout \(workout.day.rawValue)").font(.headline)
                            Spacer()
                            Text(workout.startedAt, format: .dateTime.day().month().year())
                                .foregroundStyle(.secondary)
                        }
                        ForEach(workout.orderedEntries) { entry in
                            HStack {
                                Text(entry.lift.name)
                                Spacer()
                                Text(summary(of: entry, unit: workout.unit))
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    for index in offsets { context.delete(workouts[index]) }
                    try? context.save()
                }
            }
            .overlay {
                if workouts.isEmpty {
                    ContentUnavailableView("No Workouts Yet", systemImage: "dumbbell", description: Text("Finished workouts show here."))
                }
            }
            .navigationTitle("History")
        }
    }

    private func summary(of entry: LiftEntry, unit: WeightUnit) -> String {
        let reps = entry.reps.map { $0.map(String.init) ?? "–" }.joined(separator: "/")
        if entry.lift.isBodyweight && entry.weight == 0 { return reps }
        return "\(unit.format(entry.weight))  \(reps)"
    }
}
