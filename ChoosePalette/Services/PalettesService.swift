import Foundation
import SwiftUI
import Combine

final class PalettesService: ObservableObject {
    static let shared = PalettesService()

    @Published private(set) var palettes: [PaletteModel] = []

    private let storageKey = "savedPalettes"

    private init() {
        load()
    }

    
    var displayItems: [PaletteDisplayItem] {
        palettes
            .sorted { $0.createdAt > $1.createdAt }
            .map { p in
                PaletteDisplayItem(
                    id: p.id,
                    name: p.name,
                    tags: p.tags,
                    colors: p.colorHexes.compactMap { Color.hex($0) },
                    isFavorite: p.isFavorite
                )
            }
    }

    var favoritesCount: Int {
        palettes.filter(\.isFavorite).count
    }

    func clearAll() {
        palettes = []
        save()
    }

    func add(name: String, tags: [String], colorHexes: [String]) {
        let p = PaletteModel(name: name, tags: tags, colorHexes: colorHexes)
        palettes.insert(p, at: 0)
        save()
    }

    func toggleFavorite(id: String) {
        guard let i = palettes.firstIndex(where: { $0.id == id }) else { return }
        palettes[i].isFavorite.toggle()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([PaletteModel].self, from: data) else { return }
        palettes = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(palettes) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
