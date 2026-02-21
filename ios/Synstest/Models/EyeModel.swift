import Foundation

// MARK: - Distance definitions

struct ViewingDistance: Identifiable {
    let id = UUID()
    let name: String
    let meters: Double // Infinity for far distance

    var demand: Double {
        meters.isInfinite ? 0 : 1.0 / meters
    }

    static let all: [ViewingDistance] = [
        ViewingDistance(name: "Fjern (∞)", meters: .infinity),
        ViewingDistance(name: "Mellom (70 cm)", meters: 0.70),
        ViewingDistance(name: "Nær (40 cm)", meters: 0.40),
    ]
}

// MARK: - Per-eye parameters

struct EyeParameters {
    var r0: Double = 0.0          // Startverdi / naturlig brillestyrke (−6 … +6 D)
    var lensCorrection: Double = 0.0  // Kirurgisk korreksjon (−8 … +8 D)
    var accommodation: Double = 12.0  // Akkommodasjon (0 … 12 D)

    /// Residual etter korreksjon
    var residual: Double {
        r0 - lensCorrection
    }
}

// MARK: - Result for one distance

struct DistanceResult: Identifiable {
    let id = UUID()
    let distance: ViewingDistance
    let residual: Double
    let demand: Double
    let restDefocus: Double
}

// MARK: - Dominant eye

enum DominantEye: String, CaseIterable, Identifiable {
    case right = "R"
    case left = "L"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .right: "Høyre"
        case .left: "Venstre"
        }
    }
}

// MARK: - Optics calculations

enum OpticsCalculator {

    /// Demand at distance d (1/d, 0 for infinity)
    static func demand(at distance: Double) -> Double {
        distance.isInfinite ? 0 : 1.0 / distance
    }

    /// Rest-defocus: how blurry the vision is at a given distance
    /// B = R + 1/d
    /// coverage = min(B, A) if B > 0, else 0
    /// rest = B - coverage
    static func restDefocus(residual R: Double, distance d: Double, accommodation A: Double) -> Double {
        let B = R + demand(at: d)
        let coverage = B > 0 ? min(B, A) : 0
        return B - coverage
    }

    /// Calculate results for all standard distances
    static func calculateResults(for eye: EyeParameters) -> [DistanceResult] {
        ViewingDistance.all.map { dist in
            let rest = restDefocus(
                residual: eye.residual,
                distance: dist.meters,
                accommodation: eye.accommodation
            )
            return DistanceResult(
                distance: dist,
                residual: eye.residual,
                demand: dist.demand,
                restDefocus: rest
            )
        }
    }
}
