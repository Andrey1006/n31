import UIKit

enum HapticHelper {
    static func impactIfEnabled() {
        guard UserDefaults.standard.object(forKey: UserDefaultsKeys.hapticFeedbackEnabled) as? Bool ?? true else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
