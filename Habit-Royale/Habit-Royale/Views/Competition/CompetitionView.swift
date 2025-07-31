import SwiftUI

struct CompetitionView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Competition", selection: $selectedTab) {
                    Text("Rangliste").tag(0)
                    Text("Fortschritt").tag(1)
                    Text("Erfolge").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    LeaderboardView()
                        .tag(0)
                    
                    ProgressTrackingView()
                        .tag(1)
                    
                    AchievementsView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Competition")
            .background(Color.gray.opacity(0.1))
        }
    }
}

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @State private var selectedPeriod: LeaderboardPeriod = .weekly
    
    var body: some View {
        VStack(spacing: 16) {
            // Period selector
            Picker("Zeitraum", selection: $selectedPeriod) {
                ForEach(LeaderboardPeriod.allCases, id: \.self) { period in
                    Text(period.name).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        // Stats summary
                        LeaderboardStatsCard(
                            totalPlayers: viewModel.entries.count,
                            userRank: viewModel.userRank,
                            userScore: viewModel.userScore
                        )
                        
                        // Leaderboard entries
                        ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardEntryCard(
                                entry: entry,
                                rank: index + 1,
                                isCurrentUser: entry.userId == viewModel.currentUserId
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onChange(of: selectedPeriod) { _ in
            viewModel.loadLeaderboard(for: selectedPeriod)
        }
        .onAppear {
            viewModel.loadLeaderboard(for: selectedPeriod)
        }
    }
}

struct LeaderboardStatsCard: View {
    let totalPlayers: Int
    let userRank: Int?
    let userScore: Int?
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(totalPlayers)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Spieler")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("#\(userRank ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text("Dein Rang")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("\(userScore ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Text("Punkte")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct LeaderboardEntryCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    let isCurrentUser: Bool
    
    var rankDisplay: String {
        switch rank {
        case 1: return "👑"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rank)"
        }
    }
    
    var backgroundColor: Color {
        if isCurrentUser {
            return Color.green.opacity(0.1)
        } else if rank <= 3 {
            return Color.yellow.opacity(0.05)
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text(rankDisplay)
                .font(rank <= 3 ? .title2 : .headline)
                .frame(width: 50)
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.username)
                        .font(.headline)
                    
                    if isCurrentUser {
                        Text("(Du)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                if let petType = entry.petType {
                    Text("\(petType) • Level \(entry.petLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Score
            Text("\(entry.score)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}