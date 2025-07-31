import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class BattlesViewModel: ObservableObject {
    @Published var activeBattles: [Battle] = []
    @Published var pendingBattles: [Battle] = []
    @Published var completedBattles: [Battle] = []
    @Published var battleStats: BattleStats?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    func loadBattles() {
        guard let userId = currentUserId else { return }
        
        isLoading = true
        
        // Load battles where user is challenger or defender
        let challengerListener = db.collection("battles")
            .whereField("challengerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.processBattles(snapshot: snapshot)
            }
        
        let defenderListener = db.collection("battles")
            .whereField("defenderId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.processBattles(snapshot: snapshot)
            }
        
        listeners.append(challengerListener)
        listeners.append(defenderListener)
        
        // Load battle stats
        loadBattleStats()
    }
    
    private func processBattles(snapshot: QuerySnapshot?) {
        guard let documents = snapshot?.documents else { return }
        
        let battles = documents.compactMap { doc in
            try? doc.data(as: Battle.self)
        }
        
        // Categorize battles
        var active: [Battle] = []
        var pending: [Battle] = []
        var completed: [Battle] = []
        
        for battle in battles {
            switch battle.status {
            case .active:
                active.append(battle)
            case .pending:
                pending.append(battle)
            case .completed:
                completed.append(battle)
            default:
                break
            }
        }
        
        // Sort by date
        active.sort { $0.createdAt > $1.createdAt }
        pending.sort { $0.createdAt > $1.createdAt }
        completed.sort { $0.completedAt ?? $0.createdAt > $1.completedAt ?? $1.createdAt }
        
        // Update published properties
        DispatchQueue.main.async {
            self.activeBattles = active
            self.pendingBattles = pending
            self.completedBattles = Array(completed.prefix(10)) // Last 10 battles
            self.isLoading = false
        }
    }
    
    private func loadBattleStats() {
        guard let userId = currentUserId else { return }
        
        let listener = db.collection("users").document(userId)
            .collection("battleStats").document("current")
            .addSnapshotListener { [weak self] snapshot, error in
                if let stats = try? snapshot?.data(as: BattleStats.self) {
                    DispatchQueue.main.async {
                        self?.battleStats = stats
                    }
                }
            }
        
        listeners.append(listener)
    }
    
    func challengeUser(username: String) async throws {
        guard let challengerId = currentUserId else { return }
        
        // Find user by username
        let userSnapshot = try await db.collection("users")
            .whereField("username", isEqualTo: username)
            .limit(to: 1)
            .getDocuments()
        
        guard let defenderId = userSnapshot.documents.first?.documentID else {
            throw BattleError.userNotFound
        }
        
        // Don't allow challenging yourself
        if defenderId == challengerId {
            throw BattleError.cannotChallengeSelf
        }
        
        // Create battle with random questions
        let questions = try await getRandomQuestions()
        
        let battle = Battle(
            challengerId: challengerId,
            defenderId: defenderId,
            status: .pending,
            questions: questions,
            challengerRatings: [],
            defenderRatings: [],
            createdAt: Date()
        )
        
        try await db.collection("battles").addDocument(from: battle)
    }
    
    func submitRatings(battleId: String, ratings: [Int]) async throws {
        guard let userId = currentUserId else { return }
        
        let battleRef = db.collection("battles").document(battleId)
        
        try await db.runTransaction { transaction, errorPointer in
            let battleDoc = try transaction.getDocument(battleRef)
            guard var battle = try? battleDoc.data(as: Battle.self) else {
                throw BattleError.battleNotFound
            }
            
            // Update ratings based on user role
            if battle.challengerId == userId {
                battle.challengerRatings = ratings
            } else if battle.defenderId == userId {
                battle.defenderRatings = ratings
            } else {
                throw BattleError.notParticipant
            }
            
            // Check if both have rated
            if !battle.challengerRatings.isEmpty && !battle.defenderRatings.isEmpty {
                // Calculate scores
                let (challengerScore, defenderScore) = self.calculateScores(
                    battle: battle,
                    challengerRatings: battle.challengerRatings,
                    defenderRatings: battle.defenderRatings
                )
                
                battle.challengerScore = challengerScore
                battle.defenderScore = defenderScore
                battle.winnerId = challengerScore > defenderScore ? battle.challengerId : battle.defenderId
                battle.status = .completed
                battle.completedAt = Date()
            }
            
            // Update battle
            try transaction.setData(from: battle, forDocument: battleRef)
            
            return nil
        }
    }
    
    func hasUserRated(battle: Battle) -> Bool {
        guard let userId = currentUserId else { return false }
        
        if battle.challengerId == userId {
            return !battle.challengerRatings.isEmpty
        } else if battle.defenderId == userId {
            return !battle.defenderRatings.isEmpty
        }
        
        return false
    }
    
    private func getRandomQuestions() async throws -> [BattleQuestion] {
        let snapshot = try await db.collection("battleQuestions")
            .getDocuments()
        
        var allQuestions = snapshot.documents.compactMap { doc in
            try? doc.data(as: BattleQuestion.self)
        }
        
        // Shuffle and take 3
        allQuestions.shuffle()
        return Array(allQuestions.prefix(3))
    }
    
    private func calculateScores(battle: Battle, challengerRatings: [Int], defenderRatings: [Int]) -> (Int, Int) {
        var challengerScore = 0
        var defenderScore = 0
        
        for (index, question) in battle.questions.enumerated() {
            let challengerRating = challengerRatings[index]
            let defenderRating = defenderRatings[index]
            
            if question.positiveWeighting {
                // Higher is better
                challengerScore += challengerRating
                defenderScore += defenderRating
            } else {
                // Lower is better (invert scores)
                challengerScore += (11 - challengerRating)
                defenderScore += (11 - defenderRating)
            }
        }
        
        return (challengerScore, defenderScore)
    }
}

enum BattleError: LocalizedError {
    case userNotFound
    case cannotChallengeSelf
    case battleNotFound
    case notParticipant
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Benutzer nicht gefunden."
        case .cannotChallengeSelf:
            return "Du kannst dich nicht selbst herausfordern."
        case .battleNotFound:
            return "Kampf nicht gefunden."
        case .notParticipant:
            return "Du bist kein Teilnehmer dieses Kampfes."
        }
    }
}