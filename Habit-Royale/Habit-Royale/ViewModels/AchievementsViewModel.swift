import Foundation
import FirebaseFirestore
import FirebaseAuth

class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var userAchievements: [UserAchievement] = []
    @Published var progressData: [String: Int] = [:]
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    func loadAchievements() {
        loadAllAchievements()
        loadUserAchievements()
        loadProgressData()
    }
    
    private func loadAllAchievements() {
        let listener = db.collection("achievements")
            .order(by: "category")
            .order(by: "requirement")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self?.achievements = documents.compactMap { doc in
                    try? doc.data(as: Achievement.self)
                }
            }
        
        listeners.append(listener)
    }
    
    private func loadUserAchievements() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let listener = db.collection("users").document(userId)
            .collection("achievements")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self?.userAchievements = documents.compactMap { doc in
                    try? doc.data(as: UserAchievement.self)
                }
            }
        
        listeners.append(listener)
    }
    
    private func loadProgressData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            // Load various progress data for achievement calculation
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.loadStreakProgress(userId: userId) }
                group.addTask { await self.loadCompletionProgress(userId: userId) }
                group.addTask { await self.loadLevelProgress(userId: userId) }
                group.addTask { await self.loadSpecialProgress(userId: userId) }
            }
        }
    }
    
    private func loadStreakProgress(userId: String) async {
        do {
            let doc = try await db.collection("users").document(userId)
                .collection("streak").document("current")
                .getDocument()
            
            if let streak = try? doc.data(as: UserStreak.self) {
                await MainActor.run {
                    self.progressData["current_streak"] = streak.count
                    self.progressData["longest_streak"] = streak.longestStreak
                }
            }
        } catch {
            print("Error loading streak progress: \(error)")
        }
    }
    
    private func loadCompletionProgress(userId: String) async {
        do {
            let doc = try await db.collection("users").document(userId)
                .collection("progress").document("current")
                .getDocument()
            
            if let progress = try? doc.data(as: UserProgress.self) {
                await MainActor.run {
                    self.progressData["total_completions"] = progress.totalCompletions
                    self.progressData["perfect_days"] = progress.perfectDays
                }
            }
        } catch {
            print("Error loading completion progress: \(error)")
        }
    }
    
    private func loadLevelProgress(userId: String) async {
        do {
            let doc = try await db.collection("users").document(userId)
                .getDocument()
            
            if let user = try? doc.data(as: User.self) {
                await MainActor.run {
                    self.progressData["user_level"] = user.level
                }
            }
        } catch {
            print("Error loading level progress: \(error)")
        }
    }
    
    private func loadSpecialProgress(userId: String) async {
        // Load special achievement progress like battle wins, etc.
        do {
            let doc = try await db.collection("users").document(userId)
                .collection("battleStats").document("current")
                .getDocument()
            
            if let stats = try? doc.data(as: BattleStats.self) {
                await MainActor.run {
                    self.progressData["battle_wins"] = stats.wins
                    self.progressData["battle_streak"] = stats.currentStreak
                }
            }
        } catch {
            print("Error loading special progress: \(error)")
        }
    }
    
    func getUserAchievement(for achievementId: String) -> UserAchievement? {
        userAchievements.first { $0.achievementId == achievementId }
    }
    
    func getProgress(for achievementId: String) -> Int {
        guard let achievement = achievements.first(where: { $0.id == achievementId }) else {
            return 0
        }
        
        let progressKey = getProgressKey(for: achievement)
        return progressData[progressKey] ?? 0
    }
    
    private func getProgressKey(for achievement: Achievement) -> String {
        switch achievement.category {
        case .streak:
            if achievement.title.contains("Längste") {
                return "longest_streak"
            } else {
                return "current_streak"
            }
        case .completion:
            if achievement.title.contains("Perfekt") {
                return "perfect_days"
            } else {
                return "total_completions"
            }
        case .level:
            return "user_level"
        case .special:
            if achievement.title.contains("Battle") {
                return "battle_wins"
            } else {
                return "total_completions"  // fallback
            }
        }
    }
}