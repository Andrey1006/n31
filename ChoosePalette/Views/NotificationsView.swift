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
                    ForEach(notificationsStore.items) { item in
                        notificationCard(item: item)
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
