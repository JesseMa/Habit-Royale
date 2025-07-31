import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            if let user = user {
                self?.fetchUserData(userId: user.uid)
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    func signUp(email: String, password: String, username: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // Check if username already exists
        let usernameExists = try await checkUsernameExists(username)
        if usernameExists {
            throw AuthError.usernameAlreadyExists
        }
        
        // Create Firebase Auth user
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Create user document in Firestore
        let newUser = User(username: username, email: email)
        try db.collection("users").document(authResult.user.uid).setData(from: newUser)
        
        // Create initial collections
        await createInitialUserCollections(userId: authResult.user.uid)
        
        self.currentUser = newUser
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        
        // Delete user data from Firestore
        try await deleteUserData(userId: user.uid)
        
        // Delete Firebase Auth account
        try await user.delete()
        
        currentUser = nil
    }
    
    // MARK: - Helper Methods
    
    private func fetchUserData(userId: String) {
        db.collection("users").document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error)")
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                
                do {
                    self?.currentUser = try snapshot?.data(as: User.self)
                } catch {
                    print("Error decoding user: \(error)")
                }
            }
    }
    
    private func checkUsernameExists(_ username: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }
    
    private func createInitialUserCollections(userId: String) async {
        // Create initial goals
        let goals = Goal()
        try? await db.collection("users").document(userId)
            .collection("goals").document("default")
            .setData(from: goals)
        
        // Create initial progress
        let progress = UserProgress()
        try? await db.collection("users").document(userId)
            .collection("progress").document("current")
            .setData(from: progress)
        
        // Create initial battle stats
        let battleStats = BattleStats()
        try? await db.collection("users").document(userId)
            .collection("battleStats").document("current")
            .setData(from: battleStats)
        
        // Create initial streak
        let streak = UserStreak()
        try? await db.collection("users").document(userId)
            .collection("streak").document("current")
            .setData(from: streak)
    }
    
    private func deleteUserData(userId: String) async throws {
        // Delete all user subcollections
        let collections = ["pets", "goals", "customHabits", "habitLogs", "achievements", "progress", "battleStats", "streak", "calendar"]
        
        for collection in collections {
            let documents = try await db.collection("users").document(userId)
                .collection(collection).getDocuments()
            
            for document in documents.documents {
                try await document.reference.delete()
            }
        }
        
        // Delete user document
        try await db.collection("users").document(userId).delete()
    }
}

// MARK: - Custom Errors

enum AuthError: LocalizedError {
    case usernameAlreadyExists
    case noCurrentUser
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .usernameAlreadyExists:
            return "Dieser Benutzername ist bereits vergeben."
        case .noCurrentUser:
            return "Kein Benutzer angemeldet."
        case .invalidCredentials:
            return "Ungültige Anmeldedaten."
        }
    }
}