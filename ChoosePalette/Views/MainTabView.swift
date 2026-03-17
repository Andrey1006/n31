import SwiftUI

struct MainTabView: View {
    @StateObject private var tabRouter = TabRouter()
    @State private var showTabBar = true

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch tabRouter.selectedTab {
                case 0:
                    NavigationStack {
                        HomeView()
                    }
                case 1:
                    CreatePaletteView()
                case 2:
                    CaptureView()
                case 3:
                    NavigationStack {
                        LibraryView()
                    }
                case 4:
                    ProfileView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(tabRouter)
            .environment(\.showTabBar, $showTabBar)

            if showTabBar {
                CustomTabBar(selectedIndex: tabRouter.selectedTab) { index in
                    tabRouter.selectTab(index)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
