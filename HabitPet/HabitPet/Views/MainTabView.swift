import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 2 // Dashboard als Standard
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PetsView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint.fill")
                }
                .tag(0)
            
            CompetitionView()
                .tabItem {
                    Label("Competition", systemImage: "trophy.fill")
                }
                .tag(1)
            
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(2)
            
            BattlesView()
                .tabItem {
                    Label("Battles", systemImage: "sword.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}