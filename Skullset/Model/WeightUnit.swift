import Foundation

enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    case kg, lb

    var id: Self { self }

    static let poundsPerKilogram = 2.20462

    var barWeight: Double { self == .kg ? 20 : 45 }

    /// Plates available per side, heaviest first.
    var plates: [Double] {
        switch self {
        case .kg: [25, 20, 15, 10, 5, 2.5, 1.25, 1, 0.25]
        case .lb: [45, 35, 25, 10, 5, 2.5, 1.25]
        }
    }

    /// The smallest change that can be loaded on a bar: two of the smallest plate.
    var smallestStep: Double { plates.last! * 2 }

    func increment(for lift: Lift) -> Double {
        switch self {
        case .kg: lift.isLowerBody ? 2.5 : 1
        case .lb: lift.isLowerBody ? 5 : 2.5
        }
    }

    func convert(_ weight: Double, to target: WeightUnit) -> Double {
        switch (self, target) {
        case (.kg, .lb): weight * Self.poundsPerKilogram
        case (.lb, .kg): weight / Self.poundsPerKilogram
        default: weight
        }
    }

    func roundToLoadable(_ weight: Double, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Double {
        (weight / smallestStep).rounded(rule) * smallestStep
    }

    func format(_ weight: Double) -> String {
        "\(weight.formatted(.number.precision(.fractionLength(0...2)))) \(rawValue)"
    }
}
