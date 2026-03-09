import SwiftUI
import UIKit

struct CaptureView: View {
    enum ScreenState {
        case capture
        case pickingColor(showPaletteOptions: Bool)
    }

    @State private var screenState: ScreenState = .capture
    @State private var gradientColors: [Color] = []
    @State private var sampledColor: Color = Color.rgb(106, 169, 255)
    @State private var pickerLocation: CGFloat = 0.5
    @State private var showImagePicker = false
    @State private var imagePickerSource: ImagePicker.Source = .photoLibrary
    @EnvironmentObject private var tabRouter: TabRouter
    @Environment(\.showTabBar) private var showTabBar

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)
    private let gradientButtonColors: [Color] = [
        Color.rgb(106, 169, 255),
        Color.rgb(180, 140, 255)
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .onAppear {
            showTabBar.wrappedValue = true
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                source: imagePickerSource,
                onPick: { image in
                    let colors = ImageColorExtractor.extractVerticalGradient(from: image)
                    if !colors.isEmpty {
                        gradientColors = colors
                        sampledColor = colors[colors.count / 2]
                        pickerLocation = 0.5
                        screenState = .pickingColor(showPaletteOptions: false)
                    }
                },
                onCancel: { }
            )
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Button {
                switch screenState {
                case .capture:
                    break 
                case .pickingColor:
                    screenState = .capture
                }
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.rgb(106, 169, 255))
            }
            .frame(width: 36, height: 36)

            Spacer()

            Text(headerTitle)
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)

            Spacer()

            if case .pickingColor = screenState {
                Button("Add") {
                    if case .pickingColor(let show) = screenState {
                        screenState = .pickingColor(showPaletteOptions: !show)
                    }
                }
                .font(.interMedium(size: 17))
                .foregroundStyle(titleColor)
                .frame(width: 36, height: 36)
            } else {
                Color.clear
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private var headerTitle: String {
        switch screenState {
        case .capture: return "Capture"
        case .pickingColor: return "Pick Color"
        }
    }

    @ViewBuilder
    private var content: some View {
        switch screenState {
        case .capture:
            captureContent
        case .pickingColor(let showPaletteOptions):
            pickingContent(showPaletteOptions: showPaletteOptions)
        }
    }

    private var captureContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(cardBackground)
                        .frame(minHeight: 520)

                    VStack(spacing: 12) {
                        Image(systemName: "camera")
                            .font(.system(size: 56))
                            .foregroundStyle(secondaryColor)
                        Text("Camera preview")
                            .font(.interMedium(size: 16))
                            .foregroundStyle(secondaryColor)
                        Text("Tap a point to sample a color.")
                            .font(.interRegular(size: 14))
                            .foregroundStyle(secondaryColor.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 24)

                Button {
                    imagePickerSource = .camera
                    showImagePicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "camera")
                            .font(.system(size: 18))
                        Text("Take Photo")
                            .font(.interSemiBold(size: 16))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: gradientButtonColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                Button("Choose from Gallery") {
                    imagePickerSource = .photoLibrary
                    showImagePicker = true
                }
                .font(.interRegular(size: 16))
                .foregroundStyle(secondaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    private func pickingContent(showPaletteOptions: Bool) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                gradientArea
                Text("Tap on image to sample")
                    .font(.interRegular(size: 14))
                    .foregroundStyle(secondaryColor)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                colorInfoCard
                    .padding(.bottom, 24)

                if showPaletteOptions {
                    addToPaletteSection
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 14)
            .padding(.bottom, 32)
        }
    }

    private var gradientArea: some View {
        ZStack {
            if gradientColors.isEmpty {
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardBackground)
                    .frame(height: 520)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 520)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateSampledColor(at: value.location, height: 520)
                            }
                    )
                    .onTapGesture { location in
                        updateSampledColor(at: location, height: 520)
                    }
                    .overlay(alignment: .top) {
                        Circle()
                            .stroke(Color.rgb(30, 45, 90), lineWidth: 3)
                            .background(Circle().fill(sampledColor))
                            .frame(width: 32, height: 32)
                            .offset(y: pickerLocation * (520 - 32) + 16)
                    }
            }
        }
        .frame(height: 520)
    }

    private func updateSampledColor(at location: CGPoint, height: CGFloat) {
        let y = max(0, min(location.y, height))
        let t = y / height
        pickerLocation = t
        let index = Int(t * CGFloat(max(0, gradientColors.count - 1)))
        let clamped = max(0, min(index, gradientColors.count - 1))
        sampledColor = gradientColors[clamped]
    }

    private var colorInfoCard: some View {
        let hex = sampledColorHex
        let rgb = sampledColorRGB
        return HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(sampledColor)
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 8) {
                Text(hex)
                    .font(.interMedium(size: 16))
                    .foregroundStyle(titleColor)
                Text("RGB: \(rgb)")
                    .font(.interRegular(size: 14))
                    .foregroundStyle(secondaryColor)
                HStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.string = hex
                        HapticHelper.impactIfEnabled()
                    } label: {
                        Label("Copy HEX", systemImage: "doc.on.doc")
                            .font(.interRegular(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(secondaryColor)
                            .padding(.vertical, 12)
                            .background(cardBackground)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    Button {
                        UIPasteboard.general.string = rgb
                        HapticHelper.impactIfEnabled()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                            
                            Text("Copy RGB")
                        }
                        .font(.interRegular(size: 14))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(secondaryColor)
                        .padding(.vertical, 12)
                        .background(cardBackground)
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var sampledColorHex: String {
        let (r, g, b) = sampledColorComponents
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    private var sampledColorRGB: String {
        let (r, g, b) = sampledColorComponents
        return "\(r), \(g), \(b)"
    }

    private var sampledColorComponents: (Int, Int, Int) {
        let ui = UIColor(sampledColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        return (Int(r * 255), Int(g * 255), Int(b * 255))
    }

    private var addToPaletteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add to palette")
                .font(.interSemiBold(size: 18))
                .foregroundStyle(titleColor)
                .padding(.bottom, 4)

            VStack(spacing: 0) {
                Button {
                    DraftPaletteStore.shared.addColor(hex: sampledColorHex)
                    tabRouter.selectTab(1)
                } label: {
                    HStack {
                        Text("Add to Current Palette")
                            .font(.interRegular(size: 16))
                            .foregroundStyle(titleColor)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(secondaryColor)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
                Divider()
                    .background(secondaryColor.opacity(0.2))
                    .padding(.leading, 16)
                Button {
                    DraftPaletteStore.shared.setDraft(gradientColors.map { $0.toHex() })
                    tabRouter.selectTab(1)
                } label: {
                    HStack {
                        Text("Create New Palette from Picks")
                            .font(.interRegular(size: 16))
                            .foregroundStyle(titleColor)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(secondaryColor)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    CaptureView()
        .environmentObject(TabRouter())
}
