import SwiftUI

private struct ShowTabBarKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = Binding.constant(true)
}

extension EnvironmentValues {
    var showTabBar: Binding<Bool> {
        get { self[ShowTabBarKey.self] }
        set { self[ShowTabBarKey.self] = newValue }
    }
}
