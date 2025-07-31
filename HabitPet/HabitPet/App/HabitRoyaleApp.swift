import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@main
struct HabitRoyaleApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var userManager = UserManager.shared
    
    init() {
        FirebaseApp.configure()
        setupFirebaseSettings()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    if userManager.hasActivePet {
                        MainTabView()
                    } else {
                        PetSelectionView()
                    }
                } else {
                    AuthenticationView()
                }
            }
            .environmentObject(authManager)
            .environmentObject(userManager)
            .onAppear {
                setupAppearance()
            }
        }
    }
    
    private func setupFirebaseSettings() {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024)
        Firestore.firestore().settings = settings
    }
    
    private func setupAppearance() {
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}