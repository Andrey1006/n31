import SwiftUI

struct OnboardingView: View {
    var onComplete: (() -> Void)?

    @State private var currentPage = 0

    private let background = Color.rgb(11, 16, 32)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)
    private let gradientColors: [Color] = [
        Color.rgb(106, 169, 255),
        Color.rgb(180, 140, 255)
    ]

    var body: some View {
        VStack(spacing: 0) {
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation { currentPage -= 1 }
                        }
                        .font(.interMedium(size: 16))
                        .foregroundStyle(secondaryColor)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.leading, 46)
                .padding(.top, 6)
                .frame(height: 44)

                TabView(selection: $currentPage) {
                    onboardingPage1.tag(0)
                    onboardingPage2.tag(1)
                    onboardingPage3.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                pageIndicator
                primaryButton
                skipButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            background
                .ignoresSafeArea()
        )
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.rgb(106, 169, 255) : secondaryColor.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, 24)
    }

    private var primaryButton: some View {
        Button {
            if currentPage < 2 {
                withAnimation { currentPage += 1 }
            } else {
                onComplete?()
            }
        } label: {
            Text(currentPage == 2 ? "Get Started" : "Next")
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
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 32)
        .padding(.bottom, 16)
    }

    private var skipButton: some View {
        Button {
            onComplete?()
        } label: {
            Text("Skip")
                .font(.interSemiBold(size: 16))
                .foregroundStyle(secondaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.clear)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 32)
    }

    private var onboardingPage1: some View {
        OnboardingPage(
            icon: "onboarding1Icon",
            title: "Create palettes in seconds",
            description: "Build color palettes with 3 to 8 colors. Save your favorites and reuse them anytime.",
            titleColor: titleColor,
            secondaryColor: secondaryColor,
            iconBackground: background
        )
    }

    private var onboardingPage2: some View {
        OnboardingPage(
            icon: "onboarding2Icon",
            title: "Capture colors",
            description: "Use your camera to pick colors from the real world. Import a photo from your gallery and tap to sample.",
            titleColor: titleColor,
            secondaryColor: secondaryColor,
            iconBackground: background
        )
    }

    private var onboardingPage3: some View {
        OnboardingPage(
            icon: "onboarding3Icon",
            title: "Copy & Share",
            description: "Copy HEX, RGB, HSL, or CMYK with one tap. Export palettes as images and share them anywhere.",
            titleColor: titleColor,
            secondaryColor: secondaryColor,
            iconBackground: background
        )
    }
}

private struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let titleColor: Color
    let secondaryColor: Color
    let iconBackground: Color

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image(icon)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 84)
            Spacer()
            
            Text(title)
                .font(.interSemiBold(size: 24))
                .foregroundStyle(titleColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

            Text(description)
                .font(.interRegular(size: 16))
                .foregroundStyle(secondaryColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            
        }
    }
}

#Preview {
    OnboardingView()
}
