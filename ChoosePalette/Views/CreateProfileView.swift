import SwiftUI

struct CreateProfileView: View {
    @State private var selectedAvatarIndex: Int = 0
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let background = Color.rgb(11, 16, 32)
    private let cardBackground = Color.rgb(18, 26, 46)
    private let titleColor = Color.rgb(234, 240, 255)
    private let secondaryColor = Color.rgb(167, 179, 209)
    private let gradientColors: [Color] = [
        Color.rgb(180, 140, 255),
        Color.rgb(106, 169, 255)
    ]

    private let avatars: [(emoji: String, color: Color)] = [
        ("🎨", Color.rgb(106, 169, 255)),
        ("🌈", Color.rgb(180, 140, 255)),
        ("✨", Color.rgb(0, 150, 136)),
        ("🎭", Color.rgb(180, 100, 80))
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerText
                    avatarSection
                    nameField
                    emailField
                    passwordField
                    createProfileButton
                    logInButton
                    continueAsGuestButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea())
        .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Button("OK") { errorMessage = nil }
        } message: {
            if let msg = errorMessage { Text(msg) }
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Create your profile")
                .font(.interSemiBold(size: 24))
                .foregroundStyle(titleColor)
            Text("Save palettes across sessions.")
                .font(.interRegular(size: 16))
                .foregroundStyle(secondaryColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 28)
    }

    private var avatarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose an avatar")
                .font(.interMedium(size: 14))
                .foregroundStyle(secondaryColor)
            HStack(spacing: 16) {
                ForEach(Array(avatars.enumerated()), id: \.offset) { index, item in
                    Button {
                        selectedAvatarIndex = index
                    } label: {
                        ZStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 64, height: 64)
                            Text(item.emoji)
                                .font(.system(size: 32))
                            if selectedAvatarIndex == index {
                                Circle()
                                    .stroke(titleColor, lineWidth: 3)
                                    .frame(width: 64, height: 64)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 28)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Name")
                .font(.interMedium(size: 14))
                .foregroundStyle(secondaryColor)
            TextField("", text: $name, prompt:
                        Text("Your name")
                            .font(.interRegular(size: 16))
                            .foregroundColor(secondaryColor)
            )
            .font(.interRegular(size: 16))
            .foregroundStyle(titleColor)
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 20)
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email")
                .font(.interMedium(size: 14))
                .foregroundStyle(secondaryColor)
            TextField("", text: $email, prompt:
                        Text("your@email.com")
                .font(.interRegular(size: 16))
                .foregroundColor(secondaryColor)
            )
                .font(.interRegular(size: 16))
                .foregroundStyle(titleColor)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding(16)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 20)
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password (optional)")
                .font(.interMedium(size: 14))
                .foregroundStyle(secondaryColor)
            HStack {
                if isPasswordVisible {
                    TextField("Create a password", text: $password, prompt:
                                Text("Create a password")
                        .font(.interRegular(size: 16))
                        .foregroundColor(secondaryColor)
                    )
                        .font(.interRegular(size: 16))
                        .foregroundStyle(titleColor)
                } else {
                    SecureField("Create a password", text: $password, prompt:
                                    Text("Create a password")
                        .font(.interRegular(size: 16))
                        .foregroundColor(secondaryColor)
                    )
                        .font(.interRegular(size: 16))
                        .foregroundStyle(titleColor)
                }
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 18))
                        .foregroundStyle(secondaryColor)
                }
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.bottom, 28)
    }

    private var createProfileButton: some View {
        Button {
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Enter email and password."
                return
            }
            isLoading = true
            errorMessage = nil
            UserDefaults.standard.set(selectedAvatarIndex, forKey: UserDefaultsKeys.profileAvatarIndex)
            Task {
                do {
                    _ = try await AuthService.shared.register(email: email, password: password)
                } catch let e as AuthServiceError {
                    errorMessage = String(describing: e)
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        } label: {
            Text("Create Profile")
        }
        .font(.interSemiBold(size: 16))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .buttonStyle(.plain)
        .disabled(isLoading)
        .padding(.bottom, 12)
    }

    private var logInButton: some View {
        Button {
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Enter email and password."
                return
            }
            isLoading = true
            errorMessage = nil
            UserDefaults.standard.set(selectedAvatarIndex, forKey: UserDefaultsKeys.profileAvatarIndex)
            Task {
                do {
                    _ = try await AuthService.shared.signIn(email: email, password: password)
                } catch let e as AuthServiceError {
                    errorMessage = String(describing: e)
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        } label: {
            Text("Log In")
        }
        .font(.interSemiBold(size: 16))
        .foregroundStyle(titleColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .buttonStyle(.plain)
        .disabled(isLoading)
        .padding(.bottom, 12)
    }

    private var continueAsGuestButton: some View {
        Button {
            isLoading = true
            errorMessage = nil
            UserDefaults.standard.set(selectedAvatarIndex, forKey: UserDefaultsKeys.profileAvatarIndex)
            Task {
                do {
                    _ = try await AuthService.shared.signInAnonymously()
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        } label: {
            Text("Continue as Guest")
        }
        .font(.interSemiBold(size: 16))
        .foregroundStyle(titleColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

#Preview {
    CreateProfileView()
}
