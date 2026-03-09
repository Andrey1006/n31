import Foundation
import FirebaseAuth

enum AuthServiceError: Error {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case unknown(Error)
}

final class AuthService {

    static let shared = AuthService()

    private let auth = Auth.auth()

    private init() {}

    var currentUser: User? {
        auth.currentUser
    }

    var isAnonymous: Bool {
        currentUser?.isAnonymous ?? false
    }

    func register(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    func signInAnonymously() async throws -> User {
        do {
            let result = try await auth.signInAnonymously()
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw AuthServiceError.unknown(error)
        }
    }

    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AuthServiceError.userNotFound
        }
        try await user.delete()
    }

    func linkAnonymousAccount(email: String, password: String) async throws -> User {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        guard let user = auth.currentUser else {
            throw AuthServiceError.userNotFound
        }
        do {
            let result = try await user.link(with: credential)
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    private func mapAuthError(_ error: NSError) -> AuthServiceError {
        guard error.domain == AuthErrorDomain else {
            return .unknown(error)
        }
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error)
        }
        switch code {
        case .invalidEmail, .wrongPassword, .invalidCredential:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .unknown(error)
        }
    }
}
