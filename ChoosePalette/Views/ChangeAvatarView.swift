import SwiftUI

struct ChangeAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(UserDefaultsKeys.profileAvatarIndex) private var profileAvatarIndex: Int = 0

    private let background = Color.rgb(11, 16, 32)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)

    private let avatars: [(emoji: String, color: Color)] = [
        ("🎨", Color.rgb(106, 169, 255)),
        ("🌈", Color.rgb(180, 140, 255)),
        ("✨", Color.rgb(0, 150, 136)),
        ("🎭", Color.rgb(180, 100, 80))
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            VStack(spacing: 24) {
                Text("Choose an avatar")
                    .font(.interMedium(size: 16))
                    .foregroundStyle(secondaryColor)
                HStack(spacing: 20) {
                    ForEach(Array(avatars.enumerated()), id: \.offset) { index, item in
                        Button {
                            profileAvatarIndex = index
                            HapticHelper.impactIfEnabled()
                            dismiss()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 72, height: 72)
                                Text(item.emoji)
                                    .font(.system(size: 36))
                                if profileAvatarIndex == index {
                                    Circle()
                                        .stroke(titleColor, lineWidth: 3)
                                        .frame(width: 72, height: 72)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(titleColor)
            }
            .frame(width: 36, height: 36)

            Spacer()

            Text("Change profile")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }
}

#Preview {
    ChangeAvatarView()
}
