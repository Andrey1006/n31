import SwiftUI
import UIKit

struct CreatePaletteView: View {
    enum Mode: String, CaseIterable {
        case manual = "Manual"
        case generator = "Generator"
    }

    @State private var mode: Mode = .manual
    @State private var manualColors: [String] = []
    @State private var paletteName: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var showColorPicker = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var colorPickerForNew = true
    @AppStorage(UserDefaultsKeys.defaultCopyFormat) private var defaultCopyFormat = "HEX"
    @Environment(\.showTabBar) private var showTabBar

    @State private var generatorHarmony: GeneratorHarmony = .complementary
    @State private var baseColorHex: String = "#6AA9FF"
    @State private var generatedColors: [String] = Self.randomHexColors(count: 5)

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)
    private let gradientColors: [Color] = [
        Color.rgb(106, 169, 255),
        Color.rgb(180, 140, 255)
    ]
    private let allTags = ["Brand", "UI", "Illustration", "Dark", "Fresh", "Nature"]

    private let presetColors = [
        "#6AA9FF", "#B48CFF", "#FF6B9D", "#4CAF50",
        "#FFC107", "#FF5722", "#9C27B0", "#00BCD4",
        "#E91E63", "#8BC34A", "#795548", "#607D8B"
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            segmentedControl
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if mode == .manual {
                        manualContent
                    } else {
                        generatorContent
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .overlay(alignment: .top) { toastView }
        .sheet(isPresented: $showColorPicker) { colorPickerSheet }
        .onAppear {
            showTabBar.wrappedValue = true
            let draft = DraftPaletteStore.shared.takeDraft()
            if !draft.isEmpty {
                manualColors = draft
                toastMessage = "Palette loaded! Add a name and save."
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showToast = false }
            }
        }
    }

    private var header: some View {
        HStack {
            Button { } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.rgb(106, 169, 255))
            }
            .frame(width: 36, height: 36)

            Spacer()

            Text("Create Palette")
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
                PalettesService.shared.add(name: name, tags: Array(selectedTags), colorHexes: manualColors)
                toastMessage = "Saved"
                showToast = true
                paletteName = ""
                selectedTags = []
                manualColors = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showToast = false }
            }
            .font(.interMedium(size: 14))
            .foregroundStyle(secondaryColor)
            .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(Mode.allCases, id: \.self) { m in
                Button {
                    withAnimation { mode = m }
                } label: {
                    Text(m.rawValue)
                        .font(.interSemiBold(size: 16))
                        .foregroundStyle(mode == m ? .white : secondaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(mode == m ? Color.rgb(106, 169, 255) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 24)
    }

    

    private var manualContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add 3-6 colors.")
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
    }

    

    private enum GeneratorHarmony: String, CaseIterable {
        case complementary = "Complementary"
        case analogous = "Analogous"
        case triadic = "Triadic"
        case monochrome = "Monochrome"
    }

    private var generatorContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            harmonySection
            baseColorSection
            generatedPaletteSection
            generatorButtons
        }
        .padding(.top, 14)
        .padding(.bottom, 32)
    }

    private var harmonySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose harmony type")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .padding(.horizontal, 24)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(GeneratorHarmony.allCases, id: \.self) { h in
                        Button {
                            generatorHarmony = h
                        } label: {
                            Text(h.rawValue)
                                .font(.interMedium(size: 14))
                                .foregroundStyle(generatorHarmony == h ? titleColor : secondaryColor)
                                .padding(.horizontal, 16)
                                .frame(height: 40)
                                .background(generatorHarmony == h ? Color.rgb(106, 169, 255).opacity(0.3) : cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 24)
    }

    private var baseColorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Base color")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .padding(.horizontal, 24)
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.hex(baseColorHex) ?? .gray)
                    .frame(width: 56, height: 56)
                Button("Change Color") {
                    colorPickerForNew = false
                    showColorPicker = true
                }
                .font(.interMedium(size: 15))
                .foregroundStyle(titleColor)
                Spacer()
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }

    private var generatedPaletteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generated palette")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .padding(.horizontal, 24)
            HStack(spacing: 10) {
                ForEach(Array(generatedColors.enumerated()), id: \.offset) { _, hex in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.hex(hex) ?? .gray)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }

    private var generatorButtons: some View {
        HStack(spacing: 12) {
            Button("Regenerate") {
                generatedColors = Self.randomHexColors(count: 5)
            }
            .font(.interMedium(size: 16))
            .foregroundStyle(titleColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Button("Use This Palette") {
                manualColors = generatedColors
                mode = .manual
                toastMessage = "Palette loaded! Add a name and save."
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showToast = false
                }
            }
            .font(.interSemiBold(size: 16))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 24)
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
                        if colorPickerForNew {
                            if manualColors.count < 6 {
                                manualColors.append(hex)
                            }
                        } else {
                            baseColorHex = hex
                        }
                        showColorPicker = false
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
                Button {
                    showToast = false
                } label: {
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

    private static func randomHexColors(count: Int) -> [String] {
        (0..<count).map { _ in
            let r = Int.random(in: 0...255)
            let g = Int.random(in: 0...255)
            let b = Int.random(in: 0...255)
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}

#Preview {
    CreatePaletteView()
}
