enum Lift: String, Codable, CaseIterable, Identifiable {
    case overheadPress, chinUp, squat, benchPress, barbellRow, deadlift

    var id: Self { self }

    var name: String {
        switch self {
        case .overheadPress: "Overhead Press"
        case .chinUp: "Chin-ups"
        case .squat: "Squat"
        case .benchPress: "Bench Press"
        case .barbellRow: "Barbell Row"
        case .deadlift: "Deadlift"
        }
    }

    var isLowerBody: Bool { self == .squat || self == .deadlift }

    var isBodyweight: Bool { self == .chinUp }

    var setCount: Int { self == .deadlift ? 1 : 3 }

    static let repsPerSet = 5
}

enum WorkoutDay: String, Codable {
    case a = "A", b = "B"

    var lifts: [Lift] {
        switch self {
        case .a: [.overheadPress, .chinUp, .squat]
        case .b: [.benchPress, .barbellRow, .deadlift]
        }
    }

    var other: WorkoutDay { self == .a ? .b : .a }
}
