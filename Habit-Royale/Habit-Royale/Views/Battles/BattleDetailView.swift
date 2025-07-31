import SwiftUI

struct BattleDetailView: View {
    let battle: Battle
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BattleDetailViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Battle header
                    battleHeaderSection
                    
                    // Battle status
                    battleStatusSection
                    
                    // Questions and ratings
                    if battle.status == .active || battle.status == .completed {
                        questionsSection
                    }
                    
                    // Results (if completed)
                    if battle.status == .completed {
                        resultsSection
                    }
                    
                    // Actions
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Battle Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.loadBattleDetails(battle)
        }
    }
    
    private var battleHeaderSection: some View {
        VStack(spacing: 16) {
            // VS Display
            HStack(spacing: 20) {
                // Challenger
                VStack {
                    playerAvatar(viewModel.challengerName)
                    Text(viewModel.challengerName)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text("Herausforderer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // VS
                Text("VS")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                // Defender
                VStack {
                    playerAvatar(viewModel.defenderName)
                    Text(viewModel.defenderName)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text("Verteidiger")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Battle date
            Text("Erstellt: \(battle.createdAt.formatForDisplay())")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private var battleStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Status:")
                    .font(.headline)
                
                Spacer()
                
                statusBadge
            }
            
            // Progress indicators
            if battle.status == .active {
                battleProgressView
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var statusBadge: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(12)
    }
    
    private var statusText: String {
        switch battle.status {
        case .pending: return "Ausstehend"
        case .active: return "Aktiv"
        case .completed: return "Abgeschlossen"
        case .declined: return "Abgelehnt"
        case .expired: return "Abgelaufen"
        }
    }
    
    private var statusColor: Color {
        switch battle.status {
        case .pending: return .orange
        case .active: return .blue
        case .completed: return .green
        case .declined: return .gray
        case .expired: return .red
        }
    }
    
    private var battleProgressView: some View {
        VStack(spacing: 8) {
            Text("Bewertungsfortschritt:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                // Challenger progress
                VStack {
                    Text(viewModel.challengerName)
                        .font(.caption)
                    
                    ProgressView(value: Double(battle.challengerRatings.count), total: 3)
                        .tint(.blue)
                    
                    Text("\(battle.challengerRatings.count)/3")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Defender progress
                VStack {
                    Text(viewModel.defenderName)
                        .font(.caption)
                    
                    ProgressView(value: Double(battle.defenderRatings.count), total: 3)
                        .tint(.green)
                    
                    Text("\(battle.defenderRatings.count)/3")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lifestyle-Fragen")
                .font(.headline)
            
            ForEach(Array(battle.questions.enumerated()), id: \.offset) { index, question in
                QuestionCard(
                    question: question,
                    index: index,
                    challengerRating: battle.challengerRatings.count > index ? battle.challengerRatings[index] : nil,
                    defenderRating: battle.defenderRatings.count > index ? battle.defenderRatings[index] : nil,
                    challengerName: viewModel.challengerName,
                    defenderName: viewModel.defenderName
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ergebnisse")
                .font(.headline)
            
            HStack {
                // Challenger score
                VStack {
                    Text(viewModel.challengerName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(battle.challengerScore ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(battle.winnerId == battle.challengerId ? .green : .red)
                }
                .frame(maxWidth: .infinity)
                
                Text(":")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Defender score
                VStack {
                    Text(viewModel.defenderName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(battle.defenderScore ?? 0)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(battle.winnerId == battle.defenderId ? .green : .red)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Winner announcement
            if let winnerId = battle.winnerId {
                let winnerName = winnerId == battle.challengerId ? viewModel.challengerName : viewModel.defenderName
                
                HStack {
                    Text("🏆")
                        .font(.title)
                    
                    Text("\(winnerName) gewinnt!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            if battle.status == .pending && battle.defenderId == viewModel.currentUserId {
                // Accept/Decline buttons
                HStack(spacing: 16) {
                    Button("Ablehnen") {
                        viewModel.declineBattle(battle.id ?? "")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                    
                    Button("Annehmen") {
                        viewModel.acceptBattle(battle.id ?? "")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            if battle.status == .active && !viewModel.hasUserRated {
                Button("Jetzt bewerten") {
                    // Navigate to rating view
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func playerAvatar(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Text(name.prefix(2).uppercased())
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
    }
}

struct QuestionCard: View {
    let question: BattleQuestion
    let index: Int
    let challengerRating: Int?
    let defenderRating: Int?
    let challengerName: String
    let defenderName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question header
            HStack {
                Text(question.icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Frage \(index + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(question.question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            // Category badge
            Text(question.category.name)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(categoryColor.opacity(0.2))
                .foregroundColor(categoryColor)
                .cornerRadius(4)
            
            // Ratings
            if let challengerRating = challengerRating, let defenderRating = defenderRating {
                HStack {
                    // Challenger rating
                    VStack(alignment: .leading) {
                        Text(challengerName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(challengerRating)/10")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    // Defender rating
                    VStack(alignment: .trailing) {
                        Text(defenderName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(defenderRating)/10")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 8)
            } else {
                Text("Bewertungen ausstehend...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var categoryColor: Color {
        switch question.category {
        case .health: return .green
        case .relationships: return .pink
        case .spirituality: return .purple
        case .productivity: return .orange
        case .habits: return .blue
        }
    }
}

// ViewModel
class BattleDetailViewModel: ObservableObject {
    @Published var challengerName = "Spieler 1"
    @Published var defenderName = "Spieler 2"
    @Published var hasUserRated = false
    
    var currentUserId: String {
        // Get current user ID from AuthenticationManager
        return AuthenticationManager.shared.currentUser?.id ?? ""
    }
    
    func loadBattleDetails(_ battle: Battle) {
        // Load player names and determine if current user has rated
        // This would typically fetch from Firebase
        hasUserRated = currentUserId == battle.challengerId ? 
            !battle.challengerRatings.isEmpty : 
            !battle.defenderRatings.isEmpty
    }
    
    func acceptBattle(_ battleId: String) {
        // Update battle status to active
    }
    
    func declineBattle(_ battleId: String) {
        // Update battle status to declined
    }
}

#Preview {
    BattleDetailView(battle: Battle(
        challengerId: "user1",
        defenderId: "user2",
        status: .active,
        questions: [
            BattleQuestion(
                id: "q1",
                question: "Wie gut warst du mit deinem Schlaf?",
                description: "Bewerte deine Schlafqualität",
                category: .health,
                icon: "🌙",
                positiveWeighting: true
            )
        ],
        challengerRatings: [8],
        defenderRatings: [],
        createdAt: Date()
    ))
}