import SwiftUI

struct SplashView: View {
    @State private var barScales: [CGFloat] = Array(repeating: 0.2, count: 5)
    @State private var barOpacities: [Double] = Array(repeating: 0, count: 5)
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var gradientRotation: Double = 0
    @State private var centerGlowOpacity: Double = 0

    private let background = Color.rgb(11, 16, 32)
    private let barColors: [Color] = [
        Color.rgb(106, 169, 255),
        Color.rgb(180, 140, 255),
        Color.rgb(255, 107, 157),
        Color.rgb(66, 221, 155),
        Color.rgb(255, 193, 7)
    ]

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    barColors[i].opacity(0.4),
                                    barColors[i].opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 40)
                        .offset(
                            x: 80 * cos(gradientRotation + Double(i) * 2.1),
                            y: 60 * sin(gradientRotation + Double(i) * 2.1)
                        )
                        .opacity(0.6 + 0.2 * sin(gradientRotation + Double(i)))
                }
            }
            .opacity(centerGlowOpacity)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [barColors[0], barColors[1], barColors[0]],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 140, height: 140)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            HStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(barColors[i])
                        .frame(width: 16, height: 56)
                        .scaleEffect(y: barScales[i], anchor: .bottom)
                        .opacity(barOpacities[i])
                }
            }
        }
        .onAppear {
            for i in 0..<5 {
                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                    .delay(Double(i) * 0.08)
                ) {
                    barScales[i] = 1
                    barOpacities[i] = 1
                }
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                ringScale = 1.15
                ringOpacity = 0.8
            }
            withAnimation(.easeInOut(duration: 1.2).delay(0.4)) {
                centerGlowOpacity = 1
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                gradientRotation = .pi * 2
            }
        }
    }
}

#Preview {
    SplashView()
}
