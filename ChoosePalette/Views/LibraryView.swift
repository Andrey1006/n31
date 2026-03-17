import SwiftUI

struct LibraryView: View {
    enum Filter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
        case tagged = "Tagged"
    }

    var initialFilter: Filter?
    var isPushed: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.showTabBar) private var showTabBar
    @State private var activeFilter: Filter = .all
    @State private var showSearchAlert = false
    @State private var searchQuery = ""
    @ObservedObject private var palettesService = PalettesService.shared

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)

    private var displayedPalettes: [PaletteDisplayItem] {
        let items = palettesService.displayItems
        let filtered: [PaletteDisplayItem]
        switch activeFilter {
        case .all:
            filtered = items
        case .favorites:
            filtered = items.filter(\.isFavorite)
        case .recent:
            filtered = items
        case .tagged:
            filtered = items.filter { !$0.tags.isEmpty }
        }
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    init(initialFilter: Filter? = nil, isPushed: Bool = false) {
        self.initialFilter = initialFilter
        self.isPushed = isPushed
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            filterBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(displayedPalettes) { palette in
                        NavigationLink(destination: PaletteDetailView(paletteId: palette.id)
                            .environment(\.showTabBar, showTabBar)
                        ) {
                            libraryPaletteCard(palette: palette)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .onAppear {
            if !isPushed { showTabBar.wrappedValue = true }
            if let f = initialFilter { activeFilter = f }
        }
        .alert("Search by name", isPresented: $showSearchAlert) {
            TextField("Palette name", text: $searchQuery)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            Button("Search") {
                
            }
            Button("Clear", role: .destructive) {
                searchQuery = ""
            }
            Button("Cancel", role: .cancel) {
                searchQuery = ""
            }
        } message: {
            Text("Enter part of the palette name to filter the list.")
        }
    }

    private var header: some View {
        HStack {
            if isPushed {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.rgb(106, 169, 255))
                }
                .frame(width: 36, height: 36)
            } else {
                Color.clear
                    .frame(width: 36, height: 36)
            }

            Spacer()

            Text("Library")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            Spacer()

            Button {
                showSearchAlert = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundStyle(titleColor)
            }
            .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private var filterBar: some View {
        HStack(spacing: 10) {
            ForEach(Filter.allCases, id: \.self) { filter in
                Button {
                    activeFilter = filter
                } label: {
                    Text(filter.rawValue)
                        .font(.interSemiBold(size: 16))
                        .foregroundStyle(activeFilter == filter ? .white : secondaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(activeFilter == filter ? Color.rgb(106, 169, 255) : cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 16)
    }

    private func libraryPaletteCard(palette: PaletteDisplayItem) -> some View {
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
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    LibraryView()
}
