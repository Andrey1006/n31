import SwiftUI
import Combine

struct NotificationDisplayItem: Identifiable {
    let id: UUID
    let type: NotificationDisplayType
    let title: String
    let timeAgo: String
}

enum NotificationDisplayType {
    case success
    case tip

    var iconName: String {
        switch self {
        case .success: return "checkmark.circle"
        case .tip: return "lightbulb"
        }
    }

    var iconColor: Color {
        switch self {
        case .success: return Color.rgb(46, 204, 113)
        case .tip: return Color.rgb(241, 196, 15)
        }
    }
}

final class NotificationsStore: ObservableObject {
    static let shared = NotificationsStore()

    @Published private(set) var items: [NotificationDisplayItem] = []

    private init() {}

    func clear() {
        items = []
    }
}
