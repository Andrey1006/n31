import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var tabRouter: TabRouter
    @Environment(\.showTabBar) private var showTabBar
    @AppStorage(UserDefaultsKeys.profileAvatarIndex) private var profileAvatarIndex: Int = 0
    @ObservedObject private var palettesService = PalettesService.shared

    private let background = Color.rgb(11, 16, 32)

    private static let profileAvatars: [(emoji: String, color: Color)] = [
        ("🎨", Color.rgb(106, 169, 255)),
        ("🌈", Color.rgb(180, 140, 255)),
        ("✨", Color.rgb(0, 150, 136)),
        ("🎭", Color.rgb(180, 100, 80))
    ]
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)

    private var recentPalettes: [PaletteDisplayItem] {
        palettesService.displayItems
    }

    private var favoritesPalettes: [PaletteDisplayItem] {
        palettesService.displayItems.filter(\.isFavorite)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    quickActionsSection
                    recentPalettesSection
                    favoritesSection
                    tipCard
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .onAppear {
            showTabBar.wrappedValue = true
        }
    }

    private var header: some View {
        let index = min(max(0, profileAvatarIndex), Self.profileAvatars.count - 1)
        let avatar = Self.profileAvatars[index]
        return HStack {
            Text(avatar.emoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(avatar.color)
                .clipShape(Circle())

            Spacer()

            Text("Home")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            Spacer()

            NavigationLink(destination: NotificationsView()
                .navigationBarBackButtonHidden(true)
                .environment(\.showTabBar, showTabBar)
                .onAppear { showTabBar.wrappedValue = false }
                .onDisappear { showTabBar.wrappedValue = true }
            ) {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundStyle(titleColor)
            }
            .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .padding(.horizontal, 24)

            HStack(spacing: 12) {
                quickActionButton(
                    title: "Create",
                    icon: "plus",
                    color: Color.rgb(106, 169, 255)
                )
                quickActionButton(
                    title: "Generate",
                    icon: "sparkles",
                    color: Color.rgb(180, 140, 255)
                )
                quickActionButton(
                    title: "Capture",
                    icon: "camera",
                    color: Color.rgb(66, 221, 155)
                )
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
        .padding(.top, 14)
    }

    private func quickActionButton(title: String, icon: String, color: Color) -> some View {
        Button {
            switch title {
            case "Create", "Generate":
                tabRouter.selectTab(1)
            case "Capture":
                tabRouter.selectTab(2)
            default:
                break
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                Text(title)
                    .font(.interMedium(size: 12))
                    .foregroundStyle(secondaryColor)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.rgb(18, 26, 46))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var recentPalettesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Palettes")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                ForEach(recentPalettes) { palette in
                    paletteCard(palette: palette)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }

    private var favoritesSection: some View {
        Group {
            if !favoritesPalettes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Favorites")
                        .font(.interSemiBold(size: 20))
                        .foregroundStyle(titleColor)
                        .padding(.horizontal, 20)

                    VStack(spacing: 12) {
                        ForEach(favoritesPalettes) { palette in
                            paletteCard(palette: palette)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
        }
    }

    private func paletteCard(palette: PaletteDisplayItem) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(palette.name)
                        .font(.interSemiBold(size: 18))
                        .foregroundStyle(titleColor)
                    HStack(spacing: 8) {
                        ForEach(palette.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.interRegular(size: 12))
                                .foregroundStyle(secondaryColor)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(background)
                                .cornerRadius(10)
                        }
                    }
                }
                Spacer(minLength: 0)
                Button {
                    palettesService.toggleFavorite(id: palette.id)
                } label: {
                    Image(systemName: palette.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(palette.isFavorite ? Color.rgb(106, 169, 255) : secondaryColor)
                }
            }

            HStack(spacing: 8) {
                ForEach(Array(palette.colors.enumerated()), id: \.offset) { _, color in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
            }
        }
        .padding(16)
        .background(Color.rgb(18, 26, 46))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var tipCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("💡 Tip: Try complementary harmony to create contrast.")
                .font(.interRegular(size: 14))
                .foregroundStyle(secondaryColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.rgb(15, 22, 41))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.rgb(36, 48, 74), lineWidth: 1)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

#Preview {
    HomeView()
        .environmentObject(TabRouter())
}
