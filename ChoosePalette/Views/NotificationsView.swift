import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var notificationsStore = NotificationsStore.shared

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    if notificationsStore.items.isEmpty {
                        emptyState
                    } else {
                        ForEach(notificationsStore.items) { item in
                            notificationCard(item: item)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.rgb(106, 169, 255))
            }
            .frame(width: 36, height: 36)

            Spacer()

            Text("Notifications")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            Spacer()

            Button("Clear") {
                notificationsStore.clear()
            }
            .font(.interMedium(size: 14))
            .foregroundStyle(secondaryColor)
            .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(secondaryColor.opacity(0.6))
            Text("No notifications yet")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
            Text("When you save or edit palettes, updates will appear here.")
                .font(.interRegular(size: 14))
                .foregroundStyle(secondaryColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func notificationCard(item: NotificationDisplayItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .stroke(item.type.iconColor.opacity(0.5), lineWidth: 2)
                    .frame(width: 44, height: 44)
                Image(systemName: item.type.iconName)
                    .font(.system(size: 22))
                    .foregroundStyle(item.type.iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.interRegular(size: 16))
                    .foregroundStyle(titleColor)
                Text(item.timeAgo)
                    .font(.interRegular(size: 14))
                    .foregroundStyle(secondaryColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NotificationsView()
}
