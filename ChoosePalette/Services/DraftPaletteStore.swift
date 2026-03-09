import SwiftUI
import Combine

final class DraftPaletteStore: ObservableObject {
    static let shared = DraftPaletteStore()

    @Published private(set) var draftColors: [String] = []

    private init() {}

    func addColor(hex: String) {
        draftColors.append(hex)
    }

    func setDraft(_ hexes: [String]) {
        draftColors = hexes
    }

    func takeDraft() -> [String] {
        let result = draftColors
        draftColors = []
        return result
    }
}
