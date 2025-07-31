import SwiftUI

struct BattlesView: View {
    @StateObject private var viewModel = BattlesViewModel()
    @State private var showUserSearch = false
    @State private var selectedBattle: Battle?
    @State private var showRatingView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search section
                    searchSection
                    
                    // Active battles
                    if !viewModel.activeBattles.isEmpty {
                        battleSection(
                            title: "Aktive Kämpfe",
                            battles: viewModel.activeBattles,
                            showStatus: true
                        )
                    }
                    
                    // Pending battles
                    if !viewModel.pendingBattles.isEmpty {
                        battleSection(
                            title: "Offene Herausforderungen",
                            battles: viewModel.pendingBattles,
                            showStatus: false
                        )
                    }
                    
                    // Battle history
                    if !viewModel.completedBattles.isEmpty {
                        battleSection(
                            title: "Kampfverlauf",
                            battles: viewModel.completedBattles,
                            showStatus: false
                        )
                    }
                    
                    // Battle stats
                    if let stats = viewModel.battleStats {
                        BattleStatsCard(stats: stats)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Kämpfe")
            .background(Color.gray.opacity(0.1))
            .sheet(isPresented: $showUserSearch) {
                UserSearchView(onChallenge: viewModel.challengeUser)
            }
            .sheet(item: $selectedBattle) { battle in
                BattleDetailView(battle: battle)
            }
            .sheet(isPresented: $showRatingView) {
                if let battle = selectedBattle {
                    BattleRatingView(
                        battle: battle,
                        onComplete: { ratings in
                            viewModel.submitRatings(battleId: battle.id ?? "", ratings: ratings)
                        }
                    )
                }
            }
        }
        .onAppear {
            viewModel.loadBattles()
        }
    }
    
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Neuer Kampf")
                .font(.headline)
                .padding(.horizontal)
            
            Button(action: { showUserSearch = true }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    Text("Nach Spielern suchen...")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal)
        }
    }
    
    private func battleSection(title: String, battles: [Battle], showStatus: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(battles) { battle in
                BattleCard(
                    battle: battle,
                    currentUserId: viewModel.currentUserId,
                    showStatus: showStatus,
                    onTap: {
                        selectedBattle = battle
                        if battle.status == .active && !viewModel.hasUserRated(battle: battle) {
                            showRatingView = true
                        }
                    }
                )
            }
        }
    }
}

struct BattleCard: View {
    let battle: Battle
    let currentUserId: String
    let showStatus: Bool
    let onTap: () -> Void
    
    var opponentId: String {
        battle.challengerId == currentUserId ? battle.defenderId : battle.challengerId
    }
    
    var statusText: String {
        switch battle.status {
        case .pending:
            return battle.challengerId == currentUserId ? "Warte auf Antwort" : "Annahme ausstehend"
        case .active:
            if battle.challengerId == currentUserId {
                return battle.challengerRatings.isEmpty ? "Bewertung ausstehend" : "Warte auf Gegner"
            } else {
                return battle.defenderRatings.isEmpty ? "Bewertung ausstehend" : "Warte auf Gegner"
            }
        case .completed:
            return battle.winnerId == currentUserId ? "Gewonnen! 🎉" : "Verloren"
        case .declined:
            return "Abgelehnt"
        case .expired:
            return "Abgelaufen"
        }
    }
    
    var statusColor: Color {
        switch battle.status {
        case .pending: return .orange
        case .active: return .blue
        case .completed: return battle.winnerId == currentUserId ? .green : .red
        case .declined: return .gray
        case .expired: return .gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    // Opponent info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("vs. Gegner") // In real app, fetch opponent name
                            .font(.headline)
                        
                        if showStatus {
                            Text(statusText)
                                .font(.caption)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Score or action
                    if battle.status == .completed, let myScore = getMyScore(), let opponentScore = getOpponentScore() {
                        HStack(spacing: 8) {
                            Text("\(myScore)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(myScore > opponentScore ? .green : .red)
                            
                            Text(":")
                                .foregroundColor(.secondary)
                            
                            Text("\(opponentScore)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(opponentScore > myScore ? .green : .red)
                        }
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress indicator
                if battle.status == .active {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(hasRatedQuestion(index) ? Color.green : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    private func getMyScore() -> Int? {
        if battle.challengerId == currentUserId {
            return battle.challengerScore
        } else {
            return battle.defenderScore
        }
    }
    
    private func getOpponentScore() -> Int? {
        if battle.challengerId == currentUserId {
            return battle.defenderScore
        } else {
            return battle.challengerScore
        }
    }
    
    private func hasRatedQuestion(_ index: Int) -> Bool {
        let ratings = battle.challengerId == currentUserId ? battle.challengerRatings : battle.defenderRatings
        return index < ratings.count
    }
}

struct BattleStatsCard: View {
    let stats: BattleStats
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Kampfstatistiken")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatItem(
                    value: "\(stats.totalBattles)",
                    label: "Kämpfe",
                    color: .blue
                )
                
                StatItem(
                    value: "\(Int(stats.winRate))%",
                    label: "Siegesrate",
                    color: stats.performance == .excellent ? .green : .orange
                )
                
                StatItem(
                    value: "\(stats.currentStreak)",
                    label: "Serie",
                    color: .purple
                )
            }
            
            // Performance indicator
            HStack(spacing: 8) {
                Text(stats.performance.emoji)
                    .font(.title2)
                
                Text(stats.performance.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}