import Charts
import SwiftData
import SwiftUI

struct ProgressChartsView: View {
    @Environment(HealthStore.self) private var health
    @AppStorage("unit") private var unit: WeightUnit = .kg
    @Query(filter: #Predicate<Workout> { $0.finishedAt != nil }, sort: \Workout.startedAt)
    private var workouts: [Workout]
    @State private var bodyweights: [BodyweightSample] = []

    private struct Point: Identifiable {
        let date: Date
        let value: Double
        var id: Date { date }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(Lift.allCases) { lift in
                    let points = points(for: lift)
                    if !points.isEmpty {
                        chartSection(lift.isBodyweight ? "\(lift.name) (total reps)" : lift.name, points: points)
                    }
                }
                if !bodyweights.isEmpty {
                    chartSection("Bodyweight", points: bodyweights.map {
                        Point(date: $0.date, value: WeightUnit.kg.convert($0.kilograms, to: unit))
                    })
                }
            }
            .overlay {
                if workouts.isEmpty && bodyweights.isEmpty {
                    ContentUnavailableView("No Progress Yet", systemImage: "chart.xyaxis.line", description: Text("Finish a workout to see your lifts here."))
                }
            }
            .navigationTitle("Progress")
            .task { bodyweights = await health.bodyweightSamples() }
        }
    }

    private func points(for lift: Lift) -> [Point] {
        workouts.compactMap { workout in
            guard let entry = workout.entries.first(where: { $0.lift == lift }) else { return nil }
            let value = lift.isBodyweight
                ? Double(entry.totalReps)
                : workout.unit.convert(entry.weight, to: unit)
            return Point(date: workout.startedAt, value: value)
        }
    }

    private func chartSection(_ title: String, points: [Point]) -> some View {
        Section(title) {
            Chart(points) { point in
                LineMark(x: .value("Date", point.date), y: .value(title, point.value))
                PointMark(x: .value("Date", point.date), y: .value(title, point.value))
            }
            .chartYScale(domain: .automatic(includesZero: false))
            .frame(height: 160)
            .padding(.vertical, 8)
        }
    }
}
