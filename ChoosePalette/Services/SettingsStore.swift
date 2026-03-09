import SwiftUI
import Combine

final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @AppStorage(UserDefaultsKeys.defaultCopyFormat) var defaultCopyFormat: String = "HEX"
    @AppStorage(UserDefaultsKeys.hapticFeedbackEnabled) var hapticFeedbackEnabled: Bool = true

    private init() {}
}
