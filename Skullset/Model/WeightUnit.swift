import Foundation

enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    case kg, lb

    var id: Self { self }

    static let poundsPerKilogram = 2.20462

    var barWeight: Double { self == .kg ? 20 : 45 }

    /// Every plate size Settings offers, heaviest first.
    var allPlates: [Double] {
        switch self {
        case .kg: [25, 20, 15, 10, 5, 2.5, 2, 1.5, 1.25, 1, 0.5, 0.25]
        case .lb: [45, 35, 25, 15, 10, 5, 2.5, 1.25, 0.5, 0.25]
        }
    }

    var defaultPlates: [Double] {
        switch self {
        case .kg: [25, 20, 15, 10, 5, 2.5, 1.25, 1, 0.25]
        case .lb: [45, 35, 25, 10, 5, 2.5, 1.25]
        }
    }

    /// Reads plates saved as a comma-separated string. Empty means the defaults.
    func selectedPlates(from stored: String) -> [Double] {
        let plates = stored.split(separator: ",").compactMap { Double($0) }
        return plates.isEmpty ? defaultPlates : plates.sorted(by: >)
    }

    func storageString(for plates: [Double]) -> String {
        plates.sorted(by: >).map { String($0) }.joined(separator: ",")
    }

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

    func format(_ weight: Double) -> String {
        "\(weight.formatted(.number.precision(.fractionLength(0...2)))) \(rawValue)"
    }
}
