import SwiftUI

// MARK: - ViewModel

@Observable
final class SynsViewModel {

    // MARK: Right eye

    var rightR0: Double = 0.0 {
        didSet { UserDefaults.standard.set(rightR0, forKey: "rightR0") }
    }
    var rightLens: Double = 0.0 {
        didSet { UserDefaults.standard.set(rightLens, forKey: "rightLens") }
    }

    // MARK: Left eye

    var leftR0: Double = 0.0 {
        didSet { UserDefaults.standard.set(leftR0, forKey: "leftR0") }
    }
    var leftLens: Double = 0.0 {
        didSet { UserDefaults.standard.set(leftLens, forKey: "leftLens") }
    }

    // MARK: Shared

    var accommodation: Double = 12.0 {
        didSet { UserDefaults.standard.set(accommodation, forKey: "accommodation") }
    }

    // MARK: Monovision

    var isMonovision: Bool = false {
        didSet { UserDefaults.standard.set(isMonovision, forKey: "isMonovision") }
    }
    var dominantEye: DominantEye = .right {
        didSet { UserDefaults.standard.set(dominantEye.rawValue, forKey: "dominantEye") }
    }
    var nearTarget: Double = -1.25 {
        didSet { UserDefaults.standard.set(nearTarget, forKey: "nearTarget") }
    }

    // MARK: - Init (load persisted state)

    init() {
        let ud = UserDefaults.standard

        if ud.object(forKey: "rightR0") != nil {
            rightR0 = ud.double(forKey: "rightR0")
        }
        if ud.object(forKey: "rightLens") != nil {
            rightLens = ud.double(forKey: "rightLens")
        }
        if ud.object(forKey: "leftR0") != nil {
            leftR0 = ud.double(forKey: "leftR0")
        }
        if ud.object(forKey: "leftLens") != nil {
            leftLens = ud.double(forKey: "leftLens")
        }
        if ud.object(forKey: "accommodation") != nil {
            accommodation = ud.double(forKey: "accommodation")
        }
        if ud.object(forKey: "isMonovision") != nil {
            isMonovision = ud.bool(forKey: "isMonovision")
        }
        if let raw = ud.string(forKey: "dominantEye"),
           let d = DominantEye(rawValue: raw) {
            dominantEye = d
        }
        if ud.object(forKey: "nearTarget") != nil {
            nearTarget = ud.double(forKey: "nearTarget")
        }
    }

    // MARK: - Computed eye parameters

    var rightEye: EyeParameters {
        var p = EyeParameters()
        p.r0 = rightR0
        p.accommodation = accommodation

        if isMonovision && dominantEye == .left {
            // Right is near eye → auto-calc lens
            p.lensCorrection = rightR0 - nearTarget
        } else {
            p.lensCorrection = rightLens
        }
        return p
    }

    var leftEye: EyeParameters {
        var p = EyeParameters()
        p.r0 = leftR0
        p.accommodation = accommodation

        if isMonovision && dominantEye == .right {
            // Left is near eye → auto-calc lens
            p.lensCorrection = leftR0 - nearTarget
        } else {
            p.lensCorrection = leftLens
        }
        return p
    }

    // MARK: - Results

    var rightResults: [DistanceResult] {
        OpticsCalculator.calculateResults(for: rightEye)
    }

    var leftResults: [DistanceResult] {
        OpticsCalculator.calculateResults(for: leftEye)
    }

    // MARK: - Helpers

    var isRightNearEye: Bool {
        isMonovision && dominantEye == .left
    }

    var isLeftNearEye: Bool {
        isMonovision && dominantEye == .right
    }

    var dominantLabel: String {
        dominantEye.displayName
    }

    var nearEyeLabel: String {
        dominantEye == .right ? "Venstre" : "Høyre"
    }

    var dofRange: Double {
        isMonovision ? 1.25 : 0.50
    }

    /// Effective lens value for the near eye (auto-calculated in monovision)
    var nearEyeAutoLens: Double {
        if dominantEye == .right {
            return leftR0 - nearTarget
        } else {
            return rightR0 - nearTarget
        }
    }
}

// MARK: - Formatting helper

extension Double {
    /// Format as diopter value: "+1.25 D" or "−0.50 D"
    var diopterString: String {
        let sign = self > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", self)) D"
    }
}
