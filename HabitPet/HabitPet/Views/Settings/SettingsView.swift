import SwiftUI

struct SettingsView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Settings", selection: $selectedTab) {
                    Label("Ziele", systemImage: "target").tag(0)
                    Label("Habits", systemImage: "plus.circle").tag(1)
                    Label("Account", systemImage: "person").tag(2)
                    
                    if userManager.currentUser?.role == .admin ||
                       userManager.currentUser?.role == .petCreator ||
                       userManager.currentUser?.role == .petManager {
                        Label("Admin", systemImage: "shield").tag(3)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    GoalsSettingsView()
                        .tag(0)
                    
                    CustomHabitsSettingsView()
                        .tag(1)
                    
                    AccountSettingsView()
                        .tag(2)
                    
                    if userManager.currentUser?.role == .admin ||
                       userManager.currentUser?.role == .petCreator ||
                       userManager.currentUser?.role == .petManager {
                        AdminPanelView()
                            .tag(3)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Einstellungen")
            .background(Color.gray.opacity(0.1))
        }
    }
}

struct GoalsSettingsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Sleep goal
                GoalSettingCard(
                    title: "Schlaf",
                    icon: "moon.fill",
                    color: .purple,
                    value: $viewModel.sleepGoal,
                    unit: "Stunden",
                    minValue: 4,
                    maxValue: 12,
                    step: 0.5,
                    onSave: { viewModel.saveSleepGoal() }
                )
                
                // Exercise goal
                GoalSettingCard(
                    title: "Sport",
                    icon: "figure.run",
                    color: .green,
                    value: $viewModel.exerciseGoal,
                    unit: "Minuten",
                    minValue: 0,
                    maxValue: 180,
                    step: 5,
                    onSave: { viewModel.saveExerciseGoal() }
                )
                
                // Screen time goal
                GoalSettingCard(
                    title: "Bildschirmzeit",
                    icon: "iphone",
                    color: .orange,
                    value: $viewModel.screenTimeGoal,
                    unit: "Stunden",
                    minValue: 0,
                    maxValue: 12,
                    step: 0.5,
                    onSave: { viewModel.saveScreenTimeGoal() }
                )
                
                // Save all button
                Button(action: viewModel.saveAllGoals) {
                    Text("Alle Ziele speichern")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Info card
                InfoCard(
                    title: "Pet-Effekte",
                    message: "Das Erreichen deiner Ziele erhöht die Gesundheit deines Pets um 10-20 Punkte. Übertreffen bringt Bonus-XP!",
                    icon: "info.circle.fill",
                    color: .blue
                )
            }
            .padding(.vertical)
        }
    }
}

struct GoalSettingCard: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var value: Double
    let unit: String
    let minValue: Double
    let maxValue: Double
    let step: Double
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(value, specifier: "%.1f") \(unit)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: minValue...maxValue, step: step)
                .accentColor(color)
            
            HStack {
                Text("\(Int(minValue)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(maxValue)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onSave) {
                Text("Speichern")
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct AccountSettingsView: View {
    @State private var showResetAlert = false
    @State private var showDeleteAlert = false
    @State private var resetConfirmation = ""
    @State private var deleteConfirmation = ""
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User info
                UserInfoCard()
                
                // Progress reset
                VStack(alignment: .leading, spacing: 12) {
                    Text("Fortschritt zurücksetzen")
                        .font(.headline)
                    
                    Text("Dies löscht dein aktuelles Pet und alle Gewohnheitsdaten. Dein Account bleibt bestehen.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showResetAlert = true }) {
                        Text("Fortschritt zurücksetzen")
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Account deletion
                VStack(alignment: .leading, spacing: 12) {
                    Text("Account löschen")
                        .font(.headline)
                    
                    Text("Dies löscht deinen Account und alle damit verbundenen Daten permanent.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showDeleteAlert = true }) {
                        Text("Account löschen")
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Sign out
                Button(action: signOut) {
                    Text("Abmelden")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .alert("Fortschritt zurücksetzen?", isPresented: $showResetAlert) {
            TextField("Tippe RESET zur Bestätigung", text: $resetConfirmation)
            Button("Abbrechen", role: .cancel) {
                resetConfirmation = ""
            }
            Button("Zurücksetzen", role: .destructive) {
                if resetConfirmation == "RESET" {
                    resetProgress()
                }
                resetConfirmation = ""
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
        .alert("Account löschen?", isPresented: $showDeleteAlert) {
            TextField("Tippe DELETE zur Bestätigung", text: $deleteConfirmation)
            Button("Abbrechen", role: .cancel) {
                deleteConfirmation = ""
            }
            Button("Löschen", role: .destructive) {
                if deleteConfirmation == "DELETE" {
                    deleteAccount()
                }
                deleteConfirmation = ""
            }
        } message: {
            Text("Diese Aktion ist permanent und kann nicht rückgängig gemacht werden.")
        }
    }
    
    private func signOut() {
        try? authManager.signOut()
    }
    
    private func resetProgress() {
        // Implement progress reset
    }
    
    private func deleteAccount() {
        Task {
            try? await authManager.deleteAccount()
        }
    }
}

struct UserInfoCard: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Text(userManager.currentUser?.username.prefix(2).uppercased() ?? "??")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // User info
            VStack(spacing: 4) {
                Text(userManager.currentUser?.username ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(userManager.currentUser?.email ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("Level \(userManager.currentUser?.level ?? 1)")
                        .font(.headline)
                    Text("Spieler")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(userManager.pets.count)")
                        .font(.headline)
                    Text("Pets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct InfoCard: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}