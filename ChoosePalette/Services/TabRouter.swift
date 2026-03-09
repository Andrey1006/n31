import SwiftUI
import Combine

final class TabRouter: ObservableObject {
    @Published var selectedTab: Int = 0

    func selectTab(_ index: Int) {
        selectedTab = index
    }
}
