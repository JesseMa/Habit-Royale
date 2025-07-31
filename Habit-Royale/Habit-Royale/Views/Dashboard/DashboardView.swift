import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome section
                    welcomeSection
                    
                    // Active pet card
                    if let pet = userManager.activePet {
                        ActivePetCard(pet: pet)
                            .onTapGesture {
                                // Navigate to pet profile
                            }
                    }
                    
                    // Quick stats
                    quickStatsSection
                    
                    // Quick actions
                    quickActionsSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            viewModel.loadDashboardData()
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Hi, \(userManager.currentUser?.username ?? "")! 👋")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Wie geht es deinem Pet heute?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "flame",
                iconColor: .orange,
                value: "\(viewModel.currentStreak)",
                label: "Streak"
            )
            
            StatCard(
                icon: "star.fill",
                iconColor: .purple,
                value: "\(userManager.activePet?.experience ?? 0)",
                label: "XP"
            )
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            QuickActionCard(
                icon: "target",
                title: "Gewohnheiten",
                subtitle: "Heute deine Ziele erreichen",
                color: .green,
                destination: AnyView(HabitsView())
            )
            
            QuickActionCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Fortschritt",
                subtitle: "Deine Entwicklung verfolgen",
                color: .blue,
                destination: AnyView(ProgressTrackingView())
            )
            
            QuickActionCard(
                icon: "swords",
                title: "Kämpfe",
                subtitle: "Andere Spieler herausfordern",
                color: .red,
                destination: AnyView(BattlesView())
            )
        }
    }
}

struct ActivePetCard: View {
    let pet: Pet
    
    var body: some View {
        VStack(spacing: 16) {
            // Pet image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text(pet.evolution.emoji)
                    .font(.system(size: 60))
            }
            
            // Pet info
            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Level \(pet.level) • \(pet.evolution.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Health bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    Text("\(pet.health)/\(pet.maxHealth) HP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * pet.healthPercentage, height: 8)
                            .animation(.easeInOut, value: pet.health)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickActionCard<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}