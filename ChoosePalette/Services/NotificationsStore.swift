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
    private static let maxItems = 50

    private init() {}

    func add(type: NotificationDisplayType, title: String) {
        let item = NotificationDisplayItem(
            id: UUID(),
            type: type,
            title: title,
            timeAgo: Self.timeAgo(from: Date())
        )
        items.insert(item, at: 0)
        if items.count > Self.maxItems {
            items = Array(items.prefix(Self.maxItems))
        }
    }

    func clear() {
        items = []
    }

    private static func timeAgo(from date: Date) -> String {
        let s = Int(-date.timeIntervalSinceNow)
        if s < 60 { return "Just now" }
        if s < 3600 { return "\(s / 60) min ago" }
        if s < 86400 { return "\(s / 3600) hr ago" }
        if s < 604800 { return "\(s / 86400) days ago" }
        return "\(s / 604800) wk ago"
    }
}
