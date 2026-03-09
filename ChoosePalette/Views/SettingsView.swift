import SwiftUI

private struct WebViewSheetItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(UserDefaultsKeys.defaultCopyFormat) private var defaultCopyFormat: String = "HEX"
    @AppStorage(UserDefaultsKeys.hapticFeedbackEnabled) private var hapticFeedbackEnabled: Bool = true
    @State private var showClearAlert = false
    @State private var webViewItem: WebViewSheetItem?

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    preferencesSection
                    dataSection
                    aboutSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .alert("Palettes cleared", isPresented: $showClearAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All palettes have been removed.")
        }
        .sheet(item: $webViewItem) { item in
            webViewSheet(url: item.url)
        }
    }

    private func webViewSheet(url: URL) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Done") {
                    webViewItem = nil
                }
                .font(.interMedium(size: 16))
                .foregroundStyle(Color.rgb(106, 169, 255))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(background)
            WebView(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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

            Text("Settings")
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

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Preferences")

            VStack(spacing: 0) {
                settingsRow(title: "Default copy format", value: defaultCopyFormat)
                Divider()
                    .background(secondaryColor.opacity(0.2))
                    .padding(.leading, 16)
                settingsRowWithToggle(title: "Enable haptic feedback", isOn: $hapticFeedbackEnabled)
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 24)
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Data")

            Button("Clear all palettes") {
                PalettesService.shared.clearAll()
                showClearAlert = true
            }
            .font(.interMedium(size: 16))
            .foregroundStyle(Color.rgb(255, 82, 82))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .buttonStyle(.plain)
        }
        .padding(.bottom, 24)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("About")

            VStack(spacing: 0) {
                settingsRow(title: "Version", value: "1.0")
                Divider()
                    .background(secondaryColor.opacity(0.2))
                    .padding(.leading, 16)
                settingsLinkRow(title: "Privacy Policy", url: URL(string: "https://sites.google.com/view/colorweave-creator/privacy-policy")!)
                Divider()
                    .background(secondaryColor.opacity(0.2))
                    .padding(.leading, 16)
                settingsLinkRow(title: "Terms of Use", url: URL(string: "https://sites.google.com/view/colorweave-creator/terms-of-service")!)
            }
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.interSemiBold(size: 18))
            .foregroundStyle(titleColor)
            .padding(.bottom, 4)
    }

    private func settingsRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.interRegular(size: 16))
                .foregroundStyle(titleColor)
            Spacer(minLength: 0)
            Text(value)
                .font(.interRegular(size: 16))
                .foregroundStyle(secondaryColor)
        }
        .padding(16)
    }

    private func settingsRowWithToggle(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.interRegular(size: 16))
                .foregroundStyle(titleColor)
            Spacer(minLength: 0)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.rgb(106, 169, 255))
        }
        .padding(16)
    }

    private func settingsLinkRow(title: String, url: URL) -> some View {
        Button {
            webViewItem = WebViewSheetItem(url: url)
        } label: {
            HStack {
                Text(title)
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
}

#Preview {
    SettingsView()
}
