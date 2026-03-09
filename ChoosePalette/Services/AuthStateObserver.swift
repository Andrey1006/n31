import Foundation
import FirebaseAuth
import Combine

final class AuthStateObserver: ObservableObject {
    @Published private(set) var currentUser: User?

    private var listenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
        }
    }

    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
