import SwiftUI

struct CustomTabBar: View {
    let selectedIndex: Int
    let onSelect: (Int) -> Void

    private let selectedColor = Color.rgb(106, 169, 255)
    private let unselectedColor = Color.rgb(167, 179, 209)
    private let backgroundColor = Color.rgb(18, 26, 46)

    private let items: [(icon: String, title: String)] = [
        ("house", "Home"),
        ("plus", "Create"),
        ("camera", "Camera"),
        ("square.grid.3x3", "Library"),
        ("person", "Profile")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                tabItem(index: index, icon: item.icon, title: item.title)
            }
        }
        .padding(.vertical, 12)
        .background(backgroundColor)
    }

    private func tabItem(index: Int, icon: String, title: String) -> some View {
        let isSelected = selectedIndex == index
        return Button {
            onSelect(index)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .frame(height: 24)
                Text(title)
                    .font(.interMedium(size: 12))
            }
            .foregroundStyle(isSelected ? selectedColor : unselectedColor)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainTabView()
}
