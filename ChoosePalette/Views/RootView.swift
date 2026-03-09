import SwiftUI


struct RootView: View {
    @AppStorage(UserDefaultsKeys.onboardingCompleted) private var onboardingCompleted = false
    @StateObject private var authState = AuthStateObserver()

    var body: some View {
        Group {
            if !onboardingCompleted {
                OnboardingView(onComplete: {
                    onboardingCompleted = true
                })
            } else if authState.currentUser == nil {
                CreateProfileView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: onboardingCompleted)
        .animation(.easeInOut(duration: 0.25), value: authState.currentUser != nil)
    }
}
