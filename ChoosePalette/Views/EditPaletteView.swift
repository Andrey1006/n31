import SwiftUI
import UIKit

struct EditPaletteView: View {
    let paletteId: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.showTabBar) private var showTabBar
    @ObservedObject private var palettesService = PalettesService.shared
    @State private var paletteName: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var manualColors: [String] = []
    @State private var showColorPicker = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var colorPickerForNew = true
    @State private var colorPickerEditingIndex: Int?
    @AppStorage(UserDefaultsKeys.defaultCopyFormat) private var defaultCopyFormat = "HEX"

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)
    private let allTags = ["Brand", "UI", "Illustration", "Dark", "Fresh", "Nature"]
    private let presetColors = [
        "#6AA9FF", "#B48CFF", "#FF6B9D", "#4CAF50",
        "#FFC107", "#FF5722", "#9C27B0", "#00BCD4",
        "#E91E63", "#8BC34A", "#795548", "#607D8B"
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Edit name, tags, and colors (3–6).")
                        .font(.interRegular(size: 14))
                        .foregroundStyle(secondaryColor)
                        .padding(.horizontal, 24)

                    manualColorsSection
                    addColorButton
                    paletteNameField
                    tagsSection
                }
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .overlay(alignment: .top) { toastView }
        .sheet(isPresented: $showColorPicker) { colorPickerSheet }
        .onAppear {
            showTabBar.wrappedValue = false
            if let p = palettesService.palette(byId: paletteId) {
                paletteName = p.name
                selectedTags = Set(p.tags)
                manualColors = p.colorHexes.map { $0.hasPrefix("#") ? $0 : "#" + $0 }
            }
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.rgb(106, 169, 255))
            }
            .frame(width: 36, height: 36)

            Spacer()

            Text("Edit Palette")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            Spacer()

            Button("Save") {
                let name = paletteName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Palette" : paletteName
                guard manualColors.count >= 3 else {
                    toastMessage = "Add at least 3 colors."
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showToast = false }
                    return
                }
                palettesService.update(id: paletteId, name: name, tags: Array(selectedTags), colorHexes: manualColors)
                toastMessage = "Updated"
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showToast = false
                    dismiss()
                }
            }
            .font(.interMedium(size: 14))
            .foregroundStyle(secondaryColor)
            .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private var manualColorsSection: some View {
        Group {
            if manualColors.isEmpty {
                Text("No colors yet")
                    .font(.interRegular(size: 16))
                    .foregroundStyle(secondaryColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(manualColors.enumerated()), id: \.offset) { index, hex in
                        manualColorRow(hex: hex, index: index)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func manualColorRow(hex: String, index: Int) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.hex(hex) ?? .gray)
                    .frame(width: 48, height: 48)
                Button {
                    manualColors.remove(at: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.red)
                }
                .offset(x: 6, y: -6)
            }
            Text(hex.hasPrefix("#") ? hex : "#" + hex)
                .font(.interRegular(size: 15))
                .foregroundStyle(titleColor)
            Spacer()
            Button {
                colorPickerEditingIndex = index
                colorPickerForNew = false
                showColorPicker = true
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 18))
                    .foregroundStyle(secondaryColor)
            }
            Button {
                let toCopy = defaultCopyFormat == "RGB" ? rgbString(for: hex) : (hex.hasPrefix("#") ? hex : "#" + hex)
                UIPasteboard.general.string = toCopy
                HapticHelper.impactIfEnabled()
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 18))
                    .foregroundStyle(secondaryColor)
            }
        }
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func rgbString(for hex: String) -> String {
        guard let color = Color.hex(hex.hasPrefix("#") ? hex : "#" + hex) else { return hex }
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        return "\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255))"
    }

    private var addColorButton: some View {
        Button {
            colorPickerEditingIndex = nil
            colorPickerForNew = true
            showColorPicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Add Color")
                    .font(.interSemiBold(size: 16))
            }
            .foregroundStyle(Color.rgb(106, 169, 255))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.rgb(106, 169, 255), lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
        .disabled(manualColors.count >= 6)
    }

    private var paletteNameField: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Palette Name")
                .font(.interMedium(size: 14))
                .foregroundStyle(secondaryColor)
                .padding(.horizontal, 24)
            TextField("", text: $paletteName, prompt:
                Text("Untitled Palette")
                    .font(.interRegular(size: 16))
                    .foregroundColor(secondaryColor)
            )
            .font(.interRegular(size: 16))
            .foregroundStyle(titleColor)
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tags")
                .font(.interMedium(size: 14))
                .foregroundStyle(secondaryColor)
                .padding(.horizontal, 24)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allTags, id: \.self) { tag in
                        Button {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        } label: {
                            Text(tag)
                                .font(.interSemiBold(size: 14))
                                .foregroundStyle(selectedTags.contains(tag) ? .white : secondaryColor)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedTags.contains(tag) ? Color.rgb(106, 169, 255) : cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 24)
    }

    private var colorPickerSheet: some View {
        VStack(spacing: 0) {
            Text("Choose a color")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                .padding(.leading, 24)
                .padding(.bottom, 20)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(presetColors, id: \.self) { hex in
                    Button {
                        if let idx = colorPickerEditingIndex, idx < manualColors.count {
                            manualColors[idx] = hex
                        } else if colorPickerForNew, manualColors.count < 6 {
                            manualColors.append(hex)
                        }
                        showColorPicker = false
                        colorPickerEditingIndex = nil
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.hex(hex) ?? .gray)
                            .aspectRatio(1, contentMode: .fit)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 24)

            Button("Cancel") {
                showColorPicker = false
                colorPickerEditingIndex = nil
            }
            .font(.interMedium(size: 17))
            .foregroundStyle(secondaryColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background)
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private var toastView: some View {
        if showToast {
            HStack {
                Text(toastMessage)
                    .font(.interRegular(size: 14))
                    .foregroundStyle(background)
                Spacer(minLength: 8)
                Button { showToast = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(background)
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeOut(duration: 0.25), value: showToast)
        }
    }
}

#Preview {
    EditPaletteView(paletteId: UUID().uuidString)
}
