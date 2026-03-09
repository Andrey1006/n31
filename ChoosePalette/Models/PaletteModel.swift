import SwiftUI
struct PaletteDisplayItem: Identifiable {
    let id: String
    let name: String
    let tags: [String]
    let colors: [Color]
    let isFavorite: Bool
}

struct PaletteModel: Identifiable, Codable {
    var id: String
    var name: String
    var tags: [String]
    var colorHexes: [String]
    var isFavorite: Bool
    var createdAt: Date

    init(id: String = UUID().uuidString, name: String, tags: [String], colorHexes: [String], isFavorite: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.tags = tags
        self.colorHexes = colorHexes
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}
