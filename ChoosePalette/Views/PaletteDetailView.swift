import SwiftUI
import UIKit

struct PaletteDetailView: View {
    let paletteId: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.showTabBar) private var showTabBar
    @ObservedObject private var palettesService = PalettesService.shared
    @AppStorage(UserDefaultsKeys.defaultCopyFormat) private var defaultCopyFormat = "HEX"
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    @State private var shareImage: UIImage?

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)

    private var palette: PaletteModel? {
        palettesService.palette(byId: paletteId)
    }

    private var displayItem: PaletteDisplayItem? {
        guard let p = palette else { return nil }
        return PaletteDisplayItem(
            id: p.id,
            name: p.name,
            tags: p.tags,
            colors: p.colorHexes.compactMap { Color.hex($0) },
            isFavorite: p.isFavorite
        )
    }

    var body: some View {
        Group {
            if let item = displayItem {
                detailContent(item: item)
            } else {
                deletedPlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear { showTabBar.wrappedValue = false }
        .onDisappear { showTabBar.wrappedValue = true }
        .alert("Delete palette", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                palettesService.delete(id: paletteId)
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
        .sheet(isPresented: $showEditSheet) {
            EditPaletteView(paletteId: paletteId)
        }
        .sheet(item: Binding(
            get: { shareImage.map { ShareImageWrapper(image: $0) } },
            set: { if $0 == nil { shareImage = nil } }
        )) { wrapper in
            ShareSheet(activityItems: [wrapper.image], onDismiss: { shareImage = nil })
        }
    }

    private var deletedPlaceholder: some View {
        VStack(spacing: 16) {
            Text("Palette not found")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
            Button("Back") { dismiss() }
                .font(.interMedium(size: 16))
                .foregroundStyle(Color.rgb(106, 169, 255))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func detailContent(item: PaletteDisplayItem) -> some View {
        VStack(spacing: 0) {
            header(item: item)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    colorStrip(colors: item.colors)
                    tagsSection(tags: item.tags)
                    colorRows(hexes: palette?.colorHexes ?? [])
                    actionsSection(item: item)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
        }
    }

    private func header(item: PaletteDisplayItem) -> some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.rgb(106, 169, 255))
            }
            .frame(width: 36, height: 36)

            Spacer()

            Text(item.name)
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .lineLimit(1)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    shareImage = renderPaletteImage(name: item.name, colorHexes: palette?.colorHexes ?? [])
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundStyle(titleColor)
                }
                .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private func colorStrip(colors: [Color]) -> some View {
        VStack(spacing: 0) {
            if colors.isEmpty {
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBackground)
                    .frame(height: 120)
            } else {
                HStack(spacing: 0) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                        RoundedRectangle(cornerRadius: 0)
                            .fill(color)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private func tagsSection(tags: [String]) -> some View {
        Group {
            if !tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
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
        }
    }

    private func colorRows(hexes: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Colors")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            VStack(spacing: 0) {
                ForEach(Array(hexes.enumerated()), id: \.offset) { _, hex in
                    colorRow(hex: hex)
                    if hex != hexes.last {
                        Divider()
                            .background(secondaryColor.opacity(0.2))
                            .padding(.leading, 16)
                    }
                }
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func colorRow(hex: String) -> some View {
        let normalizedHex = hex.hasPrefix("#") ? hex : "#" + hex
        let copyText = defaultCopyFormat == "RGB" ? rgbString(for: hex) : normalizedHex
        return HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.hex(normalizedHex) ?? .gray)
                .frame(width: 48, height: 48)

            Text(normalizedHex)
                .font(.interRegular(size: 15))
                .foregroundStyle(titleColor)

            Spacer(minLength: 0)

            Button {
                UIPasteboard.general.string = copyText
                HapticHelper.impactIfEnabled()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 18))
                    .foregroundStyle(secondaryColor)
            }
        }
        .padding(16)
    }

    private func rgbString(for hex: String) -> String {
        guard let color = Color.hex(hex.hasPrefix("#") ? hex : "#" + hex) else { return hex }
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        return "\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255))"
    }

    private func actionsSection(item: PaletteDisplayItem) -> some View {
        VStack(spacing: 12) {
            Button {
                palettesService.toggleFavorite(id: item.id)
            } label: {
                HStack {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                    Text(item.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                        .font(.interMedium(size: 16))
                }
                .foregroundStyle(item.isFavorite ? Color.rgb(106, 169, 255) : titleColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button {
                showEditSheet = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                    Text("Edit Palette")
                        .font(.interMedium(size: 16))
                }
                .foregroundStyle(titleColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button {
                showDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                    Text("Delete Palette")
                        .font(.interMedium(size: 16))
                }
                .foregroundStyle(Color.rgb(255, 82, 82))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
    }

    private func renderPaletteImage(name: String, colorHexes: [String]) -> UIImage? {
        let width = 600
        let colorHeight = 80
        let headerHeight = 60
        let totalHeight = headerHeight + colorHeight
        let size = CGSize(width: width, height: totalHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        let bgColor = UIColor(red: 11/255, green: 16/255, blue: 32/255, alpha: 1)
        let textColor = UIColor(red: 234/255, green: 240/255, blue: 255/255, alpha: 1)
        return renderer.image { ctx in
            bgColor.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor
            ]
            (name as NSString).draw(at: CGPoint(x: 24, y: 18), withAttributes: attrs)
            let count = max(1, colorHexes.count)
            let barWidth = CGFloat(width) / CGFloat(count)
            for (i, hex) in colorHexes.enumerated() {
                let s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
                guard s.count == 6, let value = Int(s, radix: 16) else { continue }
                let r = CGFloat((value >> 16) & 0xFF) / 255
                let g = CGFloat((value >> 8) & 0xFF) / 255
                let b = CGFloat(value & 0xFF) / 255
                UIColor(red: r, green: g, blue: b, alpha: 1).setFill()
                ctx.fill(CGRect(x: CGFloat(i) * barWidth, y: CGFloat(headerHeight), width: barWidth, height: CGFloat(colorHeight)))
            }
        }
    }
}

private struct ShareImageWrapper: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        vc.completionWithItemsHandler = { _, _, _, _ in onDismiss?() }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PaletteDetailView(paletteId: UUID().uuidString)
    }
}
