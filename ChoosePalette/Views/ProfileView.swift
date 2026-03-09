import SwiftUI

struct ProfileView: View {
    @Environment(\.showTabBar) private var showTabBar
    @AppStorage(UserDefaultsKeys.profileAvatarIndex) private var profileAvatarIndex: Int = 0
    @State private var showDeleteAlert = false
    @ObservedObject private var palettesService = PalettesService.shared

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        avatarSection
                        statsSection
                        navigationRows
                        accountButtons
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                showTabBar.wrappedValue = true
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                Group {
                    switch route {
                    case .settings:
                        SettingsView()
                    case .library(let filter):
                        LibraryView(initialFilter: filter, isPushed: true)
                    case .changeAvatar:
                        ChangeAvatarView()
                    }
                }
                .navigationBarBackButtonHidden(true)
                .environment(\.showTabBar, showTabBar)
                .onAppear { showTabBar.wrappedValue = false }
                .onDisappear { showTabBar.wrappedValue = true }
            }
        }
        .alert("Delete account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    try? await AuthService.shared.deleteAccount()
                }
            }
        } message: {
            Text("Are you sure? This cannot be undone.")
        }
    }

    private var header: some View {
        HStack {
            Color.clear
                .frame(width: 36, height: 36)

            Spacer()

            Text("Profile")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            Spacer()

            NavigationLink(value: ProfileRoute.settings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundStyle(titleColor)
            }
            .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private static let profileAvatars: [(emoji: String, color: Color)] = [
        ("🎨", Color.rgb(106, 169, 255)),
        ("🌈", Color.rgb(180, 140, 255)),
        ("✨", Color.rgb(0, 150, 136)),
        ("🎭", Color.rgb(180, 100, 80))
    ]

    private var avatarSection: some View {
        let index = min(max(0, profileAvatarIndex), Self.profileAvatars.count - 1)
        let avatar = Self.profileAvatars[index]
        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(avatar.color)
                    .frame(width: 96, height: 96)
                Text(avatar.emoji)
                    .font(.system(size: 48))
            }
            .padding(.top, 24)

            Text("Guest")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            NavigationLink(value: ProfileRoute.changeAvatar) {
                Text("Change profile")
                    .font(.interRegular(size: 14))
                    .foregroundStyle(secondaryColor)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("\(palettesService.palettes.count)")
                    .font(.interSemiBold(size: 24))
                    .foregroundStyle(titleColor)
                Text("Palettes")
                    .font(.interRegular(size: 14))
                    .foregroundStyle(secondaryColor)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(secondaryColor.opacity(0.3))
                .frame(width: 1)
                .frame(maxHeight: .infinity)

            VStack(spacing: 4) {
                Text("\(palettesService.favoritesCount)")
                    .font(.interSemiBold(size: 24))
                    .foregroundStyle(titleColor)
                Text("Favorites")
                    .font(.interRegular(size: 14))
                    .foregroundStyle(secondaryColor)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 16)
    }

    private var navigationRows: some View {
        VStack(spacing: 12) {
            NavigationLink(value: ProfileRoute.library(nil)) {
                profileRowContent(icon: "paintpalette", title: "My Palettes")
            }
            .buttonStyle(.plain)
            NavigationLink(value: ProfileRoute.library(.favorites)) {
                profileRowContent(icon: "heart", title: "Favorites")
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 24)
    }

    private var accountButtons: some View {
        VStack(spacing: 12) {
            Button("Log Out") {
                try? AuthService.shared.signOut()
            }
            .font(.interSemiBold(size: 16))
            .foregroundStyle(secondaryColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .buttonStyle(.plain)

            Button("Delete account") {
                showDeleteAlert = true
            }
            .font(.interSemiBold(size: 16))
            .foregroundStyle(Color.rgb(255, 82, 82))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .buttonStyle(.plain)
        }
    }

    private func profileRowContent(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color.rgb(106, 169, 255))
                .frame(width: 24, alignment: .center)

            Text(title)
                .font(.interMedium(size: 16))
                .foregroundStyle(titleColor)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(secondaryColor)
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private enum ProfileRoute: Hashable {
    case settings
    case library(LibraryView.Filter?)
    case changeAvatar
}

#Preview {
    ProfileView()
}
